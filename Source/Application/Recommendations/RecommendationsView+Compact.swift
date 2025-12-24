import SwiftUI

extension RecommendationsView {
    struct Compact: View {
        @Environment(Main.Router.self) var router
        @Environment(Recommendations.self) var recommendations
        @FetchRequest var recommendationSet: FetchedResults<CarRecommendation>
        
        @State var selectedCard: CarRecommendation?
        @State var popTrigger: CardSwipeDirection?
        
        var onSwipeEnd: (() -> Void)?
        
        init(onSwipeEnd: @escaping (() -> Void)) {
            self.onSwipeEnd = onSwipeEnd
            _recommendationSet = FetchRequest(fetchRequest: CarRecommendation.allNeutralSentiment(), animation: .smooth)
        }
        
        var body: some View {
            @Bindable var recommendations = recommendations
            ZStack {
                FetchedCardSwipeView(fetchedResults: recommendationSet, selectedItem: $selectedCard, popTrigger: $popTrigger) { recommendation, progress, direction in
                    CarCardView(recommendation: recommendation, progress: progress, direction: direction, compact: true)
                }
                .configure(cardSpacing: 9)
                .onSwipeEnd { card, direction in
                    switch direction {
                    case .left: recommendations.feedback(recommendation: card.id, sentiment: .reject)
                    case .right: recommendations.feedback(recommendation: card.id, sentiment: .accept)
                    case .idle: break
                    }
                    onSwipeEnd?()
                }
                .onNoMoreCardsLeft {
                    // Cards finished
                }
            }
            .padding(.bottom, 16)
        }
    }
}
