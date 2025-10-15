import Foundation

// MARK: - RestEndpoint Data Models
extension RestEndpoint {
    
    // MARK: - Common Types
    
    /// Pagination parameters for list requests
    public struct PaginationRequest: Codable {
        /// Maximum number of items to return (default: 50)
        public let limit: Int?
        /// Number of items to skip (default: 0)
        public let offset: Int?
        
        public init(limit: Int? = nil, offset: Int? = nil) {
            self.limit = limit
            self.offset = offset
        }
    }

    /// Pagination metadata in responses
    public struct PaginationResponse: Codable {
        /// Items per page
        public let limit: Int
        /// Current offset
        public let offset: Int
        /// Whether more items are available
        public let hasMore: Bool?
        
        private enum CodingKeys: String, CodingKey {
            case limit, offset
            case hasMore = "has_more"
        }
    }

    /// User role enumeration
    public enum UserRole: String, Codable, CaseIterable {
        case user = "user"
        case company = "company"
        case operator = "operator"
        case admin = "admin"
    }

    /// User account type
    public enum UserType: String, Codable, CaseIterable {
        case individual = "individual"
        case company = "company"
    }

    /// Transaction type enumeration
    public enum TransactionType: String, Codable, CaseIterable {
        case earned = "earned"
        case spent = "spent"
        case bonus = "bonus"
        case penalty = "penalty"
    }

    /// Campaign type enumeration
    public enum CampaignType: String, Codable, CaseIterable {
        case discount = "discount"
        case bonusPoints = "bonus_points"
        case freeShipping = "free_shipping"
    }

    // MARK: - Request Models

    /// User registration request
    public struct UserRegistration: Codable {
        /// Full name
        public let name: String
        /// Email address (unique)
        public let email: String
        /// Phone number
        public let phone: String
        /// Password (will be hashed)
        public let password: String
        /// Account type
        public let userType: UserType
        /// Optional device information
        public let deviceInfo: String?
        
        public init(name: String, email: String, phone: String, password: String, userType: UserType, deviceInfo: String? = nil) {
            self.name = name
            self.email = email
            self.phone = phone
            self.password = password
            self.userType = userType
            self.deviceInfo = deviceInfo
        }
    }

    /// Login credentials
    public struct LoginCredentials: Codable {
        /// User email
        public let email: String
        /// User password
        public let password: String
        /// Optional device information
        public let deviceInfo: String?
        
        public init(email: String, password: String, deviceInfo: String? = nil) {
            self.email = email
            self.password = password
            self.deviceInfo = deviceInfo
        }
    }

    /// QR code scan request
    public struct QRScanRequest: Codable {
        /// QR code string (format: NSP:uuid:category:points)
        public let qrCode: String
        /// Optional scan location
        public let location: String?
        
        private enum CodingKeys: String, CodingKey {
            case qrCode = "qr_code"
            case location
        }
        
        public init(qrCode: String, location: String? = nil) {
            self.qrCode = qrCode
            self.location = location
        }
    }

    /// Product creation request
    public struct ProductCreateRequest: Codable {
        /// Product name
        public let name: String
        /// Product category
        public let category: String
        /// Points required to purchase
        public let pointsCost: Int
        /// Optional description
        public let description: String?
        /// Optional image URL
        public let imageURL: String?
        /// Available stock quantity
        public let stockQuantity: Int
        /// Available delivery methods
        public let deliveryOptions: [String]
        
        public init(name: String, category: String, pointsCost: Int, description: String? = nil, imageURL: String? = nil, stockQuantity: Int, deliveryOptions: [String] = []) {
            self.name = name
            self.category = category
            self.pointsCost = pointsCost
            self.description = description
            self.imageURL = imageURL
            self.stockQuantity = stockQuantity
            self.deliveryOptions = deliveryOptions
        }
    }

