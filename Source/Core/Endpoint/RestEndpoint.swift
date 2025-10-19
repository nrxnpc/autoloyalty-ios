import Foundation
import Endpoint

/// NSP Auto Loyalty Program API Client
/// 
/// A type-safe REST API client for the NSP Auto Loyalty Program backend.
/// Supports iOS 18+, macOS 15+, watchOS 11+, tvOS 18+, visionOS 2+
/// 
/// Features:
/// - Async/await support with Swift 6 concurrency
/// - Type-safe request/response models
/// - Automatic JSON encoding/decoding with snake_case conversion
/// - Flexible authentication (unauthenticated, bearer token, auto-refresh)
/// - Comprehensive endpoint coverage for all user roles
@available(iOS 18.0, macOS 15.0, watchOS 11.0, tvOS 18.0, visionOS 2.0, *)
public final class RestEndpoint: EndpointBuilder, Sendable {
    private let baseURL: URL
    private let authenticator: ProxyAuthenticator
    // WARNING: Stored property 'session' of 'Sendable'-conforming class 'RestEndpoint' has non-sendable type 'any SessionProtocol'; this is an error in the Swift 6 language mode
    private let session: SessionProtocol

    /// Initialize the API client with base URL and session
    /// - Parameters:
    ///   - baseURL: The base URL for the API server
    ///   - session: Session protocol implementation for HTTP requests
    public init(baseURL: URL, session: SessionProtocol) {
        self.baseURL = baseURL
        self.authenticator = ProxyAuthenticator()
        self.session = session
    }
    
    // MARK: - Authentication Management
    
    /// Configure client for unauthenticated requests (public endpoints)
    public func setUnauthenticated() {
        authenticator.setAuthenticator(UnauthenticatedAuthenticator())
    }
    
    /// Configure client to use bearer token authentication
    /// - Parameter provider: Async closure that returns the current bearer token
    public func setBearerToken(provider: @escaping @Sendable () async -> String?) {
        authenticator.setAuthenticator(BearerTokenAuthenticator(tokenProvider: provider))
    }
    
    /// Configure client to use auto-refreshing bearer token authentication
    /// - Parameters:
    ///   - tokenProvider: Async closure that returns the current bearer token
    ///   - refreshAction: Async closure to refresh the token when needed
    public func setAutoRefreshToken(
        tokenProvider: @escaping @Sendable () async -> String?,
        refreshAction: @escaping @Sendable () async throws -> Void
    ) {
        let autoRefreshAuth = AutoRefreshAuthenticator(
            tokenProvider: tokenProvider,
            refreshAction: refreshAction
        )
        authenticator.setAuthenticator(autoRefreshAuth)
    }
}

/// Dependency injection and factory methods for ResourceEndpoint
public extension RestEndpoint {
    /// Production endpoint with real server
    static let localhost = RestEndpoint(
        baseURL: URL(string: "http://localhost:8080/api/v1")!,
        session: URLSession.shared
    )
}

// MARK: - API Methods
@available(iOS 18.0, macOS 15.0, watchOS 11.0, tvOS 18.0, visionOS 2.0, *)
public extension RestEndpoint {
    
    // MARK: - System Health
    
    /// Check system health and status
    /// - Returns: Health response with system status and version info
    /// - Throws: Network or decoding errors
    func healthCheck() async throws -> RestEndpoint.HealthResponse {
        try await Endpoint(baseURL: baseURL)
            .get("health")
            .session(session)
            .call(decoder: Self.jsonDecoder, isDataWrapped: false)
    }
    
    // MARK: - Authentication & Account Management
    
    /// Register a new user account
    /// - Parameter request: User registration data
    /// - Returns: Authentication response with user profile and token
    /// - Throws: Network or validation errors
    func register(_ request: RestEndpoint.UserRegistration) async throws -> RestEndpoint.AuthResponse {
        try await Endpoint(baseURL: baseURL)
            .post("register")
            .body(request, encoder: Self.jsonEncoder)
            .session(session)
            .call(decoder: Self.jsonDecoder, isDataWrapped: false)
    }
    
