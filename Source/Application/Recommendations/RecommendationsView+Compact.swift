import SwiftUI

extension RecommendationsView {
    struct Compact: View {
        @Environment(Main.Router.self) var router
        @Environment(Recommendations.self) var recommendations
        
        let recommendationSet: FetchedResults<CarRecommendation>
        
        @State var selectedCard: CarRecommendation?
        @State var popTrigger: CardSwipeDirection?
        
        var onSwipeEnd: (() -> Void)?
        
        init(recommendationSet: FetchedResults<CarRecommendation>, onSwipeEnd: @escaping (() -> Void)) {
            self.recommendationSet = recommendationSet
            self.onSwipeEnd = onSwipeEnd
        }
        
        var body: some View {
            @Bindable var recommendations = recommendations
            ZStack {
                FetchedCardSwipeView(fetchedResults: recommendationSet, selectedItem: $selectedCard, popTrigger: $popTrigger) { recommendation, progress, direction in
                    CarCardView(recommendation: recommendation, progress: progress, direction: direction, compact: true)
                }
                .configure(cardSpacing: 9)
                .onSwipeEnd { card, direction in
                    Task {
                        switch direction {
                        case .left:
                            try await recommendations.feedback(recommendation: card.id, sentiment: .reject)
                        case .right:
                            try await recommendations.feedback(recommendation: card.id, sentiment: .accept)
                        case .idle: break
                        }
                        
                        await MainActor.run {
                            onSwipeEnd?()
                        }
                    }
                }
                .onNoMoreCardsLeft {
                    // Cards finished
                }
            }
            .padding(.bottom, 16)
        }
    }
}
