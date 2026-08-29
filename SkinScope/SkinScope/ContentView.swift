import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            CaptureView()
                .tabItem {
                    Label("Scan", systemImage: "camera.macro")
                }

            GalleryView()
                .tabItem {
                    Label("History", systemImage: "photo.stack")
                }

            SettingsView()
                .tabItem {
                    Label("About", systemImage: "info.circle")
                }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(ScanStore())
}
