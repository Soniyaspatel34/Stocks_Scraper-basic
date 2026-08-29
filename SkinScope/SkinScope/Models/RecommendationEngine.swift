import Foundation

/// Maps a self-reported skin profile to general skincare product categories.
///
/// This is a curated, static lookup table, not a diagnosis or a personalized
/// medical/cosmetic assessment — it's the same kind of "if oily + acne-prone,
/// try a salicylic acid cleanser" logic used by retail skincare quizzes.
enum RecommendationEngine {
    static func recommendations(for profile: SkinProfile) -> [ProductRecommendation] {
        guard let skinType = profile.skinType else { return [] }

        var seenTitles = Set<String>()
        var results: [ProductRecommendation] = []

        func add(_ items: [ProductRecommendation]) {
            for item in items where !seenTitles.contains(item.title) {
                seenTitles.insert(item.title)
                results.append(item)
            }
        }

        add(baseRecommendations[skinType] ?? [])
        for concern in SkinConcern.allCases where profile.concerns.contains(concern) {
            add(concernRecommendations[concern] ?? [])
        }

        return results
    }

    private static let baseRecommendations: [SkinType: [ProductRecommendation]] = [
        .oily: [
            ProductRecommendation(title: "Oil-free gel cleanser", reason: "A lightweight gel cleanser helps clear excess oil without over-stripping skin.", searchQuery: "oil-free gel facial cleanser"),
            ProductRecommendation(title: "Oil-free moisturizer", reason: "Oily skin still needs hydration — an oil-free, non-comedogenic formula won't add extra shine.", searchQuery: "oil-free non-comedogenic moisturizer"),
            ProductRecommendation(title: "Mattifying sunscreen SPF 30+", reason: "A broad-spectrum, oil-control sunscreen protects skin without a greasy finish.", searchQuery: "mattifying sunscreen spf 30 oil control")
        ],
        .dry: [
            ProductRecommendation(title: "Creamy hydrating cleanser", reason: "A non-foaming, creamy cleanser removes dirt without stripping natural oils.", searchQuery: "hydrating cream facial cleanser dry skin"),
            ProductRecommendation(title: "Ceramide moisturizer", reason: "Ceramides help rebuild the skin barrier and lock in moisture.", searchQuery: "ceramide moisturizer for dry skin"),
            ProductRecommendation(title: "Hydrating sunscreen SPF 30+", reason: "A moisturizing broad-spectrum sunscreen protects skin without leaving it feeling tight.", searchQuery: "hydrating sunscreen spf 30 dry skin")
        ],
        .combination: [
            ProductRecommendation(title: "Balancing gel-cream cleanser", reason: "A gentle, balanced cleanser works across both oily and dry zones.", searchQuery: "balancing gel cream cleanser combination skin"),
            ProductRecommendation(title: "Lightweight lotion moisturizer", reason: "A lotion texture hydrates dry areas without overwhelming oilier zones.", searchQuery: "lightweight lotion moisturizer combination skin"),
            ProductRecommendation(title: "Broad-spectrum sunscreen SPF 30+", reason: "Daily sun protection suited to combination skin.", searchQuery: "broad spectrum sunscreen spf 30 combination skin")
        ],
        .normal: [
            ProductRecommendation(title: "Gentle daily cleanser", reason: "A mild, pH-balanced cleanser for everyday maintenance.", searchQuery: "gentle daily facial cleanser"),
            ProductRecommendation(title: "Daily moisturizer", reason: "A standard daily moisturizer to maintain skin's hydration.", searchQuery: "daily face moisturizer"),
            ProductRecommendation(title: "Broad-spectrum sunscreen SPF 30+", reason: "Daily sun protection is the single most effective anti-aging step for any skin type.", searchQuery: "broad spectrum sunscreen spf 30")
        ],
        .sensitive: [
            ProductRecommendation(title: "Fragrance-free gentle cleanser", reason: "Fragrance-free formulas reduce the chance of irritation on sensitive skin.", searchQuery: "fragrance-free gentle facial cleanser sensitive skin"),
            ProductRecommendation(title: "Barrier repair moisturizer", reason: "A fragrance-free moisturizer formulated to support and calm a sensitive skin barrier.", searchQuery: "fragrance-free barrier repair moisturizer sensitive skin"),
            ProductRecommendation(title: "Mineral sunscreen SPF 30+", reason: "Mineral (zinc oxide/titanium dioxide) sunscreens tend to be better tolerated by sensitive skin than chemical filters.", searchQuery: "mineral sunscreen spf 30 sensitive skin zinc oxide")
        ]
    ]

