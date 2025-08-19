import Foundation

struct Car: Identifiable, Codable, Equatable, Hashable {
    let id: String
    var brand: String
    var model: String
    var year: Int
    var price: String
    var imageURL: String
    var description: String
    var specifications: CarSpecifications
    var isActive: Bool
    let createdAt: Date
    var imageData: Data? // Для локального хранения изображений
    
    struct CarSpecifications: Codable, Equatable, Hashable {
        var engine: String
        var transmission: String
        var fuelType: String
        var bodyType: String
        var drivetrain: String
        var color: String
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Car, rhs: Car) -> Bool {
        lhs.id == rhs.id &&
        lhs.brand == rhs.brand &&
        lhs.model == rhs.model &&
        lhs.year == rhs.year &&
        lhs.price == rhs.price &&
        lhs.isActive == rhs.isActive
    }
}
