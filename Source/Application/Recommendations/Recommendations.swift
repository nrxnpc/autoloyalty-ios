import Dependencies
import Foundation
import SwiftUI
import CoreData

@Observable
@MainActor
final class Recommendations {
    @ObservationIgnored
    @Dependency(\.scope) var scope
    
    func removeCard(_ card: CarRecommendation) {
    
    }
    
    func reset() {
        // loadInitialBatch()
    }
}

extension Recommendations {
    func feedback(recommendation id: String, sentiment: RateRecommendationUseCase.FeedbackSentiment) {
        Task {
            let feedback = RateRecommendationUseCase(scope: scope)
            try await feedback.submitFeedback(recommendation: id, sentiment: sentiment)
        }
    }
}
