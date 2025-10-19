import Foundation

// MARK: - RestEndpoint Data Models
///
/// Complete data model definitions for the NSP Auto Loyalty Program API.
/// All models are Sendable-compliant for Swift 6 concurrency and support
/// automatic JSON encoding/decoding with snake_case conversion.
///
/// Minimum deployment targets:
/// - iOS 18.0+
/// - macOS 15.0+
/// - watchOS 11.0+
/// - tvOS 18.0+
/// - visionOS 2.0+
@available(iOS 18.0, macOS 15.0, watchOS 11.0, tvOS 18.0, visionOS 2.0, *)
extension RestEndpoint {
    
    // MARK: - Common Types
    
    /// Pagination parameters for list requests
    ///
    /// Used to control the number of items returned in paginated API responses.
    /// Both parameters are optional - if not provided, API uses default values.
    public struct PaginationRequest: Codable, Sendable {
        /// Maximum number of items to return (API default: 50, max: 100)
        public let limit: Int?
        /// Number of items to skip for pagination (default: 0)
        public let offset: Int?
        
        /// Initialize pagination request
        /// - Parameters:
        ///   - limit: Maximum items to return (nil for API default)
        ///   - offset: Items to skip (nil for no offset)
        public init(limit: Int? = nil, offset: Int? = nil) {
            self.limit = limit
            self.offset = offset
        }
    }
    
    /// Pagination metadata included in API responses
    ///
    /// Provides information about the current page and whether more data is available.
    public struct PaginationResponse: Codable, Sendable {
        /// Number of items per page
        public let limit: Int
        /// Current offset (items skipped)
        public let offset: Int
        /// Whether more items are available for pagination
        public let hasMore: Bool?
        
        private enum CodingKeys: String, CodingKey {
            case limit, offset
            case hasMore = "has_more"
        }
    }
    
    /// User role enumeration defining access levels
    ///
    /// Roles determine which API endpoints and operations are available:
    /// - user: Basic QR scanning and point management
    /// - company: Content creation (products, news, campaigns)
    /// - operator: Extended content management
    /// - admin: Full system control
    public enum UserRole: String, Codable, CaseIterable, Sendable {
        case user = "user"
        case company = "company"
        case `operator` = "operator"
        case admin = "admin"
    }
    
    /// User account type for registration
    ///
    /// Determines the type of account being created:
    /// - individual: Personal user account
    /// - company: Business account with additional privileges
    public enum UserType: String, Codable, CaseIterable, Sendable {
        case individual = "individual"
        case company = "company"
    }
    
    /// Point transaction type enumeration
    ///
    /// Categorizes different types of point movements:
    /// - earned: Points gained from QR scans or activities
    /// - spent: Points used for purchases or redemptions
    /// - bonus: Promotional or administrative point grants
    /// - penalty: Point deductions for violations
    public enum TransactionType: String, Codable, CaseIterable, Sendable {
        case earned = "earned"
        case spent = "spent"
        case bonus = "bonus"
        case penalty = "penalty"
    }
    
    /// Promotional campaign type enumeration
    ///
    /// Defines the type of promotional offer:
    /// - discount: Percentage or fixed amount discount
    /// - bonusPoints: Additional points for qualifying actions
    /// - freeShipping: Waived shipping costs
    public enum CampaignType: String, Codable, CaseIterable, Sendable {
        case discount = "discount"
        case bonusPoints = "bonus_points"
        case freeShipping = "free_shipping"
    }
    
    // MARK: - Request Models
    
    /// User registration request data
    ///
    /// Contains all required information for creating a new user account.
    /// Successful registration grants 100 bonus points automatically.
    public struct UserRegistration: Codable, Sendable {
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
    
    /// User authentication credentials
    ///
    /// Used for email/password authentication to obtain bearer tokens.
    public struct LoginCredentials: Codable, Sendable {
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
    
    /// QR code scanning request
    ///
    /// Submits a QR code for validation and point earning.
    /// QR codes follow format: NSP:uuid:category:points
    /// Each QR code can only be scanned once per user.
    public struct QRScanRequest: Codable, Sendable {
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
    
    /// Product catalog creation request
    ///
    /// Used by company+ roles to add new products to the catalog.
    /// Products can be purchased using earned points.
    public struct ProductCreateRequest: Codable, Sendable {
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
    
    /// Car listing creation request
    ///
    /// Used by admin role to add new car listings to the catalog.
    /// Includes comprehensive vehicle specifications.
    public struct CarCreateRequest: Codable, Sendable {
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
    ///
    /// Used by company+ roles to publish news articles and announcements.
    /// Articles can be marked as important for priority display.
    public struct NewsCreateRequest: Codable, Sendable {
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
    
    /// Promotional campaign creation request
    ///
    /// Used by company+ roles to create marketing campaigns with various
    /// discount types, bonus points, or special offers.
    public struct CampaignCreateRequest: Codable, Sendable {
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
    
    /// System health check response
    ///
    /// Provides current system status, version info, and database connectivity.
    /// Used for monitoring and debugging API availability.
    public struct HealthResponse: Codable, Sendable {
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
    
    /// Complete user profile information
    ///
    /// Contains all user account details including current points balance,
    /// role permissions, and account status.
    public struct UserProfile: Codable, Sendable {
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
    
