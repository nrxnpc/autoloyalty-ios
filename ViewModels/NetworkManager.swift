import Foundation
import Combine

// MARK: - Network Error
enum NetworkError: Error, LocalizedError {
    case invalidURL
    case noData
    case decodingError
    case networkUnavailable
    case serverError(Int)
    case timeout
    case unauthorized
    
    var errorDescription: String? {
        switch self {
        case .invalidURL: return "Неверный URL"
        case .noData: return "Нет данных"
        case .decodingError: return "Ошибка декодирования"
        case .networkUnavailable: return "Сеть недоступна"
        case .serverError(let code): return "Ошибка сервера: \(code)"
        case .timeout: return "Превышено время ожидания"
        case .unauthorized: return "Необходима авторизация"
        }
    }
}

// MARK: - Date Extensions
extension Date {
    var ISO8601String: String {
        return ISO8601DateFormatter().string(from: self)
    }
}

extension Optional where Wrapped == Date {
    var ISO8601String: String? {
        return self?.ISO8601String
    }
}

// MARK: - API Models
struct APIUser: Codable {
    let id: String
    let name: String
    let email: String
    let phone: String
    let userType: String
    let points: Int
    let role: String
    let registrationDate: String
    let isActive: Bool
    
    func toUser() -> User {
        return User(
            id: id,
            name: name,
            email: email,
            phone: phone,
            userType: User.UserType(rawValue: userType) ?? .individual,
            points: points,
            role: User.UserRole(rawValue: role) ?? .user,
            registrationDate: ISO8601DateFormatter().date(from: registrationDate) ?? Date(),
            isActive: isActive
        )
    }
}

struct APIProduct: Codable {
    let id: String
    let name: String
    let category: String
    let pointsCost: Int
    let imageURL: String
    let description: String
    let stockQuantity: Int
    let isActive: Bool
    let createdAt: String
    let deliveryOptions: [String]
    
    func toProduct() -> Product {
        let categoryEnum = Product.ProductCategory(rawValue: category) ?? .merchandise
        let deliveryEnum = deliveryOptions.compactMap { Product.DeliveryOption(rawValue: $0) }
        
        return Product(
            id: id,
            name: name,
            category: categoryEnum,
            pointsCost: pointsCost,
            imageURL: imageURL,
            description: description,
            stockQuantity: stockQuantity,
            isActive: isActive,
            createdAt: ISO8601DateFormatter().date(from: createdAt) ?? Date(),
            deliveryOptions: deliveryEnum,
            imageData: nil
        )
    }
}

struct APINewsArticle: Codable {
    let id: String
    let title: String
    let content: String
    let imageURL: String
    let isImportant: Bool
    let createdAt: String
    let publishedAt: String?
    let isPublished: Bool
    let authorId: String
    let tags: [String]
    
    func toNewsArticle() -> NewsArticle {
        let publishedDate = publishedAt.flatMap { ISO8601DateFormatter().date(from: $0) }
        
        return NewsArticle(
            id: id,
            title: title,
            content: content,
            imageURL: imageURL,
            isImportant: isImportant,
            createdAt: ISO8601DateFormatter().date(from: createdAt) ?? Date(),
            publishedAt: publishedDate,
            isPublished: isPublished,
            authorId: authorId,
            tags: tags,
            imageData: nil
        )
    }
}

struct APIQRScan: Codable {
    let id: String
    let pointsEarned: Int
    let productName: String
    let productCategory: String
    let timestamp: String
    let qrCode: String
    let location: String?
    
    func toQRScanResult() -> QRScanResult {
        return QRScanResult(
            id: id,
            pointsEarned: pointsEarned,
            productName: productName,
            productCategory: productCategory,
            timestamp: ISO8601DateFormatter().date(from: timestamp) ?? Date(),
            qrCode: qrCode,
            location: location
        )
    }
}

struct APIPointTransaction: Codable {
    let id: String
    let userId: String
    let type: String
    let amount: Int
    let description: String
    let timestamp: String
    let relatedId: String?
    
    func toPointTransaction() -> PointTransaction {
        let typeEnum = PointTransaction.TransactionType(rawValue: type) ?? .earned
        
        return PointTransaction(
            id: id,
            userId: userId,
            type: typeEnum,
            amount: amount,
            description: description,
            timestamp: ISO8601DateFormatter().date(from: timestamp) ?? Date(),
            relatedId: relatedId
        )
    }
}

// MARK: - Request/Response Models
struct QRScanRequest: Codable {
    let qrCode: String
    let userId: String
    let timestamp: String
    let location: String?
}

struct QRScanResponse: Codable {
    let success: Bool
    let scan: APIQRScan?
    let error: String?
}

struct UserRegistration: Codable {
    let name: String
    let email: String
    let phone: String
    let password: String
    let userType: String
}

// MARK: - Network Manager
@MainActor
class NetworkManager: ObservableObject {
    static let shared = NetworkManager()
    
    @Published var isConnected = true
    @Published var isLoading = false
    
    private init() {}
    
    // MARK: - Authentication Methods
    func login(email: String, password: String) async throws -> APIUser {
        isLoading = true
        defer { isLoading = false }
        
        try await Task.sleep(nanoseconds: 1_000_000_000)
        
        if email == "admin@nsp.com" {
            return APIUser(
                id: "admin-1",
                name: "Администратор",
                email: email,
                phone: "+7 (999) 123-45-67",
                userType: "business",
                points: 5000,
                role: "admin",
                registrationDate: ISO8601DateFormatter().string(from: Date()),
                isActive: true
            )
        } else {
            return APIUser(
                id: UUID().uuidString,
                name: "Демо пользователь",
                email: email,
                phone: "+7 (999) 876-54-32",
                userType: "individual",
                points: 1250,
                role: "user",
                registrationDate: ISO8601DateFormatter().string(from: Date()),
                isActive: true
            )
        }
    }
    
