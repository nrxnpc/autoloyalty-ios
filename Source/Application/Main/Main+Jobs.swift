import Foundation
import ScopeGraph

extension Main {
    internal func scheduleSessionJobs() async {
        scope.scheduleSessionJobs {
            Job(.once) { [scope] in
                try await CreateWelcomeMessageUseCase(scope: scope).execute()
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
            
            // TODO:
            // Job(.polling(.strategy(.intensive))) { [scope] in
            //   try await PullNotificationsUseCase(scope: scope).execute()
            // }
            
            Job(.polling(.strategy(.normal))) { [scope] in
                try await FetchAttachmentsUseCase(scope: scope).execute()
            }
        }
    }
}
