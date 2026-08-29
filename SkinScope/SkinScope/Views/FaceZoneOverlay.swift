import SwiftUI

/// Translucent position markers over the live camera preview, in the same
/// normalized layout as `FaceMapPickerView`, so the microscope can be lined
/// up in roughly the same spot each session. The highlighted dot marks the
/// zone currently selected for capture; tapping any dot re-selects it.
struct FaceZoneOverlay: View {
    @Binding var selectedZone: FaceZone

    var body: some View {
        GeometryReader { geo in
            ForEach(FaceZone.allCases) { zone in
                zoneDot(zone, in: geo.size)
            }
        }
    }

    private func zoneDot(_ zone: FaceZone, in size: CGSize) -> some View {
        let isSelected = zone == selectedZone
        let point = CGPoint(x: zone.position.x * size.width, y: zone.position.y * size.height)

        return Button {
            selectedZone = zone
        } label: {
            Circle()
                .fill(isSelected ? Color.brown.opacity(0.85) : Color.white.opacity(0.35))
                .frame(width: isSelected ? 44 : 32, height: isSelected ? 44 : 32)
                .overlay(Circle().stroke(.white, lineWidth: isSelected ? 2 : 1))
        }
        .position(point)
        .accessibilityLabel(zone.rawValue)
    }
}

#Preview {
    FaceZoneOverlay(selectedZone: .constant(.forehead))
        .background(Color.black)
}
