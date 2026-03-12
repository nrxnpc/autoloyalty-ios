import Foundation
import ScopeGraph

extension Main {
    internal func scheduleSessionJobs() async {
        scope.scheduleSessionJobs {
            Job(.once) { [scope] in
                try await CreateWelcomeMessageUseCase(scope: scope).execute()
                
                // TODO: For Demo only
                try await CreateBuiltInRecommendationsSetUseCase(scope: scope).execute()
                try await CreateBuiltInCatalogUseCase(scope: scope).execute()
                try await CreateBuiltInSweepstakesSetUseCase(scope: scope).execute()
            }
            
            Job(.polling(.strategy(.normal))) { [scope] in
                do {
                    try await PullAboutMeUseCase(scope: scope).execute()
                } catch {
                    debugPrint("[DEBUG] Cannot pull uset info: \(error)")
                }
                
                do {
                    try await PullUserTransactionsUseCase(scope: scope).execute()
                } catch {
                    debugPrint("[DEBUG] Cannot pull user transactions: \(error)")
                }
                
                do {
                    try await PullScanHistoryUseCase(scope: scope).execute()
                } catch {
                    debugPrint("[DEBUG] Cannot pull scan history: \(error)")
                }
            }
            
            Job(.polling(.strategy(.intensive))) { [weak router] in
                do {
                    try await PullSupportMessagesUseCase(router: router).execute()
                } catch {
                    debugPrint("[DEBUG] Cannot pull messages: \(error)")
                }
                
                do {
                    try await PushSupportMessagesUseCase().execute()
                } catch {
                    debugPrint("[DEBUG] Cannot push messages: \(error)")
                }
            }
            
            Job(.polling(.strategy(.normal))) { [scope] in
                do {
                    try await PullMyOrdersUseCase(scope: scope).execute()
                } catch {
                    debugPrint("[DEBUG] Cannot pull user transactions: \(error)")
                }
            }
            
            Job(.polling(.strategy(.low))) { [scope] in
                // TODO: For Test Only
                // do {
                //     try await PullCatalogUseCase(scope: scope).execute()
                // } catch {
                //     debugPrint("[DEBUG] Cannot pull catalog: \(error)")
                // }
                
                do {
                    try await PullNewsUseCase(scope: scope).execute()
                } catch {
                    debugPrint("[DEBUG] Cannot pull news transactions: \(error)")
                }
                
                // TODO: For Test Only
                // do {
                //     try await PullRecommendationsUseCase(scope: scope).execute()
                // } catch {
                //     debugPrint("[DEBUG] Cannot pull catalog: \(error)")
                // }
            }
        }
    }
    
    internal func scheduleGuestSessionJobs() async {
        scope.scheduleSessionJobs {
            Job(.once) { [scope] in
                try await CreateWelcomeMessageUseCase(scope: scope).execute()
            }
            
            Job { [scope] in
                try await scope.coreDataContext.perform {
                    try Account.createGuestAccount(in: scope.coreDataContext)
                }
                
                try await Task.sleep(for: .seconds(5))
                try await Product.fillInDemo(context: scope.coreDataContext)
            }
            
            Job(.polling(.strategy(.normal))) { [scope] in
                try await FetchAttachmentsUseCase(scope: scope).execute()
            }
        }
    }
}
