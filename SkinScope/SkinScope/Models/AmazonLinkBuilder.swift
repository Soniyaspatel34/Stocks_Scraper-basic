import Foundation

/// Builds an Amazon search URL carrying an Associates tag, so purchases made
/// after tapping through can be credited to the app owner's affiliate account.
///
/// This intentionally does not use the Product Advertising API — that needs
/// approved Associates credentials this app doesn't have. A tagged search
/// link works immediately with just an Associates tag ID and opens directly
/// in Safari/the Amazon app.
enum AmazonLinkBuilder {
    static func searchURL(query: String, associatesTag: String?) -> URL? {
        var components = URLComponents(string: "https://www.amazon.com/s")
        var items = [URLQueryItem(name: "k", value: query)]

        if let tag = associatesTag?.trimmingCharacters(in: .whitespacesAndNewlines), !tag.isEmpty {
            items.append(URLQueryItem(name: "tag", value: tag))
        }

        components?.queryItems = items
        return components?.url
    }
}