    /// Car creation request
    public struct CarCreateRequest: Codable {
        /// Car manufacturer
        public let brand: String
        /// Car model
        public let model: String
        /// Manufacturing year
        public let year: Int
        /// Price as string
        public let price: String
        /// Optional description
        public let description: String?
        /// Optional engine specifications
        public let engine: String?
        /// Optional transmission type
        public let transmission: String?
        /// Optional fuel type
        public let fuelType: String?
        /// Optional body style
        public let bodyType: String?
        /// Optional drivetrain type
        public let drivetrain: String?
        /// Optional car color
        public let color: String?
        
        public init(brand: String, model: String, year: Int, price: String, description: String? = nil, engine: String? = nil, transmission: String? = nil, fuelType: String? = nil, bodyType: String? = nil, drivetrain: String? = nil, color: String? = nil) {
            self.brand = brand
            self.model = model
            self.year = year
            self.price = price
            self.description = description
            self.engine = engine
            self.transmission = transmission
            self.fuelType = fuelType
            self.bodyType = bodyType
            self.drivetrain = drivetrain
            self.color = color
        }
    }

    /// News article creation request
    public struct NewsCreateRequest: Codable {
        /// Article title
        public let title: String
        /// Article content
        public let content: String
        /// Optional image URL
        public let imageURL: String?
        /// Priority flag
        public let isImportant: Bool
        /// Publication status
        public let isPublished: Bool
        /// Article tags
        public let tags: [String]
        /// Article type
        public let articleType: String
        
        public init(title: String, content: String, imageURL: String? = nil, isImportant: Bool = false, isPublished: Bool = true, tags: [String] = [], articleType: String = "news") {
            self.title = title
            self.content = content
            self.imageURL = imageURL
            self.isImportant = isImportant
            self.isPublished = isPublished
            self.tags = tags
            self.articleType = articleType
        }
    }

    /// Campaign creation request
    public struct CampaignCreateRequest: Codable {
        /// Campaign title
        public let title: String
        /// Campaign description
        public let description: String
        /// Campaign type
        public let campaignType: CampaignType
        /// Discount percentage
        public let discountPercent: Int?
        /// Bonus points amount
        public let bonusPoints: Int?
        /// Minimum purchase requirement
        public let minPurchaseAmount: Int?
        /// Campaign start date (ISO8601)
        public let startDate: String
        /// Campaign end date (ISO8601)
        public let endDate: String
        /// Optional image URL
        public let imageURL: String?
        /// Target audience criteria
        public let targetAudience: [String: String]
        /// Maximum usage limit
        public let maxUsage: Int
        
        public init(title: String, description: String, campaignType: CampaignType, discountPercent: Int? = nil, bonusPoints: Int? = nil, minPurchaseAmount: Int? = nil, startDate: String, endDate: String, imageURL: String? = nil, targetAudience: [String: String] = [:], maxUsage: Int = 0) {
            self.title = title
            self.description = description
            self.campaignType = campaignType
            self.discountPercent = discountPercent
            self.bonusPoints = bonusPoints
            self.minPurchaseAmount = minPurchaseAmount
            self.startDate = startDate
            self.endDate = endDate
            self.imageURL = imageURL
            self.targetAudience = targetAudience
            self.maxUsage = maxUsage
        }
    }

    // MARK: - Response Models

    /// System health response
    public struct HealthResponse: Codable {
        /// System status
        public let status: String
        /// Response timestamp
        public let timestamp: String
        /// API version
        public let version: String
        /// Database connection status
        public let database: String
        /// Error message if unhealthy
        public let error: String?
    }

    /// User profile data
    public struct UserProfile: Codable {
        /// User ID (UUID)
        public let id: String
        /// User full name
        public let name: String
        /// User email
        public let email: String
        /// User phone
        public let phone: String
        /// Account type
        public let userType: UserType
        /// Current points balance
        public let points: Int
        /// User role
        public let role: UserRole
        /// Registration date (ISO8601)
        public let registrationDate: String?
        /// Account status
        public let isActive: Bool
    }

    /// Authentication response
    public struct AuthResponse: Codable {
        /// Operation success status
        public let success: Bool
        /// User profile data
        public let user: UserProfile?
        /// Authentication token
        public let token: String?
        /// Error message if failed
        public let error: String?
    }

