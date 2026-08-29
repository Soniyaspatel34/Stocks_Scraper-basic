import Foundation

enum SkinType: String, CaseIterable, Identifiable, Codable, Hashable {
    case oily, dry, combination, normal, sensitive

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .oily: return "Oily"
        case .dry: return "Dry"
        case .combination: return "Combination"
        case .normal: return "Normal"
        case .sensitive: return "Sensitive"
        }
    }
}

enum SkinConcern: String, CaseIterable, Identifiable, Codable, Hashable {
    case acne, redness, dryness, oiliness, darkSpots, fineLines, largePores, dullness

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .acne: return "Acne / breakouts"
        case .redness: return "Redness"
        case .dryness: return "Dryness / flaking"
        case .oiliness: return "Excess oil / shine"
        case .darkSpots: return "Dark spots"
        case .fineLines: return "Fine lines"
        case .largePores: return "Large pores"
        case .dullness: return "Dullness"
        }
    }
}

/// The user's self-reported skin type and concerns, gathered from a short
/// quiz. Recommendations are based entirely on these answers — not on
/// automated analysis of any captured photo.
struct SkinProfile: Codable, Equatable {
    var skinType: SkinType?
    var concerns: Set<SkinConcern> = []
    var lastUpdated: Date?

    var isComplete: Bool { skinType != nil }
}
