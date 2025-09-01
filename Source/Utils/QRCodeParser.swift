import Foundation

// MARK: - URL Session Delegate для обхода ATS
class InsecureURLSessionDelegate: NSObject, URLSessionDelegate {
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        completionHandler(.useCredential, URLCredential(trust: challenge.protectionSpace.serverTrust!))
    }
}

struct QRCodeParser {
    
    // Структура QR-кода от бота
    struct BotQRData: Codable {
        let productId: String
        let productName: String
        let category: String
        let points: Int
        let supplierId: String
        let timestamp: String
        let signature: String? // Для проверки подлинности
    }
    
    // Структура ответа от БД бота
    struct BotProductResponse: Codable {
        let id: String
        let name: String
        let category: String
        let points: Int
        let description: String?
        let supplierId: String?
        let isActive: Bool
    }
    
    // Базовый парсинг QR-кода (без запроса к БД)
    static func parseQRCode(_ qrString: String) -> BotQRData? {
        // Если QR-код в формате NSP:ID:Категория:Баллы
        if qrString.hasPrefix("NSP:") {
            return parseNSPFormat(qrString)
        }
        
        // Если QR-код в формате JSON
        if let data = qrString.data(using: .utf8) {
            do {
                let qrData = try JSONDecoder().decode(BotQRData.self, from: data)
                return qrData
            } catch {
                print("Ошибка парсинга QR JSON: \(error)")
            }
        }
        
        // Если QR-код в формате строки (например: "product:123|points:50|name:Brake Pads")
        if qrString.contains("|") {
            return parseStringFormat(qrString)
        }
        
        return nil
    }
    
    private static func parseNSPFormat(_ qrString: String) -> BotQRData? {
        // Формат: NSP:NSP_39A06AF8:Прочее:100
        let components = qrString.components(separatedBy: ":")
        guard components.count >= 4,
              components[0] == "NSP" else {
            return nil
        }
        
        let productId = components[1]
        let category = components[2]
        let points = Int(components[3]) ?? 0
        
        // Используем базовые данные из QR, но лучше запросить из БД
        let productName = extractProductName(from: productId, category: category)
        
        return BotQRData(
            productId: productId,
            productName: productName,
            category: category,
            points: points,
            supplierId: "bot-supplier",
            timestamp: ISO8601DateFormatter().string(from: Date()),
            signature: nil
        )
    }
    
    // Улучшенный парсинг с запросом к БД бота
    static func parseQRCodeWithBotDB(_ qrString: String) async -> QRScanResult? {
        guard let basicData = parseQRCode(qrString) else {
            return nil
        }
        
        // Пытаемся получить точные данные из БД бота
        if let botProduct = await fetchProductFromBot(basicData.productId) {
            return toQRScanResult(botProduct)
        }
        
        // Если БД недоступна, используем базовые данные
        return toQRScanResult(basicData)
    }
    
    private static func extractProductName(from productId: String, category: String) -> String {
        // Извлекаем название из ID или используем категорию
        if productId.contains("_") {
            let parts = productId.components(separatedBy: "_")
            if parts.count > 1 {
                return "Товар \(parts[1])"
            }
        }
        return category
    }
    
    private static func parseStringFormat(_ qrString: String) -> BotQRData? {
        let components = qrString.components(separatedBy: "|")
        var productId = ""
        var productName = ""
        var category = "autoparts"
        var points = 0
        var supplierId = ""
        
        for component in components {
            let keyValue = component.components(separatedBy: ":")
            guard keyValue.count == 2 else { continue }
            
            let key = keyValue[0].lowercased()
            let value = keyValue[1]
            
            switch key {
            case "product", "id":
                productId = value
            case "name", "title":
                productName = value
            case "category", "cat":
                category = value
            case "points", "pts":
                points = Int(value) ?? 0
            case "supplier", "sup":
                supplierId = value
            default:
                break
            }
        }
        
        guard !productId.isEmpty else { return nil }
        
        return BotQRData(
            productId: productId,
            productName: productName.isEmpty ? category : productName,
            category: category,
            points: points,
            supplierId: supplierId.isEmpty ? "unknown-supplier" : supplierId,
            timestamp: ISO8601DateFormatter().string(from: Date()),
            signature: nil
        )
    }
    
    // Запрос данных товара из БД бота
    static func fetchProductFromBot(_ productId: String) async -> BotProductResponse? {
        let urlString = "http://195.189.70.202:8080/api/qr/\(productId)"
        print("[QR Parser] Запрос к боту: \(urlString)")
        
        guard let url = URL(string: urlString) else {
            print("[QR Parser] Ошибка: неверный URL")
            return nil
        }
        
        var request = URLRequest(url: url)
        request.setValue("nsp-mobile-app-key", forHTTPHeaderField: "X-API-Key")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.timeoutInterval = 10.0
        
        do {
            print("[QR Parser] Отправляем запрос...")
            
            // Создаем URLSession с обходом ATS
            let config = URLSessionConfiguration.default
            config.timeoutIntervalForRequest = 10.0
            let delegate = InsecureURLSessionDelegate()
            let session = URLSession(configuration: config, delegate: delegate, delegateQueue: nil)
            
            let (data, response) = try await session.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse {
                print("[QR Parser] Ответ от бота: \(httpResponse.statusCode)")
                if let responseString = String(data: data, encoding: .utf8) {
                    print("[QR Parser] Данные: \(responseString)")
                }
            }
            
            let product = try JSONDecoder().decode(BotProductResponse.self, from: data)
            print("[QR Parser] Успешно получен товар: \(product.name)")
            return product
        } catch {
            print("[QR Parser] Ошибка запроса к БД бота: \(error)")
            return nil
        }
    }
    
    // Конвертация в QRScanResult для приложения
    static func toQRScanResult(_ botData: BotQRData, location: String? = nil) -> QRScanResult {
        return QRScanResult(
            id: UUID().uuidString,
            pointsEarned: botData.points,
            productName: botData.productName,
            productCategory: botData.category,
            timestamp: Date(),
            qrCode: botData.productId,
            location: location
        )
    }
    
    static func toQRScanResult(_ botProduct: BotProductResponse, location: String? = nil) -> QRScanResult {
        return QRScanResult(
            id: UUID().uuidString,
            pointsEarned: botProduct.points,
            productName: botProduct.name,
            productCategory: botProduct.category,
            timestamp: Date(),
            qrCode: botProduct.id,
            location: location
        )
    }
}