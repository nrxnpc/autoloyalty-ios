import Dependencies
import Foundation
import SwiftUI
import CoreData

@Observable
@MainActor
final class Recommendations {
    @ObservationIgnored
    @Dependency(\.scope) var scope
    
    func reset(_ onCompletion: (() -> Void)? = nil) {
        Task {
            do {
                try await ResetRecommendationsUseCase().execute()
                await MainActor.run {
                    onCompletion?()
                }
            } catch {
                UINotificationFeedbackGenerator().notificationOccurred(.error)
            }
        }
     }
}

extension Recommendations {
    func feedback(recommendation id: String, sentiment: RateRecommendationUseCase.FeedbackSentiment) async throws {
        let feedback = RateRecommendationUseCase()
        try await feedback.submitFeedback(recommendation: id, sentiment: sentiment)
    }
}
