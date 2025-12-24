import Foundation
import ScopeGraph

public struct RateRecommendationUseCase {
    private let scope: Scope
    public init(scope: Scope) {
        self.scope = scope
    }
    
    public enum FeedbackSentiment : Sendable { case accept, reject }
    public func submitFeedback(recommendation id: String, sentiment: FeedbackSentiment) async throws {
        let context = scope.coreDataContext
        try await context.perform { [sentiment] in
            let recommendation = try context.fetch(CarRecommendation.byID(id))
            guard let recommendation = recommendation.first else {
                return
            }
            
            switch sentiment {
            case .accept: recommendation.sentimentScore = 1
            case .reject: recommendation.sentimentScore = -1
            }
            
            if context.hasChanges {
                try context.save()
            }
        }
    }
}
