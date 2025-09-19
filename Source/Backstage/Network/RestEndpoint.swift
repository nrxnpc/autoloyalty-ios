import Endpoint
import Foundation

// MARK: - REST API Client
public struct RestEndpoint: EndpointBuilder {
    private let baseURL: URL
    private let authenticator: (any Authenticator)?
    
    public init(baseURL: URL, authenticator: (any Authenticator)? = nil) {
        self.baseURL = baseURL
        self.authenticator = authenticator
    }
}

// MARK: - Authentication Endpoints
extension RestEndpoint {
    /// POST /api/v1/login
    func login(email: String, password: String, deviceInfo: String? = nil) async throws -> RestEndpoint.AuthResponse {
        let request = LoginRequest(email: email, password: password, deviceInfo: deviceInfo)
        
        return try await Endpoint(baseURL: baseURL)
            .post("api/v1/login")
            .body(request)
            .header("X-API-Key", "nsp_mobile_app_api_key_2024")
            .call()
    }
    
    /// POST /api/v1/register
    func register(userData: RegistrationRequest) async throws -> RestEndpoint.AuthResponse {
        return try await Endpoint(baseURL: baseURL)
            .post("api/v1/register")
            .body(userData)
            .header("X-API-Key", "nsp_mobile_app_api_key_2024")
            .call()
    }
    
    /// GET /health
    func healthCheck() async throws -> RestEndpoint.HealthResponse {
        return try await Endpoint(baseURL: baseURL)
            .get("health")
            .call()
    }
}

// MARK: - QR Code Endpoints
extension RestEndpoint {
    /// POST /api/v1/scan
    func scanQRCode(request: QRScanRequest) async throws -> RestEndpoint.QRScanResponse {
        return try await Endpoint(baseURL: baseURL)
            .post("api/v1/scan")
            .body(request)
            .header("X-API-Key", "nsp_mobile_app_api_key_2024")
            .authenticate(with: authenticator!)
            .call()
    }
    
    /// GET /api/v1/user/scans
    func getUserScans(limit: Int? = nil, offset: Int? = nil) async throws -> RestEndpoint.UserScansResponse {
        var endpoint = Endpoint(baseURL: baseURL).get("api/v1/user/scans")
        
        if let limit = limit {
            //  Value of type 'EndpointConfigurator' has no member 'query'
            endpoint = endpoint.parameter(key: "limit", value: String(limit))
        }
        if let offset = offset {
            endpoint = endpoint.parameter(key: "offset", value: String(offset))
        }
        
        return try await endpoint
            .header("X-API-Key", "nsp_mobile_app_api_key_2024")
            .authenticate(with: authenticator!)
            .call()
    }
}

// MARK: - Product Endpoints
extension RestEndpoint {
    /// GET /api/v1/products
    func getProducts(limit: Int? = nil, offset: Int? = nil) async throws -> RestEndpoint.ProductsResponse {
        var endpoint = Endpoint(baseURL: baseURL).get("api/v1/products")
        
        if let limit = limit {
            endpoint = endpoint.parameter(key: "limit", value: String(limit))
        }
        if let offset = offset {
            endpoint = endpoint.parameter(key: "offset", value: String(offset))
        }
        
        return try await endpoint
            .header("X-API-Key", "nsp_mobile_app_api_key_2024")
            .call()
    }
    
    /// POST /api/v1/products
    func addProduct(_ product: ProductCreateRequest) async throws -> RestEndpoint.ProductCreateResponse {
        return try await Endpoint(baseURL: baseURL)
            .post("api/v1/products")
            .body(product)
            .header("X-API-Key", "nsp_mobile_app_api_key_2024")
            .authenticate(with: authenticator!)
            .call()
    }
}

// MARK: - Car Endpoints
extension RestEndpoint {
    /// GET /api/v1/cars
    func getCars(limit: Int? = nil, offset: Int? = nil) async throws -> RestEndpoint.CarsResponse {
        var endpoint = Endpoint(baseURL: baseURL).get("api/v1/cars")
        
        if let limit = limit {
            endpoint = endpoint.parameter(key: "limit", value: String(limit))
        }
        if let offset = offset {
            endpoint = endpoint.parameter(key: "offset", value: String(offset))
        }
        
        return try await endpoint
            .header("X-API-Key", "nsp_mobile_app_api_key_2024")
            .call()
    }
    
