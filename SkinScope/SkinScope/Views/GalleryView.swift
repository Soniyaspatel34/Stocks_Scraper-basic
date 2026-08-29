import SwiftUI

struct GalleryView: View {
    @EnvironmentObject private var store: ScanStore

    private let columns = [GridItem(.adaptive(minimum: 100), spacing: 8)]

    var body: some View {
        NavigationStack {
            Group {
                if store.records.isEmpty {
                    ContentUnavailableView(
                        "No scans yet",
                        systemImage: "photo.stack",
                        description: Text("Photos you capture will show up here, grouped by body location.")
                    )
                } else {
                    List {
                        ForEach(store.distinctBodyLocations, id: \.self) { location in
                            Section {
                                ScrollView(.horizontal, showsIndicators: false) {
                                    LazyHGrid(rows: [GridItem(.fixed(100))], spacing: 8) {
                                        ForEach(store.records(for: location)) { record in
                                            NavigationLink(value: record) {
                                                thumbnail(for: record)
                                            }
                                        }
                                    }
                                }
                            } header: {
                                HStack {
                                    Text(location)
                                    Spacer()
                                    if store.records(for: location).count > 1 {
                                        NavigationLink("Compare") {
                                            CompareView(bodyLocation: location)
                                        }
                                        .font(.caption)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("History")
            .navigationDestination(for: ScanRecord.self) { record in
                ScanDetailView(record: record)
            }
        }
    }

    @ViewBuilder
    private func thumbnail(for record: ScanRecord) -> some View {
        if let image = store.image(for: record) {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .frame(width: 100, height: 100)
                .clipShape(RoundedRectangle(cornerRadius: 10))
        } else {
            RoundedRectangle(cornerRadius: 10)
                .fill(.gray.opacity(0.2))
                .frame(width: 100, height: 100)
        }
    }
}

#Preview {
    GalleryView()
        .environmentObject(ScanStore())
}
