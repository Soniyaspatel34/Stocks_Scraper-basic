import SwiftUI

struct RecommendationsView: View {
    @EnvironmentObject private var profileStore: SkinProfileStore
    @State private var showQuiz = false

    private var recommendations: [ProductRecommendation] {
        RecommendationEngine.recommendations(for: profileStore.profile)
    }

    var body: some View {
        NavigationStack {
            Group {
                if !profileStore.profile.isComplete {
                    ContentUnavailableView {
                        Label("Take the skin quiz", systemImage: "sparkles")
                    } description: {
                        Text("Answer a few quick questions about your skin type and concerns to get suggestions.")
                    } actions: {
                        Button("Start Quiz") { showQuiz = true }
                            .buttonStyle(.borderedProminent)
                    }
                } else {
                    List {
                        Section {
                            summaryRow
                        }
                        Section("Suggested for you") {
                            ForEach(recommendations) { item in
                                recommendationRow(item)
                            }
                        }
                        Section {
                            Text("As an Amazon Associate, this app may earn from qualifying purchases made through these links.")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .navigationTitle("Shop")
            .toolbar {
                if profileStore.profile.isComplete {
                    ToolbarItem(placement: .primaryAction) {
                        Button("Retake Quiz") { showQuiz = true }
                    }
                }
            }
            .sheet(isPresented: $showQuiz) {
                SkinQuizView(existing: profileStore.profile)
            }
        }
    }

    private var summaryRow: some View {
        VStack(alignment: .leading, spacing: 6) {
            if let type = profileStore.profile.skinType {
                Text("Skin type: \(type.displayName)")
                    .font(.headline)
            }
            if !profileStore.profile.concerns.isEmpty {
                Text(profileStore.profile.concerns.map(\.displayName).sorted().joined(separator: ", "))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private func recommendationRow(_ item: ProductRecommendation) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(item.title)
                .font(.headline)
            Text(item.reason)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            if let url = AmazonLinkBuilder.searchURL(query: item.searchQuery, associatesTag: profileStore.amazonAssociatesTag) {
                Link(destination: url) {
                    Label("Shop on Amazon", systemImage: "cart")
                        .font(.subheadline.weight(.semibold))
                }
                .padding(.top, 2)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    RecommendationsView()
        .environmentObject(SkinProfileStore())
}