    /// POST /api/v1/cars
    func addCar(_ car: CarCreateRequest) async throws -> RestEndpoint.CarCreateResponse {
        return try await Endpoint(baseURL: baseURL)
            .post("api/v1/cars")
            .body(car)
            .header("X-API-Key", "nsp_mobile_app_api_key_2024")
            .authenticate(with: authenticator!)
            .call()
    }
}

// MARK: - Transaction Endpoints
extension RestEndpoint {
    /// GET /api/v1/user/transactions
    func getUserTransactions(limit: Int? = nil, offset: Int? = nil) async throws -> RestEndpoint.TransactionsResponse {
        var endpoint = Endpoint(baseURL: baseURL).get("api/v1/user/transactions")
        
        if let limit = limit {
            endpoint = endpoint.parameter(key: "limit", value: String(limit))
        }
        if let offset = offset {
            endpoint = endpoint.parameter(key: "offset", value: String(offset))
        }
        
        return try await endpoint
            .header("X-API-Key", "nsp_mobile_app_api_key_2024")
            .authenticate(with: authenticator!)
            .call()
    }
}

// MARK: - News Endpoints
extension RestEndpoint {
    /// GET /api/v1/news
    func getNews(limit: Int? = nil, offset: Int? = nil) async throws -> RestEndpoint.NewsResponse {
        var endpoint = Endpoint(baseURL: baseURL).get("api/v1/news")
        
        if let limit = limit {
            endpoint = endpoint.parameter(key: "limit", value: String(limit))
        }
        if let offset = offset {
            endpoint = endpoint.parameter(key: "offset", value: String(offset))
        }
        
        return try await endpoint
            .header("X-API-Key", "nsp_mobile_app_api_key_2024")
            .call()
    }
    
    /// POST /api/v1/news
    func addNews(_ news: NewsCreateRequest) async throws -> RestEndpoint.NewsCreateResponse {
        return try await Endpoint(baseURL: baseURL)
            .post("api/v1/news")
            .body(news)
            .header("X-API-Key", "nsp_mobile_app_api_key_2024")
            .authenticate(with: authenticator!)
            .call()
    }
}

// MARK: - Campaign Endpoints
extension RestEndpoint {
    /// GET /api/v1/campaigns
    func getCampaigns(limit: Int? = nil, offset: Int? = nil) async throws -> RestEndpoint.CampaignsResponse {
        var endpoint = Endpoint(baseURL: baseURL).get("api/v1/campaigns")
        
        if let limit = limit {
            endpoint = endpoint.parameter(key: "limit", value: String(limit))
        }
        if let offset = offset {
            endpoint = endpoint.parameter(key: "offset", value: String(offset))
        }
        
        return try await endpoint
            .header("X-API-Key", "nsp_mobile_app_api_key_2024")
            .call()
    }
    
    /// POST /api/v1/campaigns
    func createCampaign(_ campaign: CampaignCreateRequest) async throws -> RestEndpoint.CampaignCreateResponse {
        return try await Endpoint(baseURL: baseURL)
            .post("api/v1/campaigns")
            .body(campaign)
            .header("X-API-Key", "nsp_mobile_app_api_key_2024")
            .authenticate(with: authenticator!)
            .call()
    }
}

// MARK: - Analytics Endpoints
extension RestEndpoint {
    /// GET /api/v1/company/analytics
    func getCompanyAnalytics() async throws -> RestEndpoint.CompanyAnalyticsResponse {
        return try await Endpoint(baseURL: baseURL)
            .get("api/v1/company/analytics")
            .header("X-API-Key", "nsp_mobile_app_api_key_2024")
            .authenticate(with: authenticator!)
            .call()
    }
}

// MARK: - File Upload Endpoints
extension RestEndpoint {
    /// POST /api/v1/upload
    func uploadFile(_ file: FileUploadRequest) async throws -> RestEndpoint.FileUploadResponse {
        return try await Endpoint(baseURL: baseURL)
            .post("api/v1/upload")
            .body(file)
            .header("X-API-Key", "nsp_mobile_app_api_key_2024")
            .authenticate(with: authenticator!)
            .call()
    }
    
    /// GET /uploads/{filename}
    func getUploadedFile(filename: String) async throws -> Data {
        return try await Endpoint(baseURL: baseURL)
            .get("uploads/\(filename)")
            .call()
    }
}

// MARK: - Statistics Endpoints
extension RestEndpoint {
    /// GET /api/v1/statistics
    func getStatistics() async throws -> RestEndpoint.StatisticsResponse {
        return try await Endpoint(baseURL: baseURL)
            .get("api/v1/statistics")
            .header("X-API-Key", "nsp_mobile_app_api_key_2024")
            .call()
    }
}
