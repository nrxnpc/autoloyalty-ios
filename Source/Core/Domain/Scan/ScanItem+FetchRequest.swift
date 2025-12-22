import Foundation
import CoreData

extension ScanItem {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<ScanItem> {
        return NSFetchRequest<ScanItem>(entityName: "ScanItem")
    }
    
    public static func allScans() -> NSFetchRequest<ScanItem> {
        let request = fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \ScanItem.createdAt, ascending: false)]
        return request
    }
    
    public static func byExternalID(_ externalID: String) -> NSFetchRequest<ScanItem> {
        let request = NSFetchRequest<ScanItem>(entityName: "ScanItem")
        request.predicate = NSPredicate(format: "sync.externalID == %@", externalID)
        request.fetchLimit = 1
        request.sortDescriptors = [NSSortDescriptor(key: "sync.externalID", ascending: true)]
        return request
    }
}