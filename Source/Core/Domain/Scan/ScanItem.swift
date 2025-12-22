import Foundation
import CoreData

/// Order domain entity with CoreData support
@objc(ScanItem)
public class ScanItem: Entity {
    @NSManaged public var productName: String
    @NSManaged public var productCategory: String
    @NSManaged public var pointsEarned: Int
}

extension ScanItem {
    static func createOrUpdate(from raw: RestEndpoint.UserScan, in context: NSManagedObjectContext) {
        let request = ScanItem.byExternalID(raw.id)
        if let existing = try? context.fetch(request).first {
            existing.productName = raw.productName
            existing.productCategory = raw.productCategory
            existing.pointsEarned = raw.pointsEarned
            if let date = ISO8601DateFormatter().date(from: raw.timestamp ?? "") {
                existing.createdAt = date
            }
        } else {
            create(from: raw, in: context)
        }
    }
    
    private static func create(from raw: RestEndpoint.UserScan, in context: NSManagedObjectContext) {
        let scanItem = ScanItem(context: context)
        scanItem.sync.externalID = raw.id
        scanItem.productName = raw.productName
        scanItem.productCategory = raw.productCategory
        scanItem.pointsEarned = raw.pointsEarned
        if let date = ISO8601DateFormatter().date(from: raw.timestamp ?? "") {
            scanItem.createdAt = date
        }
    }
}
