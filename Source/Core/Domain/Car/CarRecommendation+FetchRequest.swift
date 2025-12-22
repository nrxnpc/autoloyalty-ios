import Foundation
import CoreData

extension CarRecommendation {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<CarRecommendation> {
        return NSFetchRequest<CarRecommendation>(entityName: "CarRecommendation")
    }
    
    public static func all() -> NSFetchRequest<CarRecommendation> {
        let request = fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \CarRecommendation.createdAt, ascending: false)]
        return request
    }
    
    public static func byID(_ id: String) -> NSFetchRequest<CarRecommendation> {
        let request = NSFetchRequest<CarRecommendation>(entityName: "CarRecommendation")
        request.fetchLimit = 1
        request.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
        return request
    }
    
    public static func byExternalID(_ externalID: String) -> NSFetchRequest<CarRecommendation> {
        let request = NSFetchRequest<CarRecommendation>(entityName: "CarRecommendation")
        request.predicate = NSPredicate(format: "sync.externalID == %@", externalID)
        request.fetchLimit = 1
        request.sortDescriptors = [NSSortDescriptor(key: "sync.externalID", ascending: true)]
        return request
    }
}
