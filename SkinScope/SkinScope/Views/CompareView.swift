import SwiftUI

/// Side-by-side comparison of two photos of the same body location, taken at
/// different times, to help notice change over time.
struct CompareView: View {
    @EnvironmentObject private var store: ScanStore
    let bodyLocation: String

    @State private var leftIndex = 0
    @State private var rightIndex = 1

    private var records: [ScanRecord] { store.records(for: bodyLocation) }

    var body: some View {
        VStack {
            if records.count < 2 {
                ContentUnavailableView(
                    "Need at least two photos",
                    systemImage: "photo.stack",
                    description: Text("Capture another photo of \(bodyLocation) to compare.")
                )
            } else {
                HStack(spacing: 8) {
                    sideView(index: $leftIndex)
                    sideView(index: $rightIndex)
                }
                .padding()
            }
        }
        .navigationTitle("Compare · \(bodyLocation)")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            leftIndex = max(0, records.count - 2)
            rightIndex = records.count - 1
        }
    }

    @ViewBuilder
    private func sideView(index: Binding<Int>) -> some View {
        VStack {
            Picker("Date", selection: index) {
                ForEach(records.indices, id: \.self) { i in
                    Text(records[i].date.formatted(date: .abbreviated, time: .omitted)).tag(i)
                }
            }
            .pickerStyle(.menu)

            if let image = store.image(for: records[index.wrappedValue]) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }

            if !records[index.wrappedValue].note.isEmpty {
                Text(records[index.wrappedValue].note)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

#Preview {
    NavigationStack {
        CompareView(bodyLocation: "Face")
    }
    .environmentObject(ScanStore())
}
