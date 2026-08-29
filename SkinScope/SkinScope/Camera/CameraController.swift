import AVFoundation
import UIKit

/// Drives the capture session.
///
/// Plug-in digital microscopes come in two flavors:
///  1. Optical clip-on lenses (cheap ones) — these just sit in front of the
///     regular iPhone camera, so we simply use the built-in camera, usually
///     the ultra-wide lens which focuses closest.
///  2. USB/UVC digital microscopes with their own sensor, connected via a
///     Lightning/USB-C adapter — iOS 17+ exposes these as an `.external`
///     AVCaptureDevice. We prefer one of these automatically when attached.
///
/// The controller picks the best available device and exposes zoom/torch/
/// focus controls plus a still-capture callback.
///
/// Session setup and control run on a private background queue, per Apple's
/// guidance not to block the main thread with `AVCaptureSession` work; all
/// `@Published` updates hop back to the main actor explicitly before touching
/// UI-observed state.
final class CameraController: NSObject, ObservableObject {
    @Published private(set) var isAuthorized = false
    @Published private(set) var isUsingExternalMicroscope = false
    @Published private(set) var isSessionRunning = false
    /// True when the fix is to change a Settings toggle, not just retry —
    /// used to show an "Open Settings" button instead of leaving a dead end.
    @Published private(set) var needsSettingsAccess = false
    @Published var minZoomFactor: CGFloat = 1.0
    @Published var maxZoomFactor: CGFloat = 1.0
    @Published var zoomFactor: CGFloat = 1.0 {
        didSet { applyZoom() }
    }
    @Published var isTorchOn = false {
        didSet { applyTorch() }
    }
    @Published var errorMessage: String?

    let session = AVCaptureSession()

    private let photoOutput = AVCapturePhotoOutput()
    private var currentDevice: AVCaptureDevice?
    private var photoCompletion: ((UIImage?) -> Void)?
    private let sessionQueue = DispatchQueue(label: "com.skinscope.session")

