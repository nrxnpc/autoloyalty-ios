import Foundation
import Endpoint

/// NSP Auto Loyalty Program API Client
public final class RestEndpoint: EndpointBuilder, @unchecked Sendable {
    internal let baseURL: URL
    internal let authenticator: ProxyAuthenticator
    internal let session: SessionProtocol

    internal init(baseURL: URL, session: SessionProtocol) {
        self.baseURL = baseURL
        self.authenticator = ProxyAuthenticator()
        self.session = session
    }
    
    // MARK: - Authentication Management
    
    /// Set authenticator to unauthenticated mode
    public func setUnauthenticated() {
        authenticator.setAuthenticator(UnauthenticatedAuthenticator())
    }
    
    /// Set authenticator to use bearer token
    public func setBearerToken(provider: @escaping () async -> String?) {
        authenticator.setAuthenticator(BearerTokenAuthenticator(tokenProvider: provider))
    }
    
    /// Set authenticator to use auto-refresh bearer token
    public func setAutoRefreshToken(
        tokenProvider: @escaping () async -> String?,
        refreshAction: @escaping () async throws -> Void
    ) {
        let autoRefreshAuth = AutoRefreshAuthenticator(
            tokenProvider: tokenProvider,
            refreshAction: refreshAction
        )
        authenticator.setAuthenticator(autoRefreshAuth)
    }
}

// MARK: - API Methods
public extension RestEndpoint {
    
    // MARK: - System Health
    
    func healthCheck() async throws -> RestEndpoint.HealthResponse {
        try await Endpoint(baseURL: baseURL)
            .get("health")
            .session(session)
            .call(decoder: Self.jsonDecoder, isDataWrapped: false)
    }
    
    // MARK: - Authentication & Account Management
    
    func register(_ request: RestEndpoint.UserRegistration) async throws -> RestEndpoint.AuthResponse {
        try await Endpoint(baseURL: baseURL)
            .post("register")
            .body(request, encoder: Self.jsonEncoder)
            .session(session)
            .call(decoder: Self.jsonDecoder, isDataWrapped: false)
    }
    
    func login(_ credentials: RestEndpoint.LoginCredentials) async throws -> RestEndpoint.AuthResponse {
        try await Endpoint(baseURL: baseURL)
            .post("login")
            .body(credentials, encoder: Self.jsonEncoder)
            .session(session)
            .call(decoder: Self.jsonDecoder, isDataWrapped: false)
    }
    
    func deleteUser(_ userID: String) async throws -> RestEndpoint.SuccessResponse {
        try await Endpoint(baseURL: baseURL)
            .delete("users/\(userID)")
            .authenticate(with: authenticator)
            .session(session)
            .call(decoder: Self.jsonDecoder, isDataWrapped: false)
    }
    
    // MARK: - QR Code Operations
    
    func scanQRCode(_ request: RestEndpoint.QRScanRequest) async throws -> RestEndpoint.QRScanResponse {
        try await Endpoint(baseURL: baseURL)
            .post("scan")
            .body(request, encoder: Self.jsonEncoder)
            .authenticate(with: authenticator)
            .session(session)
            .call(decoder: Self.jsonDecoder, isDataWrapped: false)
    }
    
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
    
    func addProduct(_ product: RestEndpoint.ProductCreateRequest) async throws -> RestEndpoint.CreateResponse {
        try await Endpoint(baseURL: baseURL)
            .post("products")
            .body(product, encoder: Self.jsonEncoder)
            .authenticate(with: authenticator)
            .session(session)
            .call(decoder: Self.jsonDecoder, isDataWrapped: false)
    }
    
    func deleteProduct(_ productID: String) async throws -> RestEndpoint.SuccessResponse {
        try await Endpoint(baseURL: baseURL)
            .delete("products/\(productID)")
            .authenticate(with: authenticator)
            .session(session)
            .call(decoder: Self.jsonDecoder, isDataWrapped: false)
    }
    
    // MARK: - Car Catalog
    
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
    
    func addCar(_ car: RestEndpoint.CarCreateRequest) async throws -> RestEndpoint.CreateResponse {
        try await Endpoint(baseURL: baseURL)
            .post("cars")
            .body(car, encoder: Self.jsonEncoder)
            .authenticate(with: authenticator)
            .session(session)
            .call(decoder: Self.jsonDecoder, isDataWrapped: false)
    }
    
    func deleteCar(_ carID: String) async throws -> RestEndpoint.SuccessResponse {
        try await Endpoint(baseURL: baseURL)
            .delete("cars/\(carID)")
            .authenticate(with: authenticator)
            .session(session)
            .call(decoder: Self.jsonDecoder, isDataWrapped: false)
    }
    
    // MARK: - News & Articles
    
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
    
    func addNews(_ article: RestEndpoint.NewsCreateRequest) async throws -> RestEndpoint.CreateResponse {
        try await Endpoint(baseURL: baseURL)
            .post("news")
            .body(article, encoder: Self.jsonEncoder)
            .authenticate(with: authenticator)
            .session(session)
            .call(decoder: Self.jsonDecoder, isDataWrapped: false)
    }
    
    func deleteNews(_ newsID: String) async throws -> RestEndpoint.SuccessResponse {
        try await Endpoint(baseURL: baseURL)
            .delete("news/\(newsID)")
            .authenticate(with: authenticator)
            .session(session)
            .call(decoder: Self.jsonDecoder, isDataWrapped: false)
    }
    
    // MARK: - Promotional Campaigns
    
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
    
    func createCampaign(_ campaign: RestEndpoint.CampaignCreateRequest) async throws -> RestEndpoint.CreateResponse {
        try await Endpoint(baseURL: baseURL)
            .post("campaigns")
            .body(campaign, encoder: Self.jsonEncoder)
            .authenticate(with: authenticator)
            .session(session)
            .call(decoder: Self.jsonDecoder, isDataWrapped: false)
    }
    
    func deleteCampaign(_ campaignID: String) async throws -> RestEndpoint.SuccessResponse {
        try await Endpoint(baseURL: baseURL)
            .delete("campaigns/\(campaignID)")
            .authenticate(with: authenticator)
            .session(session)
            .call(decoder: Self.jsonDecoder, isDataWrapped: false)
    }
    
    // MARK: - Point Transactions
    
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
    
    func getCompanyAnalytics() async throws -> RestEndpoint.CompanyAnalyticsResponse {
        try await Endpoint(baseURL: baseURL)
            .get("company/analytics")
            .authenticate(with: authenticator)
            .session(session)
            .call(decoder: Self.jsonDecoder, isDataWrapped: false)
    }
}

// MARK: - JSON Configuration
internal extension RestEndpoint {
    /// A shared JSON decoder configured for snake_case keys
    static let jsonDecoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()
    
    /// A shared JSON encoder configured for snake_case keys
    static let jsonEncoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        return encoder
    }()
}