    func register(userData: UserRegistration) async throws -> APIUser {
        isLoading = true
        defer { isLoading = false }
        
        try await Task.sleep(nanoseconds: 1_000_000_000)
        
        return APIUser(
            id: UUID().uuidString,
            name: userData.name,
            email: userData.email,
            phone: userData.phone,
            userType: userData.userType,
            points: 100,
            role: "user",
            registrationDate: ISO8601DateFormatter().string(from: Date()),
            isActive: true
        )
    }
    
    // MARK: - Data Fetching Methods
    func getProducts() async throws -> [APIProduct] {
        isLoading = true
        defer { isLoading = false }
        
        try await Task.sleep(nanoseconds: 500_000_000)
        
        let demoProducts = DemoDataLoader.loadProducts()
        return demoProducts.map { product in
            APIProduct(
                id: product.id,
                name: product.name,
                category: product.category.rawValue,
                pointsCost: product.pointsCost,
                imageURL: product.imageURL,
                description: product.description,
                stockQuantity: product.stockQuantity,
                isActive: product.isActive,
                createdAt: ISO8601DateFormatter().string(from: product.createdAt),
                deliveryOptions: product.deliveryOptions.map { $0.rawValue }
            )
        }
    }
    
    func getNews() async throws -> [APINewsArticle] {
        isLoading = true
        defer { isLoading = false }
        
        try await Task.sleep(nanoseconds: 500_000_000)
        
        let demoNews = DemoDataLoader.loadNews()
        return demoNews.map { article in
            APINewsArticle(
                id: article.id,
                title: article.title,
                content: article.content,
                imageURL: article.imageURL,
                isImportant: article.isImportant,
                createdAt: ISO8601DateFormatter().string(from: article.createdAt),
                publishedAt: article.publishedAt?.ISO8601String,
                isPublished: article.isPublished,
                authorId: article.authorId,
                tags: article.tags
            )
        }
    }
    
    func getUserScans(userId: String) async throws -> [APIQRScan] {
        isLoading = true
        defer { isLoading = false }
        
        try await Task.sleep(nanoseconds: 300_000_000)
        
        let demoScans = DemoDataLoader.loadQRScans()
        return demoScans.map { scan in
            APIQRScan(
                id: scan.id,
                pointsEarned: scan.pointsEarned,
                productName: scan.productName,
                productCategory: scan.productCategory,
                timestamp: ISO8601DateFormatter().string(from: scan.timestamp),
                qrCode: scan.qrCode,
                location: scan.location
            )
        }
    }
    
    func getUserTransactions(userId: String) async throws -> [APIPointTransaction] {
        isLoading = true
        defer { isLoading = false }
        
        try await Task.sleep(nanoseconds: 300_000_000)
        
        let demoTransactions = DemoDataLoader.loadPointTransactions()
        return demoTransactions.map { transaction in
            APIPointTransaction(
                id: transaction.id,
                userId: transaction.userId,
                type: transaction.type.rawValue,
                amount: transaction.amount,
                description: transaction.description,
                timestamp: ISO8601DateFormatter().string(from: transaction.timestamp),
                relatedId: transaction.relatedId
            )
        }
    }
    
    func scanQRCode(request: QRScanRequest) async throws -> QRScanResponse {
        isLoading = true
        defer { isLoading = false }
        
        try await Task.sleep(nanoseconds: 1_000_000_000)
        
        let pointsEarned = Int.random(in: 10...100)
        let productNames = ["Тормозные колодки Brembo", "Масляный фильтр Mann", "Свечи зажигания NGK", "Амортизаторы Bilstein", "Воздушный фильтр K&N"]
        let categories = ["Тормозная система", "Система смазки", "Система зажигания", "Подвеска", "Система впуска"]
        
        let randomIndex = Int.random(in: 0..<productNames.count)
        
        let scan = APIQRScan(
            id: UUID().uuidString,
            pointsEarned: pointsEarned,
            productName: productNames[randomIndex],
            productCategory: categories[randomIndex],
            timestamp: request.timestamp,
            qrCode: request.qrCode,
            location: request.location
        )
        
        return QRScanResponse(success: true, scan: scan, error: nil)
    }
    
    // MARK: - Other Methods
    var connectionsStatusText: String {
        if isConnected {
            if let lastSync = UserDefaults.standard.lastSyncDate {
                return "Онлайн • Синхронизировано \(lastSync.timeAgoDisplay())"
            } else {
                return "Онлайн • Готов к синхронизации"
            }
        } else {
            return "Оффлайн"
        }
    }
    
    func syncUserData(userId: String) async throws {
        try await Task.sleep(nanoseconds: 500_000_000)
    }
    
    func uploadQRScan(_ scan: QRScanResult) async throws {
        try await Task.sleep(nanoseconds: 200_000_000)
    }
}

// MARK: - Token Manager
class TokenManager: ObservableObject {
    static let shared = TokenManager()
    
    @Published var isAuthenticated = false
    
    private init() {}
    
    func saveToken(_ token: String) {
        isAuthenticated = true
    }
    
    func getToken() -> String? {
        return nil
    }
    
    func clearToken() {
        isAuthenticated = false
    }
}
