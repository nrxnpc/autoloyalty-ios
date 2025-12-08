import Foundation
import CoreData

/// Product domain entity with CoreData support
@objc(Product)
public class Product: Entity {
    @NSManaged public var name: String
    @NSManaged public var productDescription: String
    @NSManaged public var pointsCost: Int
    @NSManaged public var isOutOfStock: Bool
    @NSManaged public var isFavorite: Bool
    @NSManaged public var images: Set<Attachment>
}
