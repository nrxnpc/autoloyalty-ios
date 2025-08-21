import Foundation

struct AppConfig {
    // MARK: - API Configuration
    static let baseURL = Environment.current.baseURL
    
    // MARK: - Endpoints
    struct Endpoints {
        static let auth = "/auth"
        static let login = "/auth/login"
        static let register = "/auth/register"
        static let refresh = "/auth/refresh"
        
        static let users = "/users"
        static let profile = "/users/profile"
        
        static let products = "/products"
        static let cars = "/cars"
        static let news = "/news"
        static let qrScans = "/qr-scans"
        static let transactions = "/transactions"
        static let lotteries = "/lotteries"
        static let support = "/support"
        
        static let moderation = "/moderation"
        static let moderationProducts = "/moderation/products"
        static let moderationNews = "/moderation/news"
    }
    
    // MARK: - Network Configuration
    static let requestTimeout: TimeInterval = 30.0
    static let resourceTimeout: TimeInterval = 60.0
    
    // URLSession для HTTP запросов (разрешает незащищенные соединения)
    static var httpSession: URLSession {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = requestTimeout
        config.timeoutIntervalForResource = resourceTimeout
        return URLSession(configuration: config)
    }
    
    // MARK: - Cache Configuration
    static let cacheMaxAge: TimeInterval = 300 // 5 минут
    static let imageCacheMaxSize = 100 * 1024 * 1024 // 100MB
    
    // MARK: - Environment
    enum Environment {
        case development
        case staging
        case production
        
        static var current: Environment {
            #if DEBUG
            return .development
            #else
            return .production
            #endif
        }
        
        var baseURL: String {
            switch self {
            case .development:
                return "http://localhost:3000/api"
            case .staging:
                return "https://staging-api.autoloyalty.ru/v1"
            case .production:
                return "https://api.autoloyalty.ru/v1"
            }
        }
    }
    
    // MARK: - Feature Flags
    struct Features {
        static let enableOfflineMode = false
        static let enablePushNotifications = true
        static let enableAnalytics = true
        static let enableCrashReporting = true
        static let enableDemoMode = false
    }
}