    /// Authentication operation response
    ///
    /// Returned by login and registration endpoints. Contains user profile
    /// and bearer token for subsequent authenticated requests.
    public struct AuthResponse: Codable, Sendable {
        /// Operation success status
        public let success: Bool
        /// User profile data
        public let user: UserProfile?
        /// Authentication token
        public let token: String?
        /// Error message if failed
        public let error: String?
    }
    
    /// QR code scan operation result
    ///
    /// Contains scan validation results, points earned, and product information.
    /// Includes error details if QR code is invalid or already used.
    public struct QRScanResponse: Codable, Sendable {
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
    
    /// Individual QR scan record
    ///
    /// Represents a single QR code scan in the user's history.
    public struct UserScan: Codable, Sendable {
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
    
    /// User's complete QR scan history
    ///
    /// Contains paginated scan history with summary statistics.
    public struct UserScansResponse: Codable, Sendable {
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
    
    /// Product catalog item
    ///
    /// Represents a purchasable item in the loyalty program catalog.
    public struct Product: Codable, Sendable {
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
    
    /// Product catalog listing response
    ///
    /// Contains paginated list of available products.
    public struct ProductsResponse: Codable, Sendable {
        /// Products array
        public let products: [Product]
        /// Pagination info
        public let pagination: PaginationResponse?
    }
    
    /// Detailed vehicle specifications
    ///
    /// Technical details and features for car listings.
    public struct CarSpecifications: Codable, Sendable {
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
    
    /// Car listing information
    ///
    /// Complete vehicle listing with specifications and pricing.
    public struct Car: Codable, Sendable {
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
    
    /// Car catalog listing response
    ///
    /// Contains paginated list of available vehicles.
    public struct CarsResponse: Codable, Sendable {
        /// Cars array
        public let cars: [Car]
        /// Pagination info
        public let pagination: PaginationResponse?
    }
    
    /// Published news article
    ///
    /// Represents a news article or announcement in the system.
    public struct NewsArticle: Codable, Sendable {
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
    
    /// News articles listing response
    ///
    /// Contains paginated list of published news articles.
    public struct NewsResponse: Codable, Sendable {
        /// News articles
        public let news: [NewsArticle]
        /// Pagination info
        public let pagination: PaginationResponse?
    }
    
    /// Promotional campaign information
    ///
    /// Represents an active or scheduled marketing campaign.
    public struct Campaign: Codable, Sendable {
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
    
    /// Promotional campaigns listing response
    ///
    /// Contains paginated list of active campaigns.
    public struct CampaignsResponse: Codable, Sendable {
        /// Campaigns array
        public let campaigns: [Campaign]
        /// Pagination info
        public let pagination: PaginationResponse?
    }
    
    /// Point balance transaction record
    ///
    /// Represents a single point earning or spending transaction.
    public struct PointTransaction: Codable, Sendable {
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
    
    /// Point transactions history response
    ///
    /// Contains paginated list of user's point transactions.
    public struct TransactionsResponse: Codable, Sendable {
        /// Transactions array
        public let transactions: [PointTransaction]
        /// Pagination info
        public let pagination: PaginationResponse?
    }
    
    /// Company performance analytics
    ///
    /// Aggregated metrics for company content and engagement.
    public struct CompanyAnalytics: Codable, Sendable {
        /// Products analytics
        public let products: ProductAnalytics
        /// News analytics
        public let news: NewsAnalytics
        /// Campaigns analytics
        public let campaigns: CampaignAnalytics
    }
    
    /// Product-related analytics metrics
    public struct ProductAnalytics: Codable, Sendable {
        /// Total products
        public let total: Int
    }
    
    /// News content analytics metrics
    public struct NewsAnalytics: Codable, Sendable {
        /// Total articles
        public let total: Int
    }
    
    /// Campaign performance analytics metrics
    public struct CampaignAnalytics: Codable, Sendable {
        /// Total campaigns
        public let total: Int
        /// Active campaigns
        public let active: Int
    }
    
    /// Complete company analytics response
    ///
    /// Contains comprehensive analytics data for company users.
    public struct CompanyAnalyticsResponse: Codable, Sendable {
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
    
    /// Generic operation success response
    ///
    /// Standard response for operations that don't return specific data.
    public struct SuccessResponse: Codable, Sendable {
        /// Operation success status
        public let success: Bool
        /// Success message
        public let message: String?
        /// Error message if failed
        public let error: String?
    }
    
    /// Resource creation operation response
    ///
    /// Returned by POST endpoints that create new resources.
    /// Contains the ID of the created resource on success.
    public struct CreateResponse: Codable, Sendable {
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
            let productId = try? container.decodeIfPresent(String.self, forKey: .productId)
            let carId = try? container.decodeIfPresent(String.self, forKey: .carId)
            let articleId = try? container.decodeIfPresent(String.self, forKey: .articleId)
            let campaignId = try? container.decodeIfPresent(String.self, forKey: .campaignId)
            
            id = productId ?? carId ?? articleId ?? campaignId
        }
        
        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(success, forKey: .success)
            try container.encodeIfPresent(message, forKey: .message)
            try container.encodeIfPresent(error, forKey: .error)
            try container.encodeIfPresent(id, forKey: .productId)
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
