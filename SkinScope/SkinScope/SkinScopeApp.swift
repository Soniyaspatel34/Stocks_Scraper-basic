import SwiftUI

@main
struct SkinScopeApp: App {
    @StateObject private var store = ScanStore()
    @StateObject private var profileStore = SkinProfileStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
                .environmentObject(profileStore)
        }
    }
}
