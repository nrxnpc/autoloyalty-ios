import Foundation

// MARK: - Raw API Response Models

extension RestEndpoint {
    
    // MARK: - Authentication Models
    
    struct User: Codable {
        let id: String
        let name: String
        let email: String
        let phone: String
        let userType: String
        let points: Int
        let role: String
        let registrationDate: String
        let isActive: Bool
    }
    
    struct AuthResponse: Codable {
        let success: Bool
        let user: User?
        let token: String?
        let error: String?
    }
    
    struct HealthResponse: Codable {
        let status: String
        let timestamp: String
        let version: String
        let database: String
    }
    
    // MARK: - QR Code Models
    
    struct QRScanResponse: Codable {
        let valid: Bool
        let scan_id: String?
        let product_name: String?
        let product_category: String?
        let points_earned: Int?
        let description: String?
        let timestamp: String?
        let error: String?
        let used_at: String?
    }
    
    struct UserScan: Codable {
        let id: String
        let qr_code: String
        let product_name: String
        let product_category: String
        let points_earned: Int
        let timestamp: String
        let location: String?
    }
    
    struct UserScansResponse: Codable {
        let user_id: String
        let total_scans: Int
        let total_points: Int
        let scans: [UserScan]
        let pagination: Pagination?
    }
    
    // MARK: - Product Models
    
    struct Product: Codable {
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
    }
    
    struct ProductsResponse: Codable {
        let products: [Product]
        let pagination: Pagination?
    }
    
    // MARK: - Car Models
    
    struct Car: Codable {
        let id: String
        let brand: String
        let model: String
        let year: Int
        let price: String
        let imageURL: String
        let description: String
        let specifications: CarSpecifications
        let isActive: Bool
        let createdAt: String
    }
    
    struct CarSpecifications: Codable {
        let engine: String
        let transmission: String
        let fuelType: String
        let bodyType: String
        let drivetrain: String
        let color: String
    }
    
    struct CarsResponse: Codable {
        let cars: [Car]
        let pagination: Pagination?
    }
    
    struct CarCreateResponse: Codable {
        let success: Bool
        let car_id: String?
        let message: String?
        let error: String?
    }
    
    // MARK: - News Models
    
    struct NewsArticle: Codable {
        let id: String
        let title: String
        let content: String
        let imageURL: String
        let isImportant: Bool
        let createdAt: String
        let publishedAt: String?
        let isPublished: Bool
        let authorId: String?
        let tags: [String]
    }
    
    struct NewsResponse: Codable {
        let news: [NewsArticle]
        let pagination: Pagination?
    }
    
    // MARK: - Transaction Models
    
    struct PointTransaction: Codable {
        let id: String
        let userId: String
        let type: String
        let amount: Int
        let description: String
        let timestamp: String
        let relatedId: String?
    }
    
    struct TransactionsResponse: Codable {
        let transactions: [PointTransaction]
        let pagination: Pagination?
    }
    
    // MARK: - File Upload Models
    
    struct FileUploadResponse: Codable {
        let success: Bool
        let file_url: String?
        let filename: String?
        let size: Int?
        let error: String?
    }
    
    // MARK: - Campaign Models
    
    struct Campaign: Codable {
        let id: String
        let title: String
        let description: String
        let campaignType: String
        let discountPercent: Int?
        let bonusPoints: Int?
        let minPurchaseAmount: Int?
        let startDate: String
        let endDate: String
        let imageURL: String?
        let usageCount: Int
        let maxUsage: Int
        let companyId: String?
    }
    
    struct CampaignsResponse: Codable {
        let campaigns: [Campaign]
        let pagination: Pagination?
    }
    
    struct CampaignCreateResponse: Codable {
        let success: Bool
        let campaign_id: String?
        let message: String?
        let error: String?
    }
    
    // MARK: - Analytics Models
    
    struct ProductAnalytics: Codable {
        let total: Int
    }
    
    struct NewsAnalytics: Codable {
        let total: Int
    }
    
    struct CampaignAnalytics: Codable {
        let total: Int
        let active: Int
    }
    
    struct CompanyAnalytics: Codable {
        let products: ProductAnalytics
        let news: NewsAnalytics
        let campaigns: CampaignAnalytics
    }
    
    struct CompanyAnalyticsResponse: Codable {
        let company_id: String
        let company_name: String
        let analytics: CompanyAnalytics
        let timestamp: String
    }
    
    // MARK: - Create Response Models
    
    struct ProductCreateResponse: Codable {
        let success: Bool
        let product_id: String?
        let message: String?
        let error: String?
    }
    
    struct NewsCreateResponse: Codable {
        let success: Bool
        let news_id: String?
        let message: String?
        let error: String?
    }
    
    // MARK: - Statistics Models
    
    struct QRCodeStats: Codable {
        let total: Int
        let unused: Int
        let used: Int
        let total_scans: Int
    }
    
    struct UserStats: Codable {
        let total: Int
        let active: Int
    }
    
    struct ScanStats: Codable {
        let total: Int
        let unique_scanners: Int
        let total_points_earned: Int
    }
    
    struct StatisticsResponse: Codable {
        let qr_codes: QRCodeStats
        let users: UserStats
        let scans: ScanStats
        let timestamp: String
    }
    
    // MARK: - Common Models
    
    struct Pagination: Codable {
        let limit: Int
        let offset: Int
        let has_more: Bool?
    }
    
    struct ErrorResponse: Codable {
        let error: String
    }
}

// MARK: - Request Models

struct LoginRequest: Codable {
    let email: String
    let password: String
    let deviceInfo: String?
}

struct RegistrationRequest: Codable {
    let name: String
    let email: String
    let phone: String
    let password: String
    let userType: String
    let deviceInfo: String?
}

struct QRScanRequest: Codable {
    let qr_code: String
    let location: String?
}

struct CarCreateRequest: Codable {
    let brand: String
    let model: String
    let year: Int
    let price: String
    let description: String?
    let engine: String?
    let transmission: String?
    let fuelType: String?
    let bodyType: String?
    let drivetrain: String?
    let color: String?
}

struct ProductCreateRequest: Codable {
    let name: String
    let category: String
    let pointsCost: Int
    let description: String?
    let imageURL: String?
    let stockQuantity: Int
    let deliveryOptions: [String]
}

struct NewsCreateRequest: Codable {
    let title: String
    let content: String
    let imageURL: String?
    let isImportant: Bool
    let isPublished: Bool
    let tags: [String]
    let articleType: String
}

struct CampaignCreateRequest: Codable {
    let title: String
    let description: String
    let campaignType: String
    let discountPercent: Int?
    let bonusPoints: Int?
    let minPurchaseAmount: Int?
    let startDate: String
    let endDate: String
    let imageURL: String?
    let targetAudience: [String: String]
    let maxUsage: Int
}

struct FileUploadRequest: Codable {
    let file: Data
    let filename: String
}
