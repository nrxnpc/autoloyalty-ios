import CoreData
import Foundation

extension Sweepstakes {
    /// Returns all sweepstakes sorted by start date (newest first)
    static func allSweepstakesFetchRequest() -> NSFetchRequest<Sweepstakes> {
        let request = NSFetchRequest<Sweepstakes>(entityName: "Sweepstakes")
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Sweepstakes.startDate, ascending: false)]
        return request
    }
    
    /// Returns active sweepstakes for current month, then upcoming (draft) for next month
    /// Sorted by: status (active first), then by start date (earliest first)
    static func activeSweepstakesFetchRequest() -> NSFetchRequest<Sweepstakes> {
        let now = Date()
        let calendar = Calendar.current
        
        // Current month range
        let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: now))!
        let endOfMonth = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: startOfMonth)!
        
        // Next month range
        let startOfNextMonth = calendar.date(byAdding: .month, value: 1, to: startOfMonth)!
        let endOfNextMonth = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: startOfNextMonth)!
        
        let request = NSFetchRequest<Sweepstakes>(entityName: "Sweepstakes")
        
        // Active sweepstakes in current month OR draft sweepstakes in next month
        request.predicate = NSPredicate(
            format: "(statusRaw == %d AND startDate >= %@ AND startDate <= %@ AND endDate > %@) OR (statusRaw == %d AND startDate >= %@ AND startDate <= %@)",
            Status.active.rawValue, startOfMonth as NSDate, endOfMonth as NSDate, now as NSDate,
            Status.draft.rawValue, startOfNextMonth as NSDate, endOfNextMonth as NSDate
        )
        
        // Sort: active first (descending status: 1=active, 0=draft), then by start date (earliest first)
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \Sweepstakes.statusRaw, ascending: false),
            NSSortDescriptor(keyPath: \Sweepstakes.startDate, ascending: true)
        ]
        
        return request
    }
    
    /// Returns upcoming (draft) sweepstakes that haven't started yet
    static func upcomingSweepstakesFetchRequest() -> NSFetchRequest<Sweepstakes> {
        let request = NSFetchRequest<Sweepstakes>(entityName: "Sweepstakes")
        request.predicate = NSPredicate(format: "statusRaw == %d AND startDate > %@", Status.draft.rawValue, Date() as NSDate)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Sweepstakes.startDate, ascending: true)]
        return request
    }
    
    /// Returns finished sweepstakes sorted by end date (most recent first)
    static func finishedSweepstakesFetchRequest() -> NSFetchRequest<Sweepstakes> {
        let request = NSFetchRequest<Sweepstakes>(entityName: "Sweepstakes")
        request.predicate = NSPredicate(format: "statusRaw == %d", Status.finished.rawValue)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Sweepstakes.endDate, ascending: false)]
        return request
    }
    
    /// Returns sweepstakes by internal ID
    static func by(id: String) -> NSFetchRequest<Sweepstakes> {
        let request = NSFetchRequest<Sweepstakes>(entityName: "Sweepstakes")
        request.predicate = NSPredicate(format: "id == %@", id)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Sweepstakes.title, ascending: true)]
        request.fetchLimit = 1
        return request
    }
    
    /// Returns sweepstakes by external ID (from server)
    static func byExternalID(_ externalID: String) -> NSFetchRequest<Sweepstakes> {
        let request = NSFetchRequest<Sweepstakes>(entityName: "Sweepstakes")
        request.predicate = NSPredicate(format: "sync.externalID == %@", externalID)
        request.fetchLimit = 1
        request.sortDescriptors = [NSSortDescriptor(key: "sync.externalID", ascending: true)]
        return request
    }
}
