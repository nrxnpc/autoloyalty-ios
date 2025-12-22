import Foundation
import CoreData

/// Car recommendation domain entity with CoreData support
@objc(CarRecommendation)
public class CarRecommendation: Entity {
    @NSManaged public var brand: String
    @NSManaged public var model: String
    @NSManaged public var year: Int
    @NSManaged public var price: String
    @NSManaged public var imageURL: URL?
    @NSManaged public var carDescription: String
    @NSManaged public var isActive: Bool
    
    // MARK: - Specification
    
    @NSManaged public var engine: String
    @NSManaged public var transmission: String
    @NSManaged public var fuelType: String
    @NSManaged public var bodyType: String
    @NSManaged public var drivetrain: String
    @NSManaged public var color: String
}

extension CarRecommendation {
    static func createOrUpdate(from raw: RestEndpoint.Car, in context: NSManagedObjectContext) {
        let request = CarRecommendation.byExternalID(raw.id)
        if let existing = try? context.fetch(request).first {
            existing.brand = raw.brand
            existing.model = raw.model
            existing.year = raw.year
            existing.price = raw.price
            existing.carDescription = raw.description
            existing.isActive = raw.isActive
            existing.engine = raw.specifications.engine
            existing.transmission = raw.specifications.transmission
            existing.fuelType = raw.specifications.fuelType
            existing.bodyType = raw.specifications.bodyType
            existing.drivetrain = raw.specifications.drivetrain
            existing.color = raw.specifications.color
        } else {
            create(from: raw, in: context)
        }
    }
    
    private static func create(from raw: RestEndpoint.Car, in context: NSManagedObjectContext) {
        let recommendation = CarRecommendation(context: context)
        recommendation.sync.externalID = raw.id
        recommendation.brand = raw.brand
        recommendation.model = raw.model
        recommendation.year = raw.year
        recommendation.price = raw.price
        recommendation.carDescription = raw.description
        recommendation.isActive = raw.isActive
        recommendation.engine = raw.specifications.engine
        recommendation.transmission = raw.specifications.transmission
        recommendation.fuelType = raw.specifications.fuelType
        recommendation.bodyType = raw.specifications.bodyType
        recommendation.drivetrain = raw.specifications.drivetrain
        recommendation.color = raw.specifications.color
    }
}