    /// Authenticate user with email and password
    /// - Parameter credentials: Login credentials (email/password)
    /// - Returns: Authentication response with user profile and token
    /// - Throws: Network or authentication errors
    func login(_ credentials: RestEndpoint.LoginCredentials) async throws -> RestEndpoint.AuthResponse {
        try await Endpoint(baseURL: baseURL)
            .post("login")
            .body(credentials, encoder: Self.jsonEncoder)
            .session(session)
            .call(decoder: Self.jsonDecoder, isDataWrapped: false)
    }
    
    /// Delete user account (requires authentication)
    /// - Parameter userID: ID of user to delete
    /// - Returns: Success response
    /// - Throws: Network or authorization errors
    func deleteUser(_ userID: String) async throws -> RestEndpoint.SuccessResponse {
        try await Endpoint(baseURL: baseURL)
            .delete("users/\(userID)")
            .authenticate(with: authenticator)
            .session(session)
            .call(decoder: Self.jsonDecoder, isDataWrapped: false)
    }
    
    // MARK: - QR Code Operations
    
    /// Scan QR code to earn points (requires authentication)
    /// - Parameter request: QR scan request with code and optional location
    /// - Returns: Scan result with points earned and product info
    /// - Throws: Network errors or invalid QR code errors
    func scanQRCode(_ request: RestEndpoint.QRScanRequest) async throws -> RestEndpoint.QRScanResponse {
        try await Endpoint(baseURL: baseURL)
            .post("scan")
            .body(request, encoder: Self.jsonEncoder)
            .authenticate(with: authenticator)
            .session(session)
            .call(decoder: Self.jsonDecoder, isDataWrapped: false)
    }
    
    /// Get user's QR scan history (requires authentication)
    /// - Parameter pagination: Optional pagination parameters
    /// - Returns: User scans with history and statistics
    /// - Throws: Network or authorization errors
    func getUserScans(_ pagination: RestEndpoint.PaginationRequest = RestEndpoint.PaginationRequest()) async throws -> RestEndpoint.UserScansResponse {
        var endpoint = Endpoint(baseURL: baseURL)
            .get("user/scans")
            .authenticate(with: authenticator)
            .session(session)
        
        if let limit = pagination.limit {
            endpoint = endpoint.parameter(key: "limit", value: String(limit))
        }
        if let offset = pagination.offset {
            endpoint = endpoint.parameter(key: "offset", value: String(offset))
        }
        
        return try await endpoint.call(decoder: Self.jsonDecoder, isDataWrapped: false)
    }
    
    // MARK: - Product Catalog
    
    /// Get product catalog (public endpoint)
    /// - Parameter pagination: Optional pagination parameters
    /// - Returns: Products list with pagination info
    /// - Throws: Network or decoding errors
    func getProducts(_ pagination: RestEndpoint.PaginationRequest = RestEndpoint.PaginationRequest()) async throws -> RestEndpoint.ProductsResponse {
        var endpoint = Endpoint(baseURL: baseURL)
            .get("products")
            .session(session)
        
        if let limit = pagination.limit {
            endpoint = endpoint.parameter(key: "limit", value: String(limit))
        }
        if let offset = pagination.offset {
            endpoint = endpoint.parameter(key: "offset", value: String(offset))
        }
        
        return try await endpoint.call(decoder: Self.jsonDecoder, isDataWrapped: false)
    }
    
    /// Add new product to catalog (requires company+ role)
    /// - Parameter product: Product creation data
    /// - Returns: Creation response with product ID
    /// - Throws: Network or authorization errors
    func addProduct(_ product: RestEndpoint.ProductCreateRequest) async throws -> RestEndpoint.CreateResponse {
        try await Endpoint(baseURL: baseURL)
            .post("products")
            .body(product, encoder: Self.jsonEncoder)
            .authenticate(with: authenticator)
            .session(session)
            .call(decoder: Self.jsonDecoder, isDataWrapped: false)
    }
    
