import Foundation

// MARK: - Job Scheduling Types

/// Pre-defined polling strategies that adapt to device battery status
public enum PollingStrategy: Sendable {
    case uncommon, low, normal, intensive
    
    /// Actual time duration for strategy, adjusted for battery level
    public func duration(for batteryStatus: BatteryMonitor.BatteryStatus) -> Duration {
        switch self {
        case .uncommon:
            switch batteryStatus {
            case .normal:   return .seconds(600) // 10 min
            case .low:      return .seconds(900) // 15 min
            case .critical: return .seconds(1800) // 30 min
            }
            
        case .low:
            switch batteryStatus {
            case .normal:   return .seconds(300) // 5 min
            case .low:      return .seconds(600) // 10 min
            case .critical: return .seconds(900) // 15 min
            }

        case .normal:
            switch batteryStatus {
            case .normal:   return .seconds(60) // 1 min
            case .low:      return .seconds(180) // 3 min
            case .critical: return .seconds(300) // 5 min
            }

        case .intensive:
            switch batteryStatus {
            case .normal:   return .seconds(30) // 30 sec
            case .low:      return .seconds(60) // 1 min
            case .critical: return .seconds(180) // 3 min
            }
        }
    }
}

/// Polling interval definition
public enum PollingInterval: Sendable {
    case direct(Duration)
    case strategy(PollingStrategy)
    
    /// Resolves polling interval to concrete Duration
    public func duration(using batteryComponent: BatteryMonitor) -> Duration {
        switch self {
        case .direct(let duration):
            return duration
        case .strategy(let strategy):
            let batteryStatus = batteryComponent.status()
            return strategy.duration(for: batteryStatus)
        }
    }
}

/// Job execution schedule
public enum Schedule: Sendable {
    case once
    case polling(PollingInterval)
}

/// Declarative representation of schedulable work unit
public struct Job: Sendable {
    public let schedule: Schedule
    public let execution: @Sendable () async throws -> Void

    public init(_ schedule: Schedule = .once, execution: @escaping @Sendable () async throws -> Void) {
        self.schedule = schedule
        self.execution = execution
    }
}

/// Result builder for job collections
@resultBuilder
public enum JobBuilder {
    public static func buildBlock(_ components: Job...) -> [Job] {
        components
    }
}

/// Actor-based job scheduler with battery-aware execution
public actor JobSchedulerActor: SessionJobScheduling {
    public let sessionID: String
    private var runningTasks: [Task<Void, Never>] = []
    private let battery: BatteryMonitor
    
    public init(sessionID: String) {
        self.sessionID = sessionID
        self.battery = BatteryMonitor()
    }
    
    /// Execute job according to its schedule
    public func run(job: Job) async {
        let task = Task {
            await self.execute(job: job)
        }
        runningTasks.append(task)
    }
    
    /// Stop all running jobs
    public func stopAllJobs() async {
        runningTasks.forEach { $0.cancel() }
        runningTasks.removeAll()
    }
    
    // MARK: - SessionJobScheduling Protocol
    
    public func startJobs() async {
        // Jobs start when run() is called
    }
    
    public func stopJobs() async {
        await stopAllJobs()
    }
    
    // MARK: - Private Implementation
    
    private func execute(job: Job) async {
        switch job.schedule {
        case .once:
            await executeOnce(job.execution)
        case .polling(let pollingInterval):
            await executePolling(interval: pollingInterval, job.execution)
        }
    }
    
    private func executeOnce(_ execution: @Sendable () async throws -> Void) async {
        do {
            try await execution()
        } catch {
            debugPrint("[JOB][ERROR] Once job failed: \(error)")
        }
    }
    
    private func executePolling(interval: PollingInterval, _ execution: @Sendable () async throws -> Void) async {
        while !Task.isCancelled {
            do {
                try await execution()
            } catch {
                debugPrint("[JOB][ERROR] Polling job failed: \(error)")
            }
            
            let sleepDuration = interval.duration(using: battery)
            try? await Task.sleep(for: sleepDuration)
        }
    }
}