    override init() {
        super.init()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(deviceListDidChange),
            name: .AVCaptureDeviceWasConnected,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(deviceListDidChange),
            name: .AVCaptureDeviceWasDisconnected,
            object: nil
        )
    }

    func requestAccessAndStart() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            isAuthorized = true
            needsSettingsAccess = false
            configureAndStart()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                Task { @MainActor in
                    self?.isAuthorized = granted
                    if granted {
                        self?.needsSettingsAccess = false
                        self?.configureAndStart()
                    } else {
                        self?.needsSettingsAccess = true
                        self?.errorMessage = "Camera access is required to take skin photos."
                    }
                }
            }
        default:
            isAuthorized = false
            needsSettingsAccess = true
            errorMessage = "Camera access is disabled. Enable it in Settings to use SkinScope."
        }
    }

    @objc private func deviceListDidChange() {
        Task { @MainActor in
            guard isAuthorized else { return }
            configureAndStart()
        }
    }

    func stop() {
        sessionQueue.async { [session] in
            if session.isRunning { session.stopRunning() }
        }
    }

    /// Best available device: an attached external UVC microscope first,
    /// falling back to the closest-focusing built-in lens.
    private func preferredDevice() -> AVCaptureDevice? {
        var deviceTypes: [AVCaptureDevice.DeviceType] = [
            .builtInUltraWideCamera,
            .builtInWideAngleCamera
        ]
        if #available(iOS 17.0, *) {
            deviceTypes.insert(.external, at: 0)
        }

        let discovery = AVCaptureDevice.DiscoverySession(
            deviceTypes: deviceTypes,
            mediaType: .video,
            position: .unspecified
        )

        if #available(iOS 17.0, *), let external = discovery.devices.first(where: { $0.deviceType == .external }) {
            return external
        }
        // Prefer the back ultra-wide (focuses much closer, good for macro),
        // otherwise the standard back wide-angle camera.
        return discovery.devices.first(where: { $0.deviceType == .builtInUltraWideCamera && $0.position == .back })
            ?? discovery.devices.first(where: { $0.deviceType == .builtInWideAngleCamera && $0.position == .back })
            ?? discovery.devices.first
    }

    private func configureAndStart() {
        sessionQueue.async { [weak self] in
            guard let self else { return }
            guard let device = self.preferredDevice() else {
                Task { @MainActor in self.errorMessage = "No camera found." }
                return
            }

            self.session.beginConfiguration()
            self.session.sessionPreset = .photo

            for input in self.session.inputs { self.session.removeInput(input) }

            do {
                let input = try AVCaptureDeviceInput(device: device)
                if self.session.canAddInput(input) {
                    self.session.addInput(input)
                }
            } catch {
                self.session.commitConfiguration()
                Task { @MainActor in self.errorMessage = "Couldn't open camera: \(error.localizedDescription)" }
                return
            }

            if self.session.outputs.isEmpty, self.session.canAddOutput(self.photoOutput) {
                self.session.addOutput(self.photoOutput)
            }

            self.session.commitConfiguration()

            if !self.session.isRunning {
                self.session.startRunning()
            }

            self.currentDevice = device
            self.configureDeviceDefaults(device)

            Task { @MainActor in
                self.isUsingExternalMicroscope = {
                    if #available(iOS 17.0, *) { return device.deviceType == .external }
                    return false
                }()
                self.isSessionRunning = self.session.isRunning
                self.errorMessage = nil
            }
        }
    }

    private func configureDeviceDefaults(_ device: AVCaptureDevice) {
        do {
            try device.lockForConfiguration()
            if device.isFocusModeSupported(.continuousAutoFocus) {
                device.focusMode = .continuousAutoFocus
            }
            if device.isExposureModeSupported(.continuousAutoExposure) {
                device.exposureMode = .continuousAutoExposure
            }
            let minZoom = device.minAvailableVideoZoomFactor
            let maxZoom = min(device.maxAvailableVideoZoomFactor, 8.0)
            device.videoZoomFactor = minZoom
            device.unlockForConfiguration()

            Task { @MainActor in
                self.minZoomFactor = minZoom
                self.maxZoomFactor = maxZoom
                self.zoomFactor = minZoom
            }
        } catch {
            print("SkinScope: could not configure device defaults — \(error)")
        }
    }

    private func applyZoom() {
        guard let device = currentDevice else { return }
        sessionQueue.async {
            do {
                try device.lockForConfiguration()
                let clamped = max(device.minAvailableVideoZoomFactor, min(self.zoomFactor, device.maxAvailableVideoZoomFactor))
                device.videoZoomFactor = clamped
                device.unlockForConfiguration()
            } catch {
                print("SkinScope: zoom failed — \(error)")
            }
        }
    }

    private func applyTorch() {
        guard let device = currentDevice, device.hasTorch else { return }
        sessionQueue.async {
            do {
                try device.lockForConfiguration()
                device.torchMode = self.isTorchOn ? .on : .off
                device.unlockForConfiguration()
            } catch {
                print("SkinScope: torch failed — \(error)")
            }
        }
    }

    func capturePhoto(completion: @escaping (UIImage?) -> Void) {
        photoCompletion = completion
        let settings = AVCapturePhotoSettings()
        settings.flashMode = .off
        sessionQueue.async { [weak self] in
            guard let self else { return }
            // AVCapturePhotoOutput throws an uncatchable Objective-C exception
            // (not a Swift `Error`) if capturePhoto is called without a
            // running session and an active video connection — most visible
            // on the Simulator, where a virtual/passthrough camera can report
            // as available without actually delivering frames.
            guard self.session.isRunning, self.photoOutput.connection(with: .video)?.isActive == true else {
                Task { @MainActor in
                    self.photoCompletion?(nil)
                    self.photoCompletion = nil
                }
                return
            }
            self.photoOutput.capturePhoto(with: settings, delegate: self)
        }
    }
}

extension CameraController: AVCapturePhotoCaptureDelegate {
    func photoOutput(
        _ output: AVCapturePhotoOutput,
        didFinishProcessingPhoto photo: AVCapturePhoto,
        error: Error?
    ) {
        let image: UIImage?
        if let data = photo.fileDataRepresentation() {
            image = UIImage(data: data)
        } else {
            image = nil
        }
        Task { @MainActor in
            self.photoCompletion?(image)
            self.photoCompletion = nil
        }
    }
}
