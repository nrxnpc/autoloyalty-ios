import Foundation
import CoreData
import ScopeGraph

public struct MarkFaforiteUseCase {
    private let scope: Scope
    public init(scope: Scope) {
        self.scope = scope
    }
    
    public func setFavotite(_ isFavorite: Bool, objectID: NSManagedObjectID) async throws {
        let context = scope.createBackgroundContext()
        try await context.perform {
            let product = try context.existingObject(with: objectID)
            product.setValue(isFavorite, forKey: "isFavorite")
            
            if context.hasChanges {
                try context.save()
            }
        }
    }
}
