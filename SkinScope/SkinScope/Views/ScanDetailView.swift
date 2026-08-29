import SwiftUI

struct ScanDetailView: View {
    @EnvironmentObject private var store: ScanStore
    @Environment(\.dismiss) private var dismiss

    let record: ScanRecord
    @State private var note: String
    @State private var showDeleteConfirm = false

    init(record: ScanRecord) {
        self.record = record
        _note = State(initialValue: record.note)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if let image = store.image(for: record) {
                    ZoomableImageView(image: image)
                        .frame(height: 380)
                        .background(Color.black)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(record.bodyLocation)
                        .font(.title2.bold())
                    Text(record.date.formatted(date: .abbreviated, time: .shortened))
                        .foregroundStyle(.secondary)
                }

                if let contextImage = store.contextImage(for: record) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Reference photo").font(.headline)
                        Image(uiImage: contextImage)
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 220)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        Text("Taken with the normal camera before the microscope was plugged in, for context.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Note").font(.headline)
                    TextField("Add a note", text: $note, axis: .vertical)
                        .textFieldStyle(.roundedBorder)
                        .onSubmit { store.updateNote(for: record, note: note) }
                }

                if let image = store.image(for: record) {
                    ShareLink(item: Image(uiImage: image), preview: SharePreview("SkinScope photo", image: Image(uiImage: image))) {
                        Label("Share", systemImage: "square.and.arrow.up")
                    }
                }

                Button(role: .destructive) {
                    showDeleteConfirm = true
                } label: {
                    Label("Delete", systemImage: "trash")
                }
            }
            .padding()
        }
        .navigationTitle("Scan")
        .navigationBarTitleDisplayMode(.inline)
        .onDisappear { store.updateNote(for: record, note: note) }
        .confirmationDialog("Delete this photo?", isPresented: $showDeleteConfirm, titleVisibility: .visible) {
            Button("Delete", role: .destructive) {
                store.delete(record)
                dismiss()
            }
            Button("Cancel", role: .cancel) {}
        }
    }
}

/// Pinch-to-zoom wrapper so users can inspect fine detail in a captured photo.
struct ZoomableImageView: View {
    let image: UIImage
    @State private var scale: CGFloat = 1
    @State private var lastScale: CGFloat = 1

    var body: some View {
        Image(uiImage: image)
            .resizable()
            .scaledToFit()
            .scaleEffect(scale)
            .gesture(
                MagnificationGesture()
                    .onChanged { value in
                        scale = min(max(lastScale * value, 1), 8)
                    }
                    .onEnded { _ in
                        lastScale = scale
                    }
            )
            .onTapGesture(count: 2) {
                withAnimation {
                    scale = 1
                    lastScale = 1
                }
            }
            .clipped()
    }
}

#Preview {
    NavigationStack {
        ScanDetailView(record: ScanRecord(bodyLocation: "Face", imageFileName: "missing.jpg"))
    }
    .environmentObject(ScanStore())
}
