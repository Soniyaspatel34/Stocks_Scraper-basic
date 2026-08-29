import SwiftUI

struct SkinQuizView: View {
    @EnvironmentObject private var profileStore: SkinProfileStore
    @Environment(\.dismiss) private var dismiss

    @State private var skinType: SkinType
    @State private var concerns: Set<SkinConcern>

    init(existing profile: SkinProfile) {
        _skinType = State(initialValue: profile.skinType ?? .normal)
        _concerns = State(initialValue: profile.concerns)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("What's your skin type?") {
                    Picker("Skin type", selection: $skinType) {
                        ForEach(SkinType.allCases) { type in
                            Text(type.displayName).tag(type)
                        }
                    }
                    .pickerStyle(.inline)
                    .labelsHidden()
                }

                Section("Any specific concerns? (optional)") {
                    ForEach(SkinConcern.allCases) { concern in
                        Toggle(concern.displayName, isOn: Binding(
                            get: { concerns.contains(concern) },
                            set: { isOn in
                                if isOn { concerns.insert(concern) } else { concerns.remove(concern) }
                            }
                        ))
                    }
                }

                Section {
                    Text("This is a self-assessment, not a diagnosis. Recommendations are general skincare suggestions based on your answers.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Skin Quiz")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        profileStore.updateProfile(skinType: skinType, concerns: concerns)
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    SkinQuizView(existing: SkinProfile())
        .environmentObject(SkinProfileStore())
}
