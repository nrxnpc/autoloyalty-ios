import Dependencies
import Foundation
import SwiftUI
import CoreData

@Observable
@MainActor
final class Recommendations {
    @ObservationIgnored
    @Dependency(\.scope) var scope
    
    func reset() {
        Task {
            do {
                try await ResetRecommendationsUseCase(scope: scope).execute()
            } catch {
                UINotificationFeedbackGenerator().notificationOccurred(.error)
            }
        }
    }
}

extension Recommendations {
    func feedback(recommendation id: String, sentiment: RateRecommendationUseCase.FeedbackSentiment) async throws {
        let feedback = RateRecommendationUseCase(scope: scope)
        try await feedback.submitFeedback(recommendation: id, sentiment: sentiment)
    }
}
