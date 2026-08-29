import Combine
import Foundation

/// Local-only storage for the skin quiz answers and the user's own Amazon
/// Associates tag. Both are small enough to live in UserDefaults.
@MainActor
final class SkinProfileStore: ObservableObject {
    @Published var profile: SkinProfile {
        didSet { saveProfile() }
    }
    @Published var amazonAssociatesTag: String {
        didSet { UserDefaults.standard.set(amazonAssociatesTag, forKey: Keys.associatesTag) }
    }

    private enum Keys {
        static let profile = "com.skinscope.skinProfile"
        static let associatesTag = "com.skinscope.amazonAssociatesTag"
    }

    init() {
        amazonAssociatesTag = UserDefaults.standard.string(forKey: Keys.associatesTag) ?? ""

        if let data = UserDefaults.standard.data(forKey: Keys.profile) {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            profile = (try? decoder.decode(SkinProfile.self, from: data)) ?? SkinProfile()
        } else {
            profile = SkinProfile()
        }
    }

    func updateProfile(skinType: SkinType, concerns: Set<SkinConcern>) {
        profile = SkinProfile(skinType: skinType, concerns: concerns, lastUpdated: Date())
    }

    private func saveProfile() {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        guard let data = try? encoder.encode(profile) else { return }
        UserDefaults.standard.set(data, forKey: Keys.profile)
    }
}
