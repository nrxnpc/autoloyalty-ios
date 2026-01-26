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
        baseURL: URL(string: "http://80.64.16.58:8081/api/v1")!,
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
    
    /// Get current user profile (requires authentication)
    /// - Returns: User profile response with current user data
    /// - Throws: Network or authorization errors
    func getCurrentUser() async throws -> RestEndpoint.UserProfileResponse {
        try await Endpoint(baseURL: baseURL)
            .get("user/me")
            .authenticate(with: authenticator)
            .session(session)
            .call(decoder: Self.jsonDecoder, isDataWrapped: false)
    }
    
    /// Refresh access token using refresh token
    /// - Parameter request: Refresh token request
    /// - Returns: New authentication tokens
    /// - Throws: Network or authentication errors
    func refreshToken(_ request: RestEndpoint.RefreshRequest) async throws -> RestEndpoint.RefreshResponse {
        try await Endpoint(baseURL: baseURL)
            .post("refresh")
            .body(request, encoder: Self.jsonEncoder)
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
        
        endpoint = endpoint.parameter(key: "limit", value: String(pagination.limit ?? 32768))
        endpoint = endpoint.parameter(key: "offset", value: String(pagination.offset ?? 0))
        
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
        
        endpoint = endpoint.parameter(key: "limit", value: String(pagination.limit ?? 32768))
        endpoint = endpoint.parameter(key: "offset", value: String(pagination.offset ?? 0))
        
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
        
        endpoint = endpoint.parameter(key: "limit", value: String(pagination.limit ?? 32768))
        endpoint = endpoint.parameter(key: "offset", value: String(pagination.offset ?? 0))
        
        return try await endpoint.call(decoder: Self.jsonDecoder, isDataWrapped: false)
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
        
        endpoint = endpoint.parameter(key: "limit", value: String(pagination.limit ?? 32768))
        endpoint = endpoint.parameter(key: "offset", value: String(pagination.offset ?? 0))
        
        return try await endpoint.call(decoder: Self.jsonDecoder, isDataWrapped: false)
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
        
        endpoint = endpoint.parameter(key: "limit", value: String(pagination.limit ?? 32768))
        endpoint = endpoint.parameter(key: "offset", value: String(pagination.offset ?? 0))
        
        return try await endpoint.call(decoder: Self.jsonDecoder, isDataWrapped: false)
    }
    
    // MARK: - Orders
    
    /// Create new order for product purchase (requires authentication)
    /// - Parameter request: Order creation data with product ID and quantity
    /// - Returns: Order creation response with order ID and remaining points
    /// - Throws: Network, authorization, or insufficient points errors
    func createOrder(_ request: RestEndpoint.OrderCreateRequest) async throws -> RestEndpoint.OrderCreateResponse {
        try await Endpoint(baseURL: baseURL)
            .post("orders")
            .body(request, encoder: Self.jsonEncoder)
            .authenticate(with: authenticator)
            .session(session)
            .call(decoder: Self.jsonDecoder, isDataWrapped: false)
    }
    
    /// Get user's order history (requires authentication)
    /// - Parameter pagination: Optional pagination parameters
    /// - Returns: Orders list with pagination info
    /// - Throws: Network or authorization errors
    func getUserOrders(_ pagination: RestEndpoint.PaginationRequest = RestEndpoint.PaginationRequest()) async throws -> RestEndpoint.OrdersResponse {
        var endpoint = Endpoint(baseURL: baseURL)
            .get("user/orders")
            .authenticate(with: authenticator)
            .session(session)
        
        endpoint = endpoint.parameter(key: "limit", value: String(pagination.limit ?? 32768))
        endpoint = endpoint.parameter(key: "offset", value: String(pagination.offset ?? 0))
        
        return try await endpoint.call(decoder: Self.jsonDecoder, isDataWrapped: false)
    }
    
    // MARK: - Support Messages
    
    /// Send message to support (requires authentication)
    /// - Parameter request: Support message request with content and optional subject
    /// - Returns: Support message response with ticket ID and message info
    /// - Throws: Network or authorization errors
    func sendSupportMessage(_ request: RestEndpoint.SupportMessageRequest) async throws -> RestEndpoint.SupportMessageResponse {
        try await Endpoint(baseURL: baseURL)
            .post("support/messages")
            .body(request, encoder: Self.jsonEncoder)
            .authenticate(with: authenticator)
            .session(session)
            .call(decoder: Self.jsonDecoder, isDataWrapped: false)
    }
    
    /// Get user's support messages (requires authentication)
    /// - Parameter request: Optional polling request with since timestamp
    /// - Returns: Support messages list
    /// - Throws: Network or authorization errors
    func getSupportMessages(_ request: RestEndpoint.SupportMessagesRequest = RestEndpoint.SupportMessagesRequest()) async throws -> RestEndpoint.SupportMessagesResponse {
        var endpoint = Endpoint(baseURL: baseURL)
            .get("support/messages")
            .authenticate(with: authenticator)
            .session(session)
        
        if let since = request.since {
            endpoint = endpoint.parameter(key: "since", value: since)
        }
        endpoint = endpoint.parameter(key: "limit", value: String(request.limit ?? 32768))
        
        return try await endpoint.call(decoder: Self.jsonDecoder, isDataWrapped: false)
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
