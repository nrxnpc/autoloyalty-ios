import Foundation
import CoreData

/// Sweepstakes domain entity with CoreData support
@objc(Sweepstakes)
public class Sweepstakes: Entity {
    @NSManaged public var title: String
    @NSManaged public var promoDescription: String
    @NSManaged public var startDate: Date
    @NSManaged public var endDate: Date
    @NSManaged public var statusRaw: Int16
    @NSManaged public var entryConditionRaw: Int16
    @NSManaged public var requiredValue: Int
    @NSManaged public var images: Set<Attachment>
    @NSManaged public var prizes: Set<Product>
    @NSManaged public var entries: Set<SweepstakesEntry>
}

/// Sweepstakes entry domain entity representing user participation
@objc(SweepstakesEntry)
public class SweepstakesEntry: Entity {
    @NSManaged public var entryDate: Date
    @NSManaged public var isWinner: Bool
    @NSManaged public var account: Account
    @NSManaged public var sweepstakes: Sweepstakes
    @NSManaged public var wonProduct: Product?
}

// MARK: - Status

extension Sweepstakes {
    /// Sweepstakes status enumeration
    public enum Status: Int16, CaseIterable {
        case draft = 0
        case active = 1
        case finished = 2
    }
    
    public var status: Status {
        get { Status(rawValue: statusRaw) ?? .draft }
        set { statusRaw = newValue.rawValue }
    }
}

// MARK: - Entry Condition

extension Sweepstakes {
    /// Entry condition type enumeration
    public enum EntryCondition: Int16, CaseIterable {
        case free = 0
        case minScans = 1
        case minPoints = 2
    }
    
    public var entryCondition: EntryCondition {
        get { EntryCondition(rawValue: entryConditionRaw) ?? .free }
        set { entryConditionRaw = newValue.rawValue }
    }
}

// MARK: - Create/Update

extension Sweepstakes {
    static func createOrUpdate(from raw: RestEndpoint.Sweepstake, in context: NSManagedObjectContext) {
        let request = Sweepstakes.byExternalID(raw.id)
        if let existing = try? context.fetch(request).first {
            existing.title = raw.title
            existing.promoDescription = raw.description
            existing.status = Status(rawValue: Int16(raw.status)) ?? .draft
            existing.entryCondition = EntryCondition(rawValue: Int16(raw.entryConditionType)) ?? .free
            existing.requiredValue = raw.requiredValue
            if let imageURL = URL(string: raw.imageURL) {
                existing.images = [.fromURL(imageURL, in: context)]
            }
            if let startDate = ISO8601DateFormatter().date(from: raw.startDate) {
                existing.startDate = startDate
            }
            if let endDate = ISO8601DateFormatter().date(from: raw.endDate) {
                existing.endDate = endDate
            }
        } else {
            create(from: raw, in: context)
        }
    }
    
    private static func create(from raw: RestEndpoint.Sweepstake, in context: NSManagedObjectContext) {
        let sweepstakes = Sweepstakes(context: context)
        sweepstakes.sync.externalID = raw.id
        sweepstakes.title = raw.title
        sweepstakes.promoDescription = raw.description
        sweepstakes.status = Status(rawValue: Int16(raw.status)) ?? .draft
        sweepstakes.entryCondition = EntryCondition(rawValue: Int16(raw.entryConditionType)) ?? .free
        sweepstakes.requiredValue = raw.requiredValue
        if let imageURL = URL(string: raw.imageURL) {
            sweepstakes.images = [.fromURL(imageURL, in: context)]
        }
        sweepstakes.startDate = ISO8601DateFormatter().date(from: raw.startDate) ?? .now
        sweepstakes.endDate = ISO8601DateFormatter().date(from: raw.endDate) ?? .now
    }
}
