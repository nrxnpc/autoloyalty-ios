import CoreData
import Foundation

extension Sweepstakes {
    static func allSweepstakesFetchRequest() -> NSFetchRequest<Sweepstakes> {
        let request = NSFetchRequest<Sweepstakes>(entityName: "Sweepstakes")
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Sweepstakes.startDate, ascending: false)]
        return request
    }
    
    static func obsoleteSweepstakes(excludingIDs externalIDs: Set<String>) -> NSFetchRequest<Sweepstakes> {
        let request = NSFetchRequest<Sweepstakes>(entityName: "Sweepstakes")
        request.predicate = NSPredicate(format: "NOT (sync.externalID IN %@)", externalIDs)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Sweepstakes.startDate, ascending: false)]
        return request
    }
    
    static func activeSweepstakesFetchRequest() -> NSFetchRequest<Sweepstakes> {
        let request = NSFetchRequest<Sweepstakes>(entityName: "Sweepstakes")
        request.predicate = NSPredicate(format: "statusRaw == %d AND endDate > %@", Status.active.rawValue, Date() as NSDate)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Sweepstakes.endDate, ascending: true)]
        return request
    }
    
    static func upcomingSweepstakesFetchRequest() -> NSFetchRequest<Sweepstakes> {
        let request = NSFetchRequest<Sweepstakes>(entityName: "Sweepstakes")
        request.predicate = NSPredicate(format: "statusRaw == %d AND startDate > %@", Status.draft.rawValue, Date() as NSDate)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Sweepstakes.startDate, ascending: true)]
        return request
    }
    
    static func finishedSweepstakesFetchRequest() -> NSFetchRequest<Sweepstakes> {
        let request = NSFetchRequest<Sweepstakes>(entityName: "Sweepstakes")
        request.predicate = NSPredicate(format: "statusRaw == %d", Status.finished.rawValue)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Sweepstakes.endDate, ascending: false)]
        return request
    }
    
    public static func allDrafts() -> NSFetchRequest<Sweepstakes> {
        let request = NSFetchRequest<Sweepstakes>(entityName: "Sweepstakes")
        request.predicate = NSPredicate(format: "sync.isDraft == YES")
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Sweepstakes.createdAt, ascending: false)]
        return request
    }
    
    static func by(id: String) -> NSFetchRequest<Sweepstakes> {
        let request = NSFetchRequest<Sweepstakes>(entityName: "Sweepstakes")
        request.predicate = NSPredicate(format: "id == %@", id)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Sweepstakes.title, ascending: true)]
        request.fetchLimit = 1
        return request
    }
    
    static func byExternalID(_ externalID: String) -> NSFetchRequest<Sweepstakes> {
        let request = NSFetchRequest<Sweepstakes>(entityName: "Sweepstakes")
        request.predicate = NSPredicate(format: "sync.externalID == %@", externalID)
        request.fetchLimit = 1
        request.sortDescriptors = [NSSortDescriptor(key: "sync.externalID", ascending: true)]
        return request
    }
}
