import Foundation
import ScopeGraph

// MARK: - Schedules jobs to run during current user session

public extension Scope {
    func scheduleSessionJobs(@JobBuilder _ jobs: () -> [Job]) {
        let definedJobs = jobs()
        
        Task {
            let scheduler = await getOrCreateSessionScheduler()
            for job in definedJobs {
                await scheduler.run(job: job)
            }
        }
    }
    
    private func getOrCreateSessionScheduler() async -> JobSchedulerActor {
        if let existing = await session.getJobScheduler() as? JobSchedulerActor {
            return existing
        }
        
        let newScheduler = await JobSchedulerActor(sessionID: session.id)
        await session.setJobScheduler(newScheduler)
        return newScheduler
    }
    
    // TODO: handle stop jobs
}
