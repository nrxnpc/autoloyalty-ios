import Foundation
import SwiftUI

struct Product: Identifiable, Codable, Equatable, Hashable {
    let id: String
    var name: String
    var category: ProductCategory
    var pointsCost: Int
    var imageURL: String
    var description: String
    var stockQuantity: Int
    var isActive: Bool
    let createdAt: Date
    var deliveryOptions: [DeliveryOption]
    var imageData: Data? // Для локального хранения изображений
    
    enum ProductCategory: String, CaseIterable, Codable {
        case merchandise = "merchandise"
        case discounts = "discounts"
        case accessories = "accessories"
        case services = "services"
        
        var displayName: String {
            switch self {
            case .merchandise: return "Мерч"
            case .discounts: return "Скидки"
            case .accessories: return "Аксессуары"
            case .services: return "Услуги"
            }
        }
        
        var iconName: String {
            switch self {
            case .merchandise: return "tshirt"
            case .discounts: return "percent"
            case .accessories: return "key"
            case .services: return "wrench.and.screwdriver"
            }
        }
    }
    
    enum DeliveryOption: String, CaseIterable, Codable {
        case pickup = "pickup"
        case delivery = "delivery"
        case digital = "digital"
        
        var displayName: String {
            switch self {
            case .pickup: return "Самовывоз"
            case .delivery: return "Доставка"
            case .digital: return "Цифровая доставка"
            }
        }
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Product, rhs: Product) -> Bool {
        lhs.id == rhs.id &&
        lhs.pointsCost == rhs.pointsCost &&
        lhs.stockQuantity == rhs.stockQuantity &&
        lhs.isActive == rhs.isActive &&
        lhs.name == rhs.name
    }
}
