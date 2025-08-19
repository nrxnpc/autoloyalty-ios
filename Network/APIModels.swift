import Foundation

// MARK: - API Product Model
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

// MARK: - API News Article Model
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

// MARK: - API QR Scan Model
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

// MARK: - API Point Transaction Model
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

// MARK: - API QR Scan Request
struct QRScanRequest: Codable {
    let qrCode: String
    let userId: String
    let timestamp: String
    let location: String?
}

// MARK: - API QR Scan Response
struct QRScanResponse: Codable {
    let success: Bool
    let scan: APIQRScan?
    let error: String?
}

// MARK: - API Response Wrapper
struct APIResponse<T: Codable>: Codable {
    let success: Bool
    let data: T?
    let error: String?
    let message: String?
}

// MARK: - API List Response
struct APIListResponse<T: Codable>: Codable {
    let success: Bool
    let data: [T]
    let total: Int?
    let page: Int?
    let error: String?
}

// MARK: - Connection Status
struct ConnectionStatus: Codable {
    let isConnected: Bool
    let lastSync: String?
    let pendingOperations: Int
    
    var statusText: String {
        if isConnected {
            if let lastSync = lastSync,
               let date = ISO8601DateFormatter().date(from: lastSync) {
                return "Онлайн • Синхронизировано \(date.timeAgoDisplay())"
            } else {
                return "Онлайн • Готов к синхронизации"
            }
        } else {
            let pending = pendingOperations > 0 ? " • \(pendingOperations) операций в очереди" : ""
            return "Оффлайн\(pending)"
        }
    }
}

// MARK: - Error Response
struct APIError: Codable, Error {
    let code: Int
    let message: String
    let details: String?
    
    var localizedDescription: String {
        return message
    }
}

// MARK: - Pagination
struct Pagination: Codable {
    let page: Int
    let limit: Int
    let total: Int
    let totalPages: Int
}

// MARK: - Upload Progress
struct UploadProgress {
    let bytesUploaded: Int64
    let totalBytes: Int64
    let progress: Double
    let isCompleted: Bool
}

// MARK: - Sync Status
struct SyncStatus: Codable {
    let lastSyncDate: String?
    let pendingUploads: Int
    let pendingDownloads: Int
    let conflictCount: Int
    
    var isUpToDate: Bool {
        return pendingUploads == 0 && pendingDownloads == 0 && conflictCount == 0
    }
}
