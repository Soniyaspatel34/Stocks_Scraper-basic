import Foundation

/// A suggested product category (not a specific ASIN/listing) with the reason
/// it was suggested and a search query to hand off to Amazon.
struct ProductRecommendation: Identifiable {
    let id = UUID()
    let title: String
    let reason: String
    let searchQuery: String
}
