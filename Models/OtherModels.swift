import Foundation
import SwiftUI

// MARK: - QR Scan Result
struct QRScanResult: Identifiable, Codable, Equatable, Hashable {
    let id: String
    let pointsEarned: Int
    let productName: String
    let productCategory: String
    let timestamp: Date
    let qrCode: String
    let location: String?
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: QRScanResult, rhs: QRScanResult) -> Bool {
        lhs.id == rhs.id && lhs.timestamp == rhs.timestamp
    }
}

// MARK: - News Article
struct NewsArticle: Identifiable, Codable, Equatable, Hashable {
    let id: String
    var title: String
    var content: String
    var imageURL: String
    var isImportant: Bool
    let createdAt: Date
    var publishedAt: Date?
    var isPublished: Bool
    var status: NewsStatus
    let authorId: String
    var tags: [String]
    var imageData: Data?
    
    enum NewsStatus: String, CaseIterable, Codable {
        case draft = "draft"
        case pending = "pending"
        case approved = "approved"
        case rejected = "rejected"
        
        var displayName: String {
            switch self {
            case .draft: return "Черновик"
            case .pending: return "На модерации"
            case .approved: return "Опубликовано"
            case .rejected: return "Отклонено"
            }
        }
        
        var color: Color {
            switch self {
            case .draft: return .gray
            case .pending: return .orange
            case .approved: return .green
            case .rejected: return .red
            }
        }
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: NewsArticle, rhs: NewsArticle) -> Bool {
        lhs.id == rhs.id &&
        lhs.title == rhs.title &&
        lhs.isPublished == rhs.isPublished &&
        lhs.isImportant == rhs.isImportant
    }
}

// MARK: - Lottery
struct Lottery: Identifiable, Codable, Equatable, Hashable {
    let id: String
    var title: String
    var description: String
    var prize: String
    var startDate: Date
    var endDate: Date
    var isActive: Bool
    var participants: [String]
    var winnerId: String?
    var minPointsRequired: Int
    let createdAt: Date
    var imageData: Data? // Для изображения приза
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Lottery, rhs: Lottery) -> Bool {
        lhs.id == rhs.id &&
        lhs.isActive == rhs.isActive &&
        lhs.participants.count == rhs.participants.count
    }
}

// MARK: - Order
struct Order: Identifiable, Codable, Equatable, Hashable {
    let id: String
    let userId: String
    let product: Product
    let pointsSpent: Int
    var status: OrderStatus
    let createdAt: Date
    var deliveryAddress: String?
    var deliveryOption: Product.DeliveryOption
    var trackingNumber: String?
    
    enum OrderStatus: String, CaseIterable, Codable {
        case pending = "pending"
        case confirmed = "confirmed"
        case processing = "processing"
        case shipped = "shipped"
        case delivered = "delivered"
        case cancelled = "cancelled"
        
        var displayName: String {
            switch self {
            case .pending: return "Ожидает подтверждения"
            case .confirmed: return "Подтверждён"
            case .processing: return "В обработке"
            case .shipped: return "Отправлен"
            case .delivered: return "Доставлен"
            case .cancelled: return "Отменён"
            }
        }
        
        var color: Color {
            switch self {
            case .pending: return .orange
            case .confirmed: return .blue
            case .processing: return .purple
            case .shipped: return .cyan
            case .delivered: return .green
            case .cancelled: return .red
            }
        }
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Order, rhs: Order) -> Bool {
        lhs.id == rhs.id && lhs.status == rhs.status
    }
}

// MARK: - Price Request
struct PriceRequest: Identifiable, Codable, Equatable, Hashable {
    let id: String
    let userId: String
    let car: Car
    let userMessage: String?
    var status: PriceRequestStatus
    let createdAt: Date
    var dealerResponse: String?
    var estimatedPrice: String?
    var respondedAt: Date?
    
    enum PriceRequestStatus: String, CaseIterable, Codable {
        case pending = "pending"
        case responded = "responded"
        case expired = "expired"
        
        var displayName: String {
            switch self {
            case .pending: return "Ожидает ответа"
            case .responded: return "Получен ответ"
            case .expired: return "Истёк"
            }
        }
        
        var color: Color {
            switch self {
            case .pending: return .orange
            case .responded: return .green
            case .expired: return .gray
            }
        }
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: PriceRequest, rhs: PriceRequest) -> Bool {
        lhs.id == rhs.id && lhs.status == rhs.status
    }
}

// MARK: - Point Transaction
struct PointTransaction: Identifiable, Codable, Equatable, Hashable {
    let id: String
    let userId: String
    let type: TransactionType
    let amount: Int
    let description: String
    let timestamp: Date
    let relatedId: String?
    
    enum TransactionType: String, CaseIterable, Codable {
        case earned = "earned"
        case spent = "spent"
        case bonus = "bonus"
        case penalty = "penalty"
        
        var displayName: String {
            switch self {
            case .earned: return "Начислено"
            case .spent: return "Потрачено"
            case .bonus: return "Бонус"
            case .penalty: return "Списано"
            }
        }
        
        var color: Color {
            switch self {
            case .earned, .bonus: return .green
            case .spent, .penalty: return .red
            }
        }
        
        var sign: String {
            switch self {
            case .earned, .bonus: return "+"
            case .spent, .penalty: return "-"
            }
        }
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: PointTransaction, rhs: PointTransaction) -> Bool {
        lhs.id == rhs.id && lhs.timestamp == rhs.timestamp
    }
}

// MARK: - Support Ticket
struct SupportTicket: Identifiable, Codable, Equatable, Hashable {
    let id: String
    let userId: String
    var subject: String
    var messages: [SupportMessage]
    var status: TicketStatus
    let createdAt: Date
    var updatedAt: Date
    var priority: Priority
    
    enum TicketStatus: String, CaseIterable, Codable {
        case open = "open"
        case inProgress = "inProgress"
        case resolved = "resolved"
        case closed = "closed"
        
        var displayName: String {
            switch self {
            case .open: return "Открыт"
            case .inProgress: return "В работе"
            case .resolved: return "Решён"
            case .closed: return "Закрыт"
            }
        }
        
        var color: Color {
            switch self {
            case .open: return .red
            case .inProgress: return .orange
            case .resolved: return .green
            case .closed: return .gray
            }
        }
    }
    
    enum Priority: String, CaseIterable, Codable {
        case low = "low"
        case medium = "medium"
        case high = "high"
        case urgent = "urgent"
        
        var displayName: String {
            switch self {
            case .low: return "Низкий"
            case .medium: return "Средний"
            case .high: return "Высокий"
            case .urgent: return "Срочный"
            }
        }
        
        var color: Color {
            switch self {
            case .low: return .green
            case .medium: return .yellow
            case .high: return .orange
            case .urgent: return .red
            }
        }
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: SupportTicket, rhs: SupportTicket) -> Bool {
        lhs.id == rhs.id &&
        lhs.status == rhs.status &&
        lhs.messages.count == rhs.messages.count
    }
}

// MARK: - Support Message
struct SupportMessage: Identifiable, Codable, Equatable, Hashable {
    let id: String
    let content: String
    let senderId: String
    let senderRole: User.UserRole
    let timestamp: Date
    var attachments: [String]
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: SupportMessage, rhs: SupportMessage) -> Bool {
        lhs.id == rhs.id && lhs.timestamp == rhs.timestamp
    }
}