    /// Delete product from catalog (requires company+ role)
    /// - Parameter productID: ID of product to delete
    /// - Returns: Success response
    /// - Throws: Network or authorization errors
    func deleteProduct(_ productID: String) async throws -> RestEndpoint.SuccessResponse {
        try await Endpoint(baseURL: baseURL)
            .delete("products/\(productID)")
            .authenticate(with: authenticator)
            .session(session)
            .call(decoder: Self.jsonDecoder, isDataWrapped: false)
    }
    
    // MARK: - Car Catalog
    
    /// Get car listings (public endpoint)
    /// - Parameter pagination: Optional pagination parameters
    /// - Returns: Cars list with pagination info
    /// - Throws: Network or decoding errors
    func getCars(_ pagination: RestEndpoint.PaginationRequest = RestEndpoint.PaginationRequest()) async throws -> RestEndpoint.CarsResponse {
        var endpoint = Endpoint(baseURL: baseURL)
            .get("cars")
            .session(session)
        
        if let limit = pagination.limit {
            endpoint = endpoint.parameter(key: "limit", value: String(limit))
        }
        if let offset = pagination.offset {
            endpoint = endpoint.parameter(key: "offset", value: String(offset))
        }
        
        return try await endpoint.call(decoder: Self.jsonDecoder, isDataWrapped: false)
    }
    
    /// Add new car listing (requires admin role)
    /// - Parameter car: Car creation data
    /// - Returns: Creation response with car ID
    /// - Throws: Network or authorization errors
    func addCar(_ car: RestEndpoint.CarCreateRequest) async throws -> RestEndpoint.CreateResponse {
        try await Endpoint(baseURL: baseURL)
            .post("cars")
            .body(car, encoder: Self.jsonEncoder)
            .authenticate(with: authenticator)
            .session(session)
            .call(decoder: Self.jsonDecoder, isDataWrapped: false)
    }
    
    /// Delete car listing (requires admin role)
    /// - Parameter carID: ID of car to delete
    /// - Returns: Success response
    /// - Throws: Network or authorization errors
    func deleteCar(_ carID: String) async throws -> RestEndpoint.SuccessResponse {
        try await Endpoint(baseURL: baseURL)
            .delete("cars/\(carID)")
            .authenticate(with: authenticator)
            .session(session)
            .call(decoder: Self.jsonDecoder, isDataWrapped: false)
    }
    
    // MARK: - News & Articles
    
    /// Get published news articles (public endpoint)
    /// - Parameter pagination: Optional pagination parameters
    /// - Returns: News articles list with pagination info
    /// - Throws: Network or decoding errors
    func getNews(_ pagination: RestEndpoint.PaginationRequest = RestEndpoint.PaginationRequest()) async throws -> RestEndpoint.NewsResponse {
        var endpoint = Endpoint(baseURL: baseURL)
            .get("news")
            .session(session)
        
        if let limit = pagination.limit {
            endpoint = endpoint.parameter(key: "limit", value: String(limit))
        }
        if let offset = pagination.offset {
            endpoint = endpoint.parameter(key: "offset", value: String(offset))
        }
        
        return try await endpoint.call(decoder: Self.jsonDecoder, isDataWrapped: false)
    }
    
    /// Publish new news article (requires company+ role)
    /// - Parameter article: News article creation data
    /// - Returns: Creation response with article ID
    /// - Throws: Network or authorization errors
    func addNews(_ article: RestEndpoint.NewsCreateRequest) async throws -> RestEndpoint.CreateResponse {
        try await Endpoint(baseURL: baseURL)
            .post("news")
            .body(article, encoder: Self.jsonEncoder)
            .authenticate(with: authenticator)
            .session(session)
            .call(decoder: Self.jsonDecoder, isDataWrapped: false)
    }
    
    /// Delete news article (requires company+ role)
    /// - Parameter newsID: ID of news article to delete
    /// - Returns: Success response
    /// - Throws: Network or authorization errors
    func deleteNews(_ newsID: String) async throws -> RestEndpoint.SuccessResponse {
        try await Endpoint(baseURL: baseURL)
            .delete("news/\(newsID)")
            .authenticate(with: authenticator)
            .session(session)
            .call(decoder: Self.jsonDecoder, isDataWrapped: false)
    }
    
