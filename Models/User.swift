import Foundation

struct User: Identifiable, Codable, Equatable, Hashable {
    let id: String
    var name: String
    var email: String
    var phone: String
    let userType: UserType
    var points: Int
    let role: UserRole
    let registrationDate: Date
    var isActive: Bool
    var profileImageURL: String?
    
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
        case user = "user"
        case admin = "admin"
        case operator_ = "operator"
        
        var displayName: String {
            switch self {
            case .user: return "Пользователь"
            case .admin: return "Администратор"
            case .operator_: return "Оператор"
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
