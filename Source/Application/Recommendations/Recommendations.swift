import Dependencies
import Foundation
import SwiftUI
import CoreData

@Observable
@MainActor
final class Recommendations {
    @ObservationIgnored
    @Dependency(\.scope) var scope
    
    var cards: [CarRecommendation] = []
    var selectedCard: CarRecommendation?
    var popTrigger: CardSwipeDirection?
    var isEmpty: Bool = false
    
    private var currentOffset = 0
    private let batchSize = 10
    private let loadThreshold = 3
    
    init() {
        loadInitialBatch()
    }
    
    private func loadInitialBatch() {
        currentOffset = 0
        cards.removeAll()
        loadNextBatch()
    }
    
    private func loadNextBatch() {
        let context = scope.coreDataContext
        
        let request = CarRecommendation.all()
        request.fetchLimit = batchSize
        request.fetchOffset = currentOffset
        
        do {
            let newCards = try context.fetch(request)
            cards.append(contentsOf: newCards)
            currentOffset += newCards.count
            isEmpty = cards.isEmpty
            
            if selectedCard == nil {
                selectedCard = cards.first
            }
        } catch {
            print("Failed to fetch recommendations: \(error)")
        }
    }
    
    func checkAndLoadMore() {
        if cards.count <= loadThreshold {
            loadNextBatch()
        }
    }
    
    func removeCard(_ card: CarRecommendation) {
        cards.removeAll { $0.id == card.id }
        selectedCard = cards.first
        checkAndLoadMore()
    }
    
    func reset() {
        loadInitialBatch()
    }
}
