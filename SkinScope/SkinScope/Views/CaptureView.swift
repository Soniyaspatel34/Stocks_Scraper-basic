import SwiftUI
import UIKit

struct CaptureView: View {
    @EnvironmentObject private var store: ScanStore
    @StateObject private var camera = CameraController()

    @State private var selectedZone: FaceZone = .forehead
    @State private var note: String = ""
    @State private var showGrid = false
    @State private var capturedImage: UIImage?
    @State private var isSaving = false
    @State private var pendingReferencePhoto: UIImage?
    @State private var isCapturingReferencePhoto = false
    @State private var captureFailed = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ZStack {
                    if camera.isAuthorized {
                        CameraPreviewView(session: camera.session)
                            .overlay(showGrid ? AnyView(ReferenceGridOverlay()) : AnyView(EmptyView()))
                            .overlay(FaceZoneOverlay(selectedZone: $selectedZone))
                    } else {
                        ContentUnavailableCameraView(
                            message: camera.errorMessage,
                            showsSettingsButton: camera.needsSettingsAccess
                        )
                    }

                    VStack {
                        HStack {
                            if camera.isUsingExternalMicroscope {
                                Label("Microscope connected", systemImage: "cable.connector")
                                    .font(.caption.weight(.semibold))
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 6)
                                    .background(.green.opacity(0.85), in: Capsule())
                                    .foregroundStyle(.white)
                            }
                            Spacer()
                            Button {
                                showGrid.toggle()
                            } label: {
                                Image(systemName: showGrid ? "grid" : "grid.circle")
                                    .padding(10)
                                    .background(.black.opacity(0.4), in: Circle())
                                    .foregroundStyle(.white)
                            }
                            Button {
                                camera.isTorchOn.toggle()
                            } label: {
                                Image(systemName: camera.isTorchOn ? "bolt.fill" : "bolt.slash")
                                    .padding(10)
                                    .background(.black.opacity(0.4), in: Circle())
                                    .foregroundStyle(.white)
                            }
                        }
                        .padding()
                        Spacer()
                    }
                }
                .aspectRatio(3.0 / 4.0, contentMode: .fit)
                .background(Color.black)

                if camera.maxZoomFactor > camera.minZoomFactor {
                    HStack {
                        Image(systemName: "minus.magnifyingglass")
                        Slider(value: $camera.zoomFactor, in: camera.minZoomFactor...camera.maxZoomFactor)
                        Image(systemName: "plus.magnifyingglass")
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                }

                referencePhotoRow
                    .padding(.horizontal)
                    .padding(.top, 8)

                Form {
                    Section("Zone — tap the dot, on the diagram or the live view") {
                        FaceMapPickerView(selectedZone: $selectedZone)
                            .frame(height: 180)
                            .frame(maxWidth: .infinity)
                            .listRowInsets(EdgeInsets())
                            .padding(.vertical, 8)
                        Text(selectedZone.rawValue)
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                    Section("Note") {
                        TextField("e.g. new mole, itchy patch, follow-up", text: $note, axis: .vertical)
                            .lineLimit(2...4)
                    }
                }
                .frame(maxHeight: 320)

                Button {
                    capture()
                } label: {
                    Label(isSaving ? "Saving…" : "Capture", systemImage: "camera.macro")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                }
                .buttonStyle(.borderedProminent)
                .disabled(!camera.isAuthorized || isSaving)
                .padding()
            }
            .navigationTitle("SkinScope")
            .onAppear { camera.requestAccessAndStart() }
            .onDisappear { camera.stop() }
            .alert("Saved", isPresented: Binding(
                get: { capturedImage != nil && !isSaving },
                set: { _ in }
            )) {
                Button("OK") { capturedImage = nil }
            } message: {
                Text("Added to \(selectedZone.rawValue) in History.")
            }
            .alert("Couldn't capture photo", isPresented: $captureFailed) {
                Button("OK") {}
            } message: {
                Text("The camera wasn't ready — try again. On the Simulator, still-photo capture isn't fully supported even when the live preview works; a physical iPhone is needed to test this reliably.")
            }
        }
    }

    @ViewBuilder
    private var referencePhotoRow: some View {
        if let pendingReferencePhoto {
            HStack {
                Image(uiImage: pendingReferencePhoto)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 44, height: 44)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                Text("Reference photo added")
                    .font(.subheadline)
                Spacer()
                Button("Remove") { self.pendingReferencePhoto = nil }
                    .font(.subheadline)
            }
        } else {
            Button {
                captureReferencePhoto()
            } label: {
                Label(
                    isCapturingReferencePhoto ? "Capturing…" : "Add reference photo (before plugging in microscope)",
                    systemImage: "camera.on.rectangle"
                )
                .font(.subheadline)
            }
            .disabled(!camera.isAuthorized || isCapturingReferencePhoto)
        }
    }

    private func captureReferencePhoto() {
        isCapturingReferencePhoto = true
        camera.capturePhoto { image in
            isCapturingReferencePhoto = false
            pendingReferencePhoto = image
        }
    }

    private func capture() {
        isSaving = true
        camera.capturePhoto { image in
            defer { isSaving = false }
            guard let image else {
                captureFailed = true
                return
            }
            store.addScan(
                image: image,
                bodyLocation: selectedZone.rawValue,
                note: note,
                contextImage: pendingReferencePhoto,
                referenceWidthMM: nil
            )
            capturedImage = image
            note = ""
            pendingReferencePhoto = nil
        }
    }
}

/// A simple mm-scale grid to overlay on the live preview. Hold a ruler or the
/// microscope's built-in scale reticle against the grid lines to gauge size
/// consistently across repeat photos — this is a visual aid only, not a
/// calibrated measurement.
private struct ReferenceGridOverlay: View {
    var body: some View {
        GeometryReader { geo in
            let step = geo.size.width / 6
            Path { path in
                var x: CGFloat = 0
                while x <= geo.size.width {
                    path.move(to: CGPoint(x: x, y: 0))
                    path.addLine(to: CGPoint(x: x, y: geo.size.height))
                    x += step
                }
                var y: CGFloat = 0
                while y <= geo.size.height {
                    path.move(to: CGPoint(x: 0, y: y))
                    path.addLine(to: CGPoint(x: geo.size.width, y: y))
                    y += step
                }
            }
            .stroke(Color.yellow.opacity(0.45), lineWidth: 0.5)
        }
        .allowsHitTesting(false)
    }
}

private struct ContentUnavailableCameraView: View {
    let message: String?
    let showsSettingsButton: Bool

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "camera.macro.slash")
                .font(.system(size: 40))
            Text(message ?? "Requesting camera access…")
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            if showsSettingsButton {
                Button("Open Settings") {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
                .buttonStyle(.bordered)
                .tint(.white)
            }
        }
        .foregroundStyle(.white)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black)
    }
}

#Preview {
    CaptureView()
        .environmentObject(ScanStore())
}
