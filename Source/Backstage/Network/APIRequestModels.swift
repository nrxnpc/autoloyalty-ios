import Foundation

// MARK: - Authentication Request Models

struct LoginRequest: Codable {
    let email: String
    let password: String
}

struct RefreshTokenRequest: Codable {
    let refreshToken: String
}

struct TokenResponse: Codable {
    let accessToken: String
    let refreshToken: String
    let expiresIn: Int
}

// MARK: - User Request Models

struct UpdateProfileRequest: Codable {
    let name: String
    let email: String
    let phone: String
    let preferences: UserPreferencesRequest?
}

struct UserPreferencesRequest: Codable {
    let notificationsEnabled: Bool
    let emailNotifications: Bool
    let pushNotifications: Bool
    let preferredCategories: [String]
}

// MARK: - Product Request Models

struct CreateProductRequest: Codable {
    let name: String
    let category: String
    let pointsCost: Int
    let imageURL: String
    let description: String
    let stockQuantity: Int
    let deliveryOptions: [String]
    let supplierId: String
}

struct UpdateProductRequest: Codable {
    let name: String?
    let pointsCost: Int?
    let description: String?
    let stockQuantity: Int?
    let isActive: Bool?
    let deliveryOptions: [String]?
}

// MARK: - QR Code Request Models

struct UploadQRScanRequest: Codable {
    let scan: QRScanResultRequest
    
    init(scan: QRScanResult) {
        self.scan = QRScanResultRequest(
            id: scan.id,
            pointsEarned: scan.pointsEarned,
            productName: scan.productName,
            productCategory: scan.productCategory,
            timestamp: scan.timestamp.ISO8601String,
            qrCode: scan.qrCode,
            location: scan.location
        )
    }
}

struct QRScanResultRequest: Codable {
    let id: String
    let pointsEarned: Int
    let productName: String
    let productCategory: String
    let timestamp: String
    let qrCode: String
    let location: String?
}

// MARK: - Transaction Request Models

struct CreateTransactionRequest: Codable {
    let userId: String
    let type: String
    let amount: Int
    let description: String
    let relatedId: String?
}

// MARK: - News Request Models

struct CreateNewsRequest: Codable {
    let title: String
    let content: String
    let imageURL: String
    let isImportant: Bool
    let tags: [String]
    let authorId: String
}

struct UpdateNewsRequest: Codable {
    let title: String?
    let content: String?
    let imageURL: String?
    let isImportant: Bool?
    let tags: [String]?
}

// MARK: - Car Request Models

struct CreateCarRequest: Codable {
    let brand: String
    let model: String
    let year: Int
    let price: String
    let imageURL: String
    let description: String
    let specifications: CarSpecificationsRequest
}

struct CarSpecificationsRequest: Codable {
    let engine: String
    let transmission: String
    let fuelType: String
    let bodyType: String
    let drivetrain: String
    let color: String
}

// MARK: - Order Request Models

struct CreateOrderRequest: Codable {
    let userId: String
    let productId: String
    let pointsSpent: Int
    let deliveryOption: String
    let deliveryAddress: String?
}

struct UpdateOrderStatusRequest: Codable {
    let status: String
}

// MARK: - Price Request Models

struct CreatePriceRequestRequest: Codable {
    let userId: String
    let carId: String
    let userMessage: String?
}

struct PriceRequestResponse: Codable {
    let dealerResponse: String
    let estimatedPrice: String?
}

// MARK: - Support Request Models

struct CreateSupportTicketRequest: Codable {
    let userId: String
    let subject: String
    let priority: String
    let initialMessage: String
}

struct CreateSupportMessageRequest: Codable {
    let content: String
    let senderId: String
    let senderRole: String
    let attachments: [String]
}

// MARK: - Lottery Request Models

struct LotteryParticipationRequest: Codable {
    let userId: String
}

// MARK: - Moderation Request Models

struct RejectProductRequest: Codable {
    let reason: String
}

// MARK: - Request Models Only
// Response models moved to RestEndpoint+Raw.swift