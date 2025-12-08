import Foundation
import CoreData

/// Product delivery address domain entity with CoreData support
@objc(ProductDelivery)
public class ProductDelivery: Entity {
    @NSManaged public var fullAddress: String
    @NSManaged public var contactPhoneNumber: String
}
