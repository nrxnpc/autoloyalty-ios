import Foundation

struct User: Identifiable, Codable, Equatable, Hashable {
    let id: String
    var name: String
    var email: String
    var phone: String
    let userType: UserType
    var points: Int
    var role: UserRole
    let registrationDate: Date
    var isActive: Bool
    var profileImageURL: String?
    var supplierID: String?
    var preferences: UserPreferences
    var statistics: UserStatistics
    var lastLoginDate: Date?
    
    enum UserType: String, CaseIterable, Codable {
        case individual = "individual"
        case business = "business"
        
        var displayName: String {
            switch self {
            case .individual: return "Физическое лицо"
            case .business: return "Юридическое лицо"
            }
        }
    }
    
    enum UserRole: String, CaseIterable, Codable {
        case customer = "customer"
        case supplier = "supplier"
        case platformAdmin = "platformAdmin"
        
        var displayName: String {
            switch self {
            case .customer: return "Пользователь"
            case .supplier: return "Поставщик"
            case .platformAdmin: return "Администратор платформы"
            }
        }
    }
    
    struct UserPreferences: Codable {
        var notificationsEnabled: Bool
        var emailNotifications: Bool
        var pushNotifications: Bool
        var preferredCategories: [ProductCategory]
        
        static let `default` = UserPreferences(
            notificationsEnabled: true,
            emailNotifications: true,
            pushNotifications: true,
            preferredCategories: []
        )
    }
    
    struct UserStatistics: Codable {
        var totalPurchases: Int
        var totalSpent: Double
        var averageOrderValue: Double
        var loyaltyTier: String
        var joinedPromotions: Int
        var createdContent: Int
        var totalPointsEarned: Int
        var lastActivityDate: Date
        
        static let `default` = UserStatistics(
            totalPurchases: 0,
            totalSpent: 0.0,
            averageOrderValue: 0.0,
            loyaltyTier: "Бронза",
            joinedPromotions: 0,
            createdContent: 0,
            totalPointsEarned: 0,
            lastActivityDate: Date()
        )
    }
    
    enum ProductCategory: String, CaseIterable, Codable {
        case autoparts = "autoparts"
        case oils = "oils"
        case tires = "tires"
        case accessories = "accessories"
        case tools = "tools"
        case electronics = "electronics"
        
        var displayName: String {
            switch self {
            case .autoparts: return "Автозапчасти"
            case .oils: return "Масла и жидкости"
            case .tires: return "Шины и диски"
            case .accessories: return "Аксессуары"
            case .tools: return "Инструменты"
            case .electronics: return "Электроника"
            }
        }
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: User, rhs: User) -> Bool {
        lhs.id == rhs.id &&
        lhs.points == rhs.points &&
        lhs.isActive == rhs.isActive &&
        lhs.name == rhs.name &&
        lhs.email == rhs.email
    }
}
