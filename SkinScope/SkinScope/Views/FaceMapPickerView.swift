import SwiftUI

/// A simplified face outline with tappable position markers for each
/// `FaceZone`, so a scan is logged against a consistent, fixed spot instead
/// of free text.
struct FaceMapPickerView: View {
    @Binding var selectedZone: FaceZone

    var body: some View {
        GeometryReader { geo in
            ZStack {
                FaceOutline()
                    .stroke(.secondary, lineWidth: 1.5)

                ForEach(FaceZone.allCases) { zone in
                    zoneDot(zone, in: geo.size)
                }
            }
        }
        .aspectRatio(0.8, contentMode: .fit)
    }

    private func zoneDot(_ zone: FaceZone, in size: CGSize) -> some View {
        let isSelected = zone == selectedZone
        let point = CGPoint(x: zone.position.x * size.width, y: zone.position.y * size.height)

        return Button {
            selectedZone = zone
        } label: {
            Circle()
                .fill(isSelected ? Color.accentColor : Color.accentColor.opacity(0.25))
                .frame(width: isSelected ? 26 : 18, height: isSelected ? 26 : 18)
        }
        .position(point)
        .accessibilityLabel(zone.rawValue)
    }
}

/// A rough face-outline silhouette, purely as a visual reference for where
/// the zone markers sit — not anatomically precise.
private struct FaceOutline: Shape {
    func path(in rect: CGRect) -> Path {
        Path(
            ellipseIn: CGRect(
                x: rect.width * 0.15,
                y: rect.height * 0.05,
                width: rect.width * 0.7,
                height: rect.height * 0.85
            )
        )
    }
}

#Preview {
    FaceMapPickerView(selectedZone: .constant(.forehead))
        .padding()
}