    private static let concernRecommendations: [SkinConcern: [ProductRecommendation]] = [
        .acne: [
            ProductRecommendation(title: "Salicylic acid treatment", reason: "Salicylic acid (BHA) helps clear pores associated with breakouts.", searchQuery: "salicylic acid acne treatment"),
            ProductRecommendation(title: "Benzoyl peroxide spot treatment", reason: "A targeted spot treatment can help calm active breakouts.", searchQuery: "benzoyl peroxide spot treatment")
        ],
        .redness: [
            ProductRecommendation(title: "Niacinamide serum", reason: "Niacinamide is commonly used to help soothe visible redness.", searchQuery: "niacinamide serum for redness"),
            ProductRecommendation(title: "Centella (cica) calming cream", reason: "Cica-based products are widely used to help calm reactive, red-prone skin.", searchQuery: "centella asiatica cica calming cream")
        ],
        .dryness: [
            ProductRecommendation(title: "Hyaluronic acid serum", reason: "Hyaluronic acid helps draw and hold moisture in the skin.", searchQuery: "hyaluronic acid serum"),
            ProductRecommendation(title: "Overnight repair balm", reason: "A richer overnight balm gives dry patches extra time to recover.", searchQuery: "overnight repair balm dry skin")
        ],
        .oiliness: [
            ProductRecommendation(title: "Clay mask", reason: "A clay mask used a few times a week can help absorb excess surface oil.", searchQuery: "clay mask oil control"),
            ProductRecommendation(title: "Oil-absorbing blotting sheets", reason: "A quick, product-free way to manage midday shine.", searchQuery: "oil absorbing blotting sheets")
        ],
        .darkSpots: [
            ProductRecommendation(title: "Vitamin C serum", reason: "Vitamin C is commonly used to help brighten the look of dark spots over time.", searchQuery: "vitamin c brightening serum"),
            ProductRecommendation(title: "Niacinamide serum", reason: "Niacinamide is also used to help even out the look of skin tone.", searchQuery: "niacinamide serum for dark spots")
        ],
        .fineLines: [
            ProductRecommendation(title: "Retinol serum", reason: "Retinol is one of the most studied ingredients for the look of fine lines — start slowly and always pair with daily sunscreen.", searchQuery: "retinol anti-aging serum"),
            ProductRecommendation(title: "Peptide firming cream", reason: "Peptide-based creams are commonly used to support the look of skin firmness.", searchQuery: "peptide firming face cream")
        ],
        .largePores: [
            ProductRecommendation(title: "BHA pore-refining toner", reason: "A BHA toner can help keep pores clear of debris that makes them look larger.", searchQuery: "bha pore refining toner"),
            ProductRecommendation(title: "Niacinamide pore-minimizing serum", reason: "Niacinamide is also used to help the appearance of enlarged pores.", searchQuery: "niacinamide pore minimizing serum")
        ],
        .dullness: [
            ProductRecommendation(title: "Gentle AHA exfoliant", reason: "A mild AHA exfoliant helps remove built-up dead skin that can make skin look dull.", searchQuery: "gentle aha exfoliant face"),
            ProductRecommendation(title: "Vitamin C serum", reason: "Vitamin C is also commonly used to help brighten an uneven, dull complexion.", searchQuery: "vitamin c brightening serum")
        ]
    ]
}
