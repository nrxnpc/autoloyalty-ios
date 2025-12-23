import SwiftUI
import SwiftUIComponents

// MARK: - View Builder

extension FeedView {
    // MARK: - Recommendations Section
    
    @ViewBuilder func makeRecommendationsSection() -> some View {
        VStack(alignment: .leading, spacing: 16) {
            makeRecommendationsHeader()
            
            RoundedRectangle(cornerRadius: 16)
                .foregroundStyle(.ultraThinMaterial)
                .aspectRatio(1/1.1, contentMode: .fit)
                .onTap {
                    router.route(fullScreen: .recommendations(namespace))
                }
        }
        .matchedTransitionSource(id: "recommendations", in: namespace)
        .padding()
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

