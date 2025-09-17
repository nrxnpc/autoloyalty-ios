import Foundation
import Combine
import Endpoint

// MARK: - Enhanced Network Manager using RestEndpoint
@MainActor
class NetworkManagerV2: ObservableObject {
    static let shared = NetworkManagerV2()
    
    @Published var isConnected = true
    @Published var isLoading = false
    
    private let restEndpoint: RestEndpoint
    private let tokenManager = TokenManager.shared
    
    private init() {
        let baseURL = URL(string: AppConfig.Environment.current.baseURL)!
        
        // Create authenticator with token provider
        let authenticator = BearerTokenAuthenticator { [weak tokenManager] in
            return await tokenManager?.getToken()
        }
        
        self.restEndpoint = RestEndpoint(baseURL: baseURL, authenticator: authenticator)
    }
    
    // MARK: - Authentication Methods
    
    func login(email: String, password: String) async throws -> RestEndpoint.AuthResponse {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let response = try await restEndpoint.login(email: email, password: password)
            if let token = response.token {
                tokenManager.saveToken(token)
            }
            return response
        } catch {
            throw NetworkError.from(error)
        }
    }
    
    func register(userData: RegistrationRequest) async throws -> RestEndpoint.AuthResponse {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let response = try await restEndpoint.register(userData: userData)
            if let token = response.token {
                tokenManager.saveToken(token)
            }
            return response
        } catch {
            throw NetworkError.from(error)
        }
    }
    
    // MARK: - QR Code Methods
    
    func scanQRCode(request: QRScanRequest) async throws -> RestEndpoint.QRScanResponse {
        isLoading = true
        defer { isLoading = false }
        
        do {
            return try await restEndpoint.scanQRCode(request: request)
        } catch {
            throw NetworkError.from(error)
        }
    }
    
    func getUserScans(limit: Int? = nil, offset: Int? = nil) async throws -> RestEndpoint.UserScansResponse {
        isLoading = true
        defer { isLoading = false }
        
        do {
            return try await restEndpoint.getUserScans(limit: limit, offset: offset)
        } catch {
            throw NetworkError.from(error)
        }
    }
    
    // MARK: - Product Methods
    
    func getProducts(limit: Int? = nil, offset: Int? = nil) async throws -> RestEndpoint.ProductsResponse {
        isLoading = true
        defer { isLoading = false }
        
        do {
            return try await restEndpoint.getProducts(limit: limit, offset: offset)
        } catch {
            throw NetworkError.from(error)
        }
    }
    
    // MARK: - Car Methods
    
    func getCars(limit: Int? = nil, offset: Int? = nil) async throws -> RestEndpoint.CarsResponse {
        isLoading = true
        defer { isLoading = false }
        
        do {
            return try await restEndpoint.getCars(limit: limit, offset: offset)
        } catch {
            throw NetworkError.from(error)
        }
    }
    
    func addCar(_ car: CarCreateRequest) async throws -> RestEndpoint.CarCreateResponse {
        do {
            return try await restEndpoint.addCar(car)
        } catch {
            throw NetworkError.from(error)
        }
    }
    
    // MARK: - Transaction Methods
    
    func getUserTransactions(limit: Int? = nil, offset: Int? = nil) async throws -> RestEndpoint.TransactionsResponse {
        isLoading = true
        defer { isLoading = false }
        
        do {
            return try await restEndpoint.getUserTransactions(limit: limit, offset: offset)
        } catch {
            throw NetworkError.from(error)
        }
    }
    
    // MARK: - News Methods
    
    func getNews(limit: Int? = nil, offset: Int? = nil) async throws -> RestEndpoint.NewsResponse {
        isLoading = true
        defer { isLoading = false }
        
        do {
            return try await restEndpoint.getNews(limit: limit, offset: offset)
        } catch {
            throw NetworkError.from(error)
        }
    }
    
    // MARK: - File Upload Methods
    
    func uploadFile(_ file: FileUploadRequest) async throws -> RestEndpoint.FileUploadResponse {
        do {
            return try await restEndpoint.uploadFile(file)
        } catch {
            throw NetworkError.from(error)
        }
    }
    
    func getUploadedFile(filename: String) async throws -> Data {
        do {
            return try await restEndpoint.getUploadedFile(filename: filename)
        } catch {
            throw NetworkError.from(error)
        }
    }
    
    // MARK: - Statistics Methods
    
    func getStatistics() async throws -> RestEndpoint.StatisticsResponse {
        do {
            return try await restEndpoint.getStatistics()
        } catch {
            throw NetworkError.from(error)
        }
    }
    
    // MARK: - Health Check Methods
    
    func healthCheck() async throws -> RestEndpoint.HealthResponse {
        do {
            return try await restEndpoint.healthCheck()
        } catch {
            throw NetworkError.from(error)
        }
    } catch {
            throw NetworkError.from(error)
        }
    }
    
    // MARK: - Support Methods
    
    func getUserSupportTickets(userId: String, status: String? = nil) async throws -> [RestEndpoint.SupportTicket] {
        do {
            return try await restEndpoint.getUserSupportTickets(userId: userId, status: status)
        } catch {
            throw NetworkError.from(error)
        }
    }
    
    func createSupportTicket(_ ticket: CreateSupportTicketRequest) async throws -> RestEndpoint.SupportTicket {
        do {
            return try await restEndpoint.createSupportTicket(ticket)
        } catch {
            throw NetworkError.from(error)
        }
    }
    
    func addSupportMessage(ticketId: String, message: CreateSupportMessageRequest) async throws -> RestEndpoint.SupportMessage {
        do {
            return try await restEndpoint.addSupportMessage(ticketId: ticketId, message: message)
        } catch {
            throw NetworkError.from(error)
        }
    }
    
    // MARK: - Lottery Methods
    
    func getLotteries(isActive: Bool? = nil) async throws -> [RestEndpoint.Lottery] {
        do {
            return try await restEndpoint.getLotteries(isActive: isActive)
        } catch {
            throw NetworkError.from(error)
        }
    }
    
    func participateInLottery(lotteryId: String, userId: String) async throws {
        do {
            try await restEndpoint.participateInLottery(lotteryId: lotteryId, userId: userId)
        } catch {
            throw NetworkError.from(error)
        }
    }
    
    // MARK: - Moderation Methods
    
    func getModerationProducts(status: String? = nil) async throws -> [RestEndpoint.Product] {
        do {
            return try await restEndpoint.getModerationProducts(status: status)
        } catch {
            throw NetworkError.from(error)
        }
    }
    
    func approveProduct(productId: String) async throws -> RestEndpoint.Product {
        do {
            return try await restEndpoint.approveProduct(productId: productId)
        } catch {
            throw NetworkError.from(error)
        }
    }
    
    func rejectProduct(productId: String, reason: String) async throws -> RestEndpoint.Product {
        do {
            return try await restEndpoint.rejectProduct(productId: productId, reason: reason)
        } catch {
            throw NetworkError.from(error)
        }
    }
    
    func getModerationNews(status: String? = nil) async throws -> [RestEndpoint.NewsArticle] {
        do {
            return try await restEndpoint.getModerationNews(status: status)
        } catch {
            throw NetworkError.from(error)
        }
    }
    
    func approveNews(newsId: String) async throws -> RestEndpoint.NewsArticle {
        do {
            return try await restEndpoint.approveNews(newsId: newsId)
        } catch {
            throw NetworkError.from(error)
        }
    }
    
    // MARK: - Utility Methods
    
    var connectionsStatusText: String {
        if isConnected {
            if let lastSync = UserDefaults.standard.lastSyncDate {
                return "Онлайн • Синхронизировано \(lastSync.timeAgoDisplay())"
            } else {
                return "Онлайн • Готов к синхронизации"
            }
        } else {
            return "Оффлайн"
        }
    }
}

// MARK: - Error Mapping Extension

extension NetworkError {
    static func from(_ error: Error) -> NetworkError {
        if let endpointError = error as? EndpointError {
            switch endpointError {
            case .invalidURL:
                return .invalidURL
            case .authenticationFailed:
                return .unauthorized
            case .requestFailed:
                return .networkUnavailable
            case .unexpectedStatusCode(let code):
                return .serverError(code)
            case .decodingFailed:
                return .decodingError
            case .noData:
                return .noData
            }
        }
        return .networkUnavailable
    }
}