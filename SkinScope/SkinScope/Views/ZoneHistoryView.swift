import SwiftUI

/// All scans logged for one face zone, newest first, with a shortcut into
/// the compare view once there are at least two.
struct ZoneHistoryView: View {
    @EnvironmentObject private var store: ScanStore
    let zone: FaceZone

    private var records: [ScanRecord] { store.records(for: zone.rawValue) }

    var body: some View {
        Group {
            if records.isEmpty {
                ContentUnavailableView(
                    "No scans yet",
                    systemImage: "camera.macro",
                    description: Text("Capture a photo of your \(zone.rawValue.lowercased()) to start tracking it here.")
                )
            } else {
                List {
                    if records.count > 1 {
                        NavigationLink("Compare over time") {
                            CompareView(bodyLocation: zone.rawValue)
                        }
                    }
                    ForEach(records.reversed()) { record in
                        NavigationLink(value: record) {
                            row(for: record)
                        }
                    }
                }
            }
        }
        .navigationTitle(zone.rawValue)
    }

    private func row(for record: ScanRecord) -> some View {
        HStack {
            if let image = store.image(for: record) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 60, height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(record.date.formatted(date: .abbreviated, time: .shortened))
                if !record.note.isEmpty {
                    Text(record.note)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        ZoneHistoryView(zone: .forehead)
    }
    .environmentObject(ScanStore())
}
