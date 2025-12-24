import SwiftUI
import SwiftUIComponents

// MARK: - View Builder

extension FeedView {
    // MARK: - Recommendations Section
    
    @ViewBuilder func makeRecommendationsSection() -> some View {
        VStack(alignment: .leading, spacing: 16) {
            makeRecommendationsHeader()
                .padding(.leading, 16)
            
            ZStack {
                RecommendationsView.Compact() {
                    router.route(fullScreen: .recommendations(namespace))
                }
                .padding(.horizontal, 16)
                .aspectRatio(1/0.8, contentMode: .fit)
            }
            .onTapGesture {
                router.route(fullScreen: .recommendations(namespace))
            }
        }
        .matchedTransitionSource(id: "recommendations", in: namespace)
        .padding(.vertical)
    }
    
    @ViewBuilder func makeRecommendationsHeader() -> some View {
        HStack {
            Text("Do you like it?")
                .font(.title2.weight(.semibold))
            
            Spacer()
        }
        .foregroundStyle(.primary)
    }
}