    /// QR scan result
    public struct QRScanResponse: Codable {
        /// Scan validity
        public let valid: Bool
        /// Scan record ID
        public let scanId: String?
        /// Product name
        public let productName: String?
        /// Product category
        public let productCategory: String?
        /// Points awarded
        public let pointsEarned: Int?
        /// Product description
        public let description: String?
        /// Scan timestamp
        public let timestamp: String?
        /// Error message if invalid
        public let error: String?
        /// Previous usage timestamp
        public let usedAt: String?
        
        private enum CodingKeys: String, CodingKey {
            case valid
            case scanId = "scan_id"
            case productName = "product_name"
            case productCategory = "product_category"
            case pointsEarned = "points_earned"
            case description, timestamp, error
            case usedAt = "used_at"
        }
    }

    /// User scan history item
    public struct UserScan: Codable {
        /// Scan ID
        public let id: String
        /// QR code ID
        public let qrCode: String
        /// Product name
        public let productName: String
        /// Product category
        public let productCategory: String
        /// Points earned
        public let pointsEarned: Int
        /// Scan timestamp
        public let timestamp: String?
        /// Scan location
        public let location: String?
        
        private enum CodingKeys: String, CodingKey {
            case id
            case qrCode = "qr_code"
            case productName = "product_name"
            case productCategory = "product_category"
            case pointsEarned = "points_earned"
            case timestamp, location
        }
    }

    /// User scans response
    public struct UserScansResponse: Codable {
        /// User ID
        public let userId: String
        /// Total scans count
        public let totalScans: Int
        /// Total points earned
        public let totalPoints: Int
        /// Scan history
        public let scans: [UserScan]
        /// Pagination info
        public let pagination: PaginationResponse?
        
        private enum CodingKeys: String, CodingKey {
            case userId = "user_id"
            case totalScans = "total_scans"
            case totalPoints = "total_points"
            case scans, pagination
        }
    }

    /// Product data
    public struct Product: Codable {
        /// Product ID
        public let id: String
        /// Product name
        public let name: String
        /// Product category
        public let category: String
        /// Points cost
        public let pointsCost: Int
        /// Image URL
        public let imageURL: String
        /// Description
        public let description: String
        /// Stock quantity
        public let stockQuantity: Int
        /// Active status
        public let isActive: Bool
        /// Creation date
        public let createdAt: String
        /// Delivery options
        public let deliveryOptions: [String]
    }

    /// Products list response
    public struct ProductsResponse: Codable {
        /// Products array
        public let products: [Product]
        /// Pagination info
        public let pagination: PaginationResponse?
    }

    /// Car specifications
    public struct CarSpecifications: Codable {
        /// Engine specs
        public let engine: String
        /// Transmission type
        public let transmission: String
        /// Fuel type
        public let fuelType: String
        /// Body type
        public let bodyType: String
        /// Drivetrain
        public let drivetrain: String
        /// Color
        public let color: String
    }

    /// Car data
    public struct Car: Codable {
        /// Car ID
        public let id: String
        /// Brand
        public let brand: String
        /// Model
        public let model: String
        /// Year
        public let year: Int
        /// Price
        public let price: String
        /// Image URL
        public let imageURL: String
        /// Description
        public let description: String
        /// Specifications
        public let specifications: CarSpecifications
        /// Active status
        public let isActive: Bool
        /// Creation date
        public let createdAt: String
    }

    /// Cars list response
    public struct CarsResponse: Codable {
        /// Cars array
        public let cars: [Car]
        /// Pagination info
        public let pagination: PaginationResponse?
    }

    /// News article data
    public struct NewsArticle: Codable {
        /// Article ID
        public let id: String
        /// Title
        public let title: String
        /// Content
        public let content: String
        /// Image URL
        public let imageURL: String
        /// Important flag
        public let isImportant: Bool
        /// Creation date
        public let createdAt: String
        /// Publication date
        public let publishedAt: String?
        /// Published status
        public let isPublished: Bool
        /// Author ID
        public let authorId: String?
        /// Tags
        public let tags: [String]
    }

