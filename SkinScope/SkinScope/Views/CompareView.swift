import SwiftUI

/// Side-by-side comparison of two photos of the same body location, taken at
/// different times, to help notice change over time.
struct CompareView: View {
    @EnvironmentObject private var store: ScanStore
    let bodyLocation: String

    @State private var leftIndex = 0
    @State private var rightIndex = 1

    private var records: [ScanRecord] { store.records(for: bodyLocation) }

    private var leftMetrics: ImageMetrics? {
        metrics(at: leftIndex)
    }

    private var rightMetrics: ImageMetrics? {
        metrics(at: rightIndex)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                if records.count < 2 {
                    ContentUnavailableView(
                        "Need at least two photos",
                        systemImage: "photo.stack",
                        description: Text("Capture another photo of \(bodyLocation) to compare.")
                    )
                } else {
                    HStack(alignment: .top, spacing: 8) {
                        sideView(index: $leftIndex, metrics: leftMetrics)
                        sideView(index: $rightIndex, metrics: rightMetrics)
                    }

                    if let left = leftMetrics, let right = rightMetrics {
                        deltaCard(left: left, right: right)
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Compare · \(bodyLocation)")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            leftIndex = max(0, records.count - 2)
            rightIndex = records.count - 1
        }
    }

    private func metrics(at index: Int) -> ImageMetrics? {
        guard records.indices.contains(index), let image = store.image(for: records[index]) else { return nil }
        return ImageAnalyzer.metrics(for: image)
    }

    @ViewBuilder
    private func sideView(index: Binding<Int>, metrics: ImageMetrics?) -> some View {
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

            if let metrics {
                VStack(spacing: 2) {
                    Text("Brightness \(Int(metrics.brightness * 100))%")
                    Text("Redness \(Int(metrics.redness * 100))%")
                }
                .font(.caption2)
                .foregroundStyle(.secondary)
            }

            if !records[index.wrappedValue].note.isEmpty {
                Text(records[index.wrappedValue].note)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private func deltaCard(left: ImageMetrics, right: ImageMetrics) -> some View {
        VStack(spacing: 6) {
            Text(deltaText("Brightness", left.brightness, right.brightness))
            Text(deltaText("Redness", left.redness, right.redness))
            Text(
                "Rough whole-photo pixel averages only — lighting, angle, and distance change " +
                "these numbers more than actual skin does. Not a measurement of skin condition."
            )
            .font(.caption2)
            .foregroundStyle(.tertiary)
            .multilineTextAlignment(.center)
            .padding(.top, 4)
        }
        .font(.footnote.weight(.medium))
        .padding()
        .frame(maxWidth: .infinity)
        .background(.quaternary, in: RoundedRectangle(cornerRadius: 10))
    }

    private func deltaText(_ label: String, _ left: Double, _ right: Double) -> String {
        let delta = (right - left) * 100
        let sign = delta >= 0 ? "+" : ""
        return "\(label): \(sign)\(String(format: "%.0f", delta))% (left → right)"
    }
}

#Preview {
    NavigationStack {
        CompareView(bodyLocation: "Face")
    }
    .environmentObject(ScanStore())
}
