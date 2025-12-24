import Dependencies
import Foundation
import ScopeGraph

public struct RateRecommendationUseCase {
    @Dependency(\.scope) var scope
    
    public enum FeedbackSentiment : Sendable { case accept, reject }
    public func submitFeedback(recommendation id: String, sentiment: FeedbackSentiment) async throws {
        let context = scope.createBackgroundContext()
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

public struct ResetRecommendationsUseCase {
    @Dependency(\.scope) var scope
    
    public func execute() async throws {
        let context = scope.createBackgroundContext()
        try await context.perform {
            let recommendatons = try context.fetch(CarRecommendation.all())
            recommendatons.forEach { $0.sentimentScore = 0 }
            
            if context.hasChanges {
                try context.save()
            }
        }
    }
}
