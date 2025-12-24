import CoreData
import Foundation
import ScopeGraph

/// Use case for fetching attachment data from remote URLs
public struct FetchAttachmentsUseCase {
    private let scope: Scope
    
    public init(scope: Scope) {
        self.scope = scope
    }
    
    public func execute() async throws {
        let context = scope.createBackgroundContext()
        let request = Attachment.notLoaded()
        let attachments = try context.fetch(request)
        
        for attachment in attachments {
            guard let sourceURL = attachment.sourceURL else { continue }
            
            do {
                let (data, _) = try await URLSession.shared.data(from: sourceURL)
                attachment.raw = data
                attachment.sourceHash = attachment.calculateRawHash()
            } catch {
                print("Failed to fetch attachment from \(sourceURL): \(error)")
            }
        }
        
        try context.save()
    }
}
