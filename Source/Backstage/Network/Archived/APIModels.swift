import Foundation

// MARK: - Legacy API Models
// These models have been moved to RestEndpoint+Raw.swift
// This file now contains only request/response wrappers and utility models

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
