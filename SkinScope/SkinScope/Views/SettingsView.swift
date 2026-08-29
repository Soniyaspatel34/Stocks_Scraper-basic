import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var store: ScanStore
    @State private var showDeleteAllConfirm = false

    var body: some View {
        NavigationStack {
            Form {
                Section("About SkinScope") {
                    Text(
                        "SkinScope helps you capture, organize, and compare close-up photos of your " +
                        "skin over time using a plug-in phone microscope or your camera's macro lens. " +
                        "It's a personal photo journal — it does not analyze, diagnose, or screen for " +
                        "any medical condition."
                    )
                    .font(.subheadline)
                }

                Section("Important") {
                    Label(
                        "This app is not a medical device and does not provide medical advice. " +
                        "If you notice a new, changing, or concerning spot, see a dermatologist or " +
                        "other qualified clinician.",
                        systemImage: "cross.case"
                    )
                    .font(.subheadline)
                }

                Section("Your data") {
                    Text("Photos and notes are stored only on this device. Nothing is uploaded.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Button("Delete all scans", role: .destructive) {
                        showDeleteAllConfirm = true
                    }
                    .disabled(store.records.isEmpty)
                }
            }
            .navigationTitle("About")
            .confirmationDialog(
                "Delete every saved photo and note? This can't be undone.",
                isPresented: $showDeleteAllConfirm,
                titleVisibility: .visible
            ) {
                Button("Delete Everything", role: .destructive) { store.deleteAll() }
                Button("Cancel", role: .cancel) {}
            }
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(ScanStore())
}
