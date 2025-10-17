import Foundation
import ScopeGraph

extension Main {
    internal func scheduleSessionJobs() async {
        scope.scheduleSessionJobs {
            
        }
    }
    
    internal func scheduleGuestSessionJobs() async {
        scope.scheduleSessionJobs {
            Job() { [scope] in
                try await scope.coreDataContext.perform {
                    let account = try Account.byID("guest").execute().first ?? Account.create(id: "guest", in: scope.coreDataContext)
                    account.nickname = "Demo Customer"
                    account.email = "customer@email.com"
                    if scope.coreDataContext.hasChanges {
                        try scope.coreDataContext.save()
                    }
                }
            }
        }
    }
}
