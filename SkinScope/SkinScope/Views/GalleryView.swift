import SwiftUI

struct GalleryView: View {
    @EnvironmentObject private var store: ScanStore

    private let columns = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(FaceZone.allCases) { zone in
                        NavigationLink(value: zone) {
                            zoneCell(zone)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding()
            }
            .navigationTitle("History")
            .navigationDestination(for: FaceZone.self) { zone in
                ZoneHistoryView(zone: zone)
            }
            .navigationDestination(for: ScanRecord.self) { record in
                ScanDetailView(record: record)
            }
        }
    }

    @ViewBuilder
    private func zoneCell(_ zone: FaceZone) -> some View {
        VStack(spacing: 6) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(.gray.opacity(0.15))
                if let latest = store.records(for: zone.rawValue).last, let image = store.image(for: latest) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                } else {
                    Image(systemName: "camera.macro")
                        .foregroundStyle(.secondary)
                }
            }
            .aspectRatio(1, contentMode: .fit)
            .clipped()

            Text(zone.rawValue)
                .font(.caption)
                .foregroundStyle(.primary)
        }
    }
}

#Preview {
    GalleryView()
        .environmentObject(ScanStore())
}
