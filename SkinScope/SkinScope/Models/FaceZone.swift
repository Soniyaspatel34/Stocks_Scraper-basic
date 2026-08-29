import CoreGraphics

/// The 12 face zones used for guided, repeatable capture positioning —
/// replaces free-text body-location tagging so the same spot can be found
/// again session after session.
enum FaceZone: String, CaseIterable, Identifiable, Codable, Hashable {
    case forehead = "Forehead"
    case leftTemple = "L. Temple"
    case rightTemple = "R. Temple"
    case leftUnderEye = "L. Under-eye"
    case rightUnderEye = "R. Under-eye"
    case nose = "Nose"
    case leftCheek = "L. Cheek"
    case rightCheek = "R. Cheek"
    case upperLip = "Upper lip"
    case leftJawline = "L. Jawline"
    case rightJawline = "R. Jawline"
    case chin = "Chin"

    var id: String { rawValue }

    /// Normalized (0–1, 0–1) position on a face diagram / camera overlay,
    /// (0,0) top-left, (1,1) bottom-right. A rough visual guide for landing
    /// the microscope in the same spot each time — not derived from real-time
    /// face detection, so treat it as approximate.
    var position: CGPoint {
        switch self {
        case .forehead: return CGPoint(x: 0.50, y: 0.18)
        case .leftTemple: return CGPoint(x: 0.72, y: 0.30)
        case .rightTemple: return CGPoint(x: 0.28, y: 0.30)
        case .leftUnderEye: return CGPoint(x: 0.63, y: 0.44)
        case .rightUnderEye: return CGPoint(x: 0.37, y: 0.44)
        case .nose: return CGPoint(x: 0.50, y: 0.50)
        case .leftCheek: return CGPoint(x: 0.70, y: 0.58)
        case .rightCheek: return CGPoint(x: 0.30, y: 0.58)
        case .upperLip: return CGPoint(x: 0.50, y: 0.68)
        case .leftJawline: return CGPoint(x: 0.68, y: 0.76)
        case .rightJawline: return CGPoint(x: 0.32, y: 0.76)
        case .chin: return CGPoint(x: 0.50, y: 0.85)
        }
    }
}