    /// News list response
    public struct NewsResponse: Codable {
        /// News articles
        public let news: [NewsArticle]
        /// Pagination info
        public let pagination: PaginationResponse?
    }

    /// Campaign data
    public struct Campaign: Codable {
        /// Campaign ID
        public let id: String
        /// Title
        public let title: String
        /// Description
        public let description: String
        /// Campaign type
        public let campaignType: CampaignType
        /// Discount percentage
        public let discountPercent: Int?
        /// Bonus points
        public let bonusPoints: Int?
        /// Minimum purchase amount
        public let minPurchaseAmount: Int?
        /// Start date
        public let startDate: String
        /// End date
        public let endDate: String
        /// Image URL
        public let imageURL: String?
        /// Usage count
        public let usageCount: Int
        /// Maximum usage
        public let maxUsage: Int
        /// Company ID
        public let companyId: String?
    }

    /// Campaigns list response
    public struct CampaignsResponse: Codable {
        /// Campaigns array
        public let campaigns: [Campaign]
        /// Pagination info
        public let pagination: PaginationResponse?
    }

    /// Point transaction data
    public struct PointTransaction: Codable {
        /// Transaction ID
        public let id: String
        /// User ID
        public let userId: String
        /// Transaction type
        public let type: TransactionType
        /// Amount
        public let amount: Int
        /// Description
        public let description: String
        /// Timestamp
        public let timestamp: String
        /// Related entity ID
        public let relatedId: String?
    }

    /// Transactions list response
    public struct TransactionsResponse: Codable {
        /// Transactions array
        public let transactions: [PointTransaction]
        /// Pagination info
        public let pagination: PaginationResponse?
    }

    /// Company analytics data
    public struct CompanyAnalytics: Codable {
        /// Products analytics
        public let products: ProductAnalytics
        /// News analytics
        public let news: NewsAnalytics
        /// Campaigns analytics
        public let campaigns: CampaignAnalytics
    }

    /// Product analytics
    public struct ProductAnalytics: Codable {
        /// Total products
        public let total: Int
    }

    /// News analytics
    public struct NewsAnalytics: Codable {
        /// Total articles
        public let total: Int
    }

    /// Campaign analytics
    public struct CampaignAnalytics: Codable {
        /// Total campaigns
        public let total: Int
        /// Active campaigns
        public let active: Int
    }

    /// Company analytics response
    public struct CompanyAnalyticsResponse: Codable {
        /// Company ID
        public let companyId: String
        /// Company name
        public let companyName: String
        /// Analytics data
        public let analytics: CompanyAnalytics
        /// Response timestamp
        public let timestamp: String
        
        private enum CodingKeys: String, CodingKey {
            case companyId = "company_id"
            case companyName = "company_name"
            case analytics, timestamp
        }
    }

    /// Generic success response
    public struct SuccessResponse: Codable {
        /// Operation success status
        public let success: Bool
        /// Success message
        public let message: String?
        /// Error message if failed
        public let error: String?
    }

    /// Generic creation response
    public struct CreateResponse: Codable {
        /// Operation success status
        public let success: Bool
        /// Created entity ID
        public let id: String?
        /// Success message
        public let message: String?
        /// Error message if failed
        public let error: String?
        
        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            success = try container.decode(Bool.self, forKey: .success)
            message = try container.decodeIfPresent(String.self, forKey: .message)
            error = try container.decodeIfPresent(String.self, forKey: .error)
            
            // Try different ID field names
            id = try container.decodeIfPresent(String.self, forKey: .productId) ??
                 try container.decodeIfPresent(String.self, forKey: .carId) ??
                 try container.decodeIfPresent(String.self, forKey: .articleId) ??
                 try container.decodeIfPresent(String.self, forKey: .campaignId)
        }
        
        private enum CodingKeys: String, CodingKey {
            case success, message, error
            case productId = "product_id"
            case carId = "car_id"
            case articleId = "article_id"
            case campaignId = "campaign_id"
        }
    }
}