    // MARK: - Promotional Campaigns
    
    /// Get active promotional campaigns (public endpoint)
    /// - Parameter pagination: Optional pagination parameters
    /// - Returns: Campaigns list with pagination info
    /// - Throws: Network or decoding errors
    func getCampaigns(_ pagination: RestEndpoint.PaginationRequest = RestEndpoint.PaginationRequest()) async throws -> RestEndpoint.CampaignsResponse {
        var endpoint = Endpoint(baseURL: baseURL)
            .get("campaigns")
            .session(session)
        
        if let limit = pagination.limit {
            endpoint = endpoint.parameter(key: "limit", value: String(limit))
        }
        if let offset = pagination.offset {
            endpoint = endpoint.parameter(key: "offset", value: String(offset))
        }
        
        return try await endpoint.call(decoder: Self.jsonDecoder, isDataWrapped: false)
    }
    
    /// Create new promotional campaign (requires company+ role)
    /// - Parameter campaign: Campaign creation data
    /// - Returns: Creation response with campaign ID
    /// - Throws: Network or authorization errors
    func createCampaign(_ campaign: RestEndpoint.CampaignCreateRequest) async throws -> RestEndpoint.CreateResponse {
        try await Endpoint(baseURL: baseURL)
            .post("campaigns")
            .body(campaign, encoder: Self.jsonEncoder)
            .authenticate(with: authenticator)
            .session(session)
            .call(decoder: Self.jsonDecoder, isDataWrapped: false)
    }
    
    /// Delete promotional campaign (requires company+ role)
    /// - Parameter campaignID: ID of campaign to delete
    /// - Returns: Success response
    /// - Throws: Network or authorization errors
    func deleteCampaign(_ campaignID: String) async throws -> RestEndpoint.SuccessResponse {
        try await Endpoint(baseURL: baseURL)
            .delete("campaigns/\(campaignID)")
            .authenticate(with: authenticator)
            .session(session)
            .call(decoder: Self.jsonDecoder, isDataWrapped: false)
    }
    
    // MARK: - Point Transactions
    
    /// Get user's point transaction history (requires authentication)
    /// - Parameter pagination: Optional pagination parameters
    /// - Returns: Transactions list with pagination info
    /// - Throws: Network or authorization errors
    func getUserTransactions(_ pagination: RestEndpoint.PaginationRequest = RestEndpoint.PaginationRequest()) async throws -> RestEndpoint.TransactionsResponse {
        var endpoint = Endpoint(baseURL: baseURL)
            .get("user/transactions")
            .authenticate(with: authenticator)
            .session(session)
        
        if let limit = pagination.limit {
            endpoint = endpoint.parameter(key: "limit", value: String(limit))
        }
        if let offset = pagination.offset {
            endpoint = endpoint.parameter(key: "offset", value: String(offset))
        }
        
        return try await endpoint.call(decoder: Self.jsonDecoder, isDataWrapped: false)
    }
    
    // MARK: - Company Analytics
    
    /// Get company performance analytics (requires company+ role)
    /// - Returns: Analytics data with metrics for products, news, and campaigns
    /// - Throws: Network or authorization errors
    func getCompanyAnalytics() async throws -> RestEndpoint.CompanyAnalyticsResponse {
        try await Endpoint(baseURL: baseURL)
            .get("company/analytics")
            .authenticate(with: authenticator)
            .session(session)
            .call(decoder: Self.jsonDecoder, isDataWrapped: false)
    }
}

// MARK: - JSON Configuration
@available(iOS 18.0, macOS 15.0, watchOS 11.0, tvOS 18.0, visionOS 2.0, *)
internal extension RestEndpoint {
    /// Shared JSON decoder configured for snake_case key conversion
    /// 
    /// Automatically converts API response keys from snake_case to camelCase
    /// for Swift property names (e.g., "user_id" -> "userId")
    static let jsonDecoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()
    
    /// Shared JSON encoder configured for snake_case key conversion
    /// 
    /// Automatically converts Swift property names from camelCase to snake_case
    /// for API requests (e.g., "userId" -> "user_id")
    static let jsonEncoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }()
}
