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
                .aspectRatio(1/1.2, contentMode: .fit)
        }
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

