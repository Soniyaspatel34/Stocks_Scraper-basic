import SwiftUI

struct CaptureView: View {
    @EnvironmentObject private var store: ScanStore
    @StateObject private var camera = CameraController()

    @State private var bodyLocation: String = BodyLocationPreset.face.rawValue
    @State private var customLocation: String = ""
    @State private var note: String = ""
    @State private var showGrid = true
    @State private var capturedImage: UIImage?
    @State private var isSaving = false

    private var resolvedBodyLocation: String {
        bodyLocation == BodyLocationPreset.other.rawValue
            ? (customLocation.isEmpty ? "Other" : customLocation)
            : bodyLocation
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ZStack {
                    if camera.isAuthorized {
                        CameraPreviewView(session: camera.session)
                            .overlay(showGrid ? AnyView(ReferenceGridOverlay()) : AnyView(EmptyView()))
                    } else {
                        ContentUnavailableCameraView(message: camera.errorMessage)
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

                Form {
                    Section("Body location") {
                        Picker("Location", selection: $bodyLocation) {
                            ForEach(BodyLocationPreset.allCases) { preset in
                                Text(preset.rawValue).tag(preset.rawValue)
                            }
                        }
                        if bodyLocation == BodyLocationPreset.other.rawValue {
                            TextField("Custom location", text: $customLocation)
                        }
                    }
                    Section("Note") {
                        TextField("e.g. new mole, itchy patch, follow-up", text: $note, axis: .vertical)
                            .lineLimit(2...4)
                    }
                }
                .frame(maxHeight: 220)

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
                Text("Added to \(resolvedBodyLocation) in History.")
            }
        }
    }

    private func capture() {
        isSaving = true
        camera.capturePhoto { image in
            defer { isSaving = false }
            guard let image else { return }
            store.addScan(image: image, bodyLocation: resolvedBodyLocation, note: note, referenceWidthMM: nil)
            capturedImage = image
            note = ""
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

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "camera.macro.slash")
                .font(.system(size: 40))
            Text(message ?? "Requesting camera access…")
                .multilineTextAlignment(.center)
                .padding(.horizontal)
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
