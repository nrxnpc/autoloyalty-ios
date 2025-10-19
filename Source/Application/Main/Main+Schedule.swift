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
                    try Account.createGuestAccount(in: scope.coreDataContext)
                }
            }
        }
    }
}
