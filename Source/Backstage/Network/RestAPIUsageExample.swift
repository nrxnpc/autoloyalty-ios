import Foundation
import Endpoint

// MARK: - REST API Usage Examples

/// Example showing how to use the new RestEndpoint with EndpointBuilder DSL
class RestAPIUsageExample {
    
    private let networkManager = NetworkManagerV2.shared
    
    // MARK: - Authentication Examples
    
    func loginExample() async {
        do {
            let user = try await networkManager.login(
                email: "customer@nsp.com",
                password: "password123"
            )
            print("Logged in user: \(user.name)")
        } catch {
            print("Login failed: \(error)")
        }
    }
    
    func registerExample() async {
        let userData = UserRegistration(
            name: "Новый пользователь",
            email: "newuser@example.com",
            phone: "+7 (999) 123-45-67",
            password: "password123",
            userType: "individual"
        )
        
        do {
            let user = try await networkManager.register(userData: userData)
            print("Registered user: \(user.name)")
        } catch {
            print("Registration failed: \(error)")
        }
    }
    
    // MARK: - Product Examples
    
    func getProductsExample() async {
        do {
            // Get all products
            let allProducts = try await networkManager.getProducts()
            print("Total products: \(allProducts.count)")
            
            // Get products by category
            let merchandiseProducts = try await networkManager.getProducts(
                category: "merchandise",
                isActive: true
            )
            print("Merchandise products: \(merchandiseProducts.count)")
        } catch {
            print("Failed to get products: \(error)")
        }
    }
    
    func createProductExample() async {
        let newProduct = CreateProductRequest(
            name: "Новые тормозные колодки",
            category: "merchandise",
            pointsCost: 500,
            imageURL: "https://example.com/brake-pads.jpg",
            description: "Высококачественные тормозные колодки",
            stockQuantity: 25,
            deliveryOptions: ["pickup", "delivery"],
            supplierId: "supplier-001"
        )
        
        do {
            let product = try await networkManager.createProduct(newProduct)
            print("Created product: \(product.name)")
        } catch {
            print("Failed to create product: \(error)")
        }
    }
    
    // MARK: - QR Code Examples
    
    func scanQRCodeExample() async {
        let scanRequest = QRScanRequest(
            qrCode: "QR123456789",
            userId: "customer-001",
            timestamp: Date().ISO8601String,
            location: "Москва"
        )
        
        do {
            let response = try await networkManager.scanQRCode(request: scanRequest)
            if response.success, let scan = response.scan {
                print("QR scan successful: +\(scan.pointsEarned) points for \(scan.productName)")
            }
        } catch {
            print("QR scan failed: \(error)")
        }
    }
    
    func getUserScansExample() async {
        do {
            let scans = try await networkManager.getUserScans(
                userId: "customer-001",
                limit: 10,
                offset: 0
            )
            print("User has \(scans.count) QR scans")
        } catch {
            print("Failed to get user scans: \(error)")
        }
    }
    
    // MARK: - Order Examples
    
    func createOrderExample() async {
        let orderRequest = CreateOrderRequest(
            userId: "customer-001",
            productId: "product-001",
            pointsSpent: 500,
            deliveryOption: "delivery",
            deliveryAddress: "ул. Примерная, д. 123, кв. 45"
        )
        
        do {
            let order = try await networkManager.createOrder(orderRequest)
            print("Created order: \(order.id)")
        } catch {
            print("Failed to create order: \(error)")
        }
    }
    
    func getUserOrdersExample() async {
        do {
            // Get all orders
            let allOrders = try await networkManager.getUserOrders(userId: "customer-001")
            print("User has \(allOrders.count) orders")
            
            // Get pending orders only
            let pendingOrders = try await networkManager.getUserOrders(
                userId: "customer-001",
                status: "pending"
            )
            print("Pending orders: \(pendingOrders.count)")
        } catch {
            print("Failed to get user orders: \(error)")
        }
    }
    
    // MARK: - Price Request Examples
    
    func createPriceRequestExample() async {
        let priceRequest = CreatePriceRequestRequest(
            userId: "customer-001",
            carId: "car-001",
            userMessage: "Интересует цена на этот автомобиль"
        )
        
        do {
            let request = try await networkManager.createPriceRequest(priceRequest)
            print("Created price request: \(request.id)")
        } catch {
            print("Failed to create price request: \(error)")
        }
    }
    
    // MARK: - Support Examples
    
    func createSupportTicketExample() async {
        let ticketRequest = CreateSupportTicketRequest(
            userId: "customer-001",
            subject: "Проблема с заказом",
            priority: "medium",
            initialMessage: "У меня проблема с заказом #12345"
        )
        
        do {
            let ticket = try await networkManager.createSupportTicket(ticketRequest)
            print("Created support ticket: \(ticket.id)")
        } catch {
            print("Failed to create support ticket: \(error)")
        }
    }
    
    func addSupportMessageExample() async {
        let messageRequest = CreateSupportMessageRequest(
            content: "Дополнительная информация по проблеме",
            senderId: "customer-001",
            senderRole: "customer",
            attachments: []
        )
        
        do {
            let message = try await networkManager.addSupportMessage(
                ticketId: "ticket-001",
                message: messageRequest
            )
            print("Added support message: \(message.id)")
        } catch {
            print("Failed to add support message: \(error)")
        }
    }
    
    // MARK: - Moderation Examples
    
    func moderationExample() async {
        do {
            // Get products pending moderation
            let pendingProducts = try await networkManager.getModerationProducts(status: "pending")
            print("Products pending moderation: \(pendingProducts.count)")
            
            // Approve a product
            if let firstProduct = pendingProducts.first {
                let approvedProduct = try await networkManager.approveProduct(productId: firstProduct.id)
                print("Approved product: \(approvedProduct.name)")
            }
            
            // Get news pending moderation
            let pendingNews = try await networkManager.getModerationNews(status: "pending")
            print("News pending moderation: \(pendingNews.count)")
            
        } catch {
            print("Moderation operations failed: \(error)")
        }
    }
    
    // MARK: - Batch Operations Example
    
    func batchOperationsExample() async {
        do {
            // Perform multiple operations concurrently
            async let products = networkManager.getProducts(isActive: true)
            async let news = networkManager.getNews(isPublished: true)
            async let lotteries = networkManager.getLotteries(isActive: true)
            
            let (productList, newsList, lotteryList) = try await (products, news, lotteries)
            
            print("Loaded: \(productList.count) products, \(newsList.count) news, \(lotteryList.count) lotteries")
            
        } catch {
            print("Batch operations failed: \(error)")
        }
    }
    
    // MARK: - Error Handling Example
    
    func errorHandlingExample() async {
        do {
            let user = try await networkManager.getUserProfile()
            print("User profile: \(user.name)")
        } catch NetworkError.unauthorized {
            print("User needs to login again")
            // Handle authentication error
        } catch NetworkError.networkUnavailable {
            print("Network is unavailable, using cached data")
            // Handle offline mode
        } catch NetworkError.serverError(let code) {
            print("Server error with code: \(code)")
            // Handle server errors
        } catch {
            print("Unexpected error: \(error)")
        }
    }
}

// MARK: - Direct RestEndpoint Usage Example

/// Example showing direct usage of RestEndpoint without NetworkManager wrapper
class DirectRestEndpointExample {
    
    func directUsageExample() async {
        let baseURL = URL(string: "https://api.autoloyalty.ru/v1")!
        
        // Create authenticator
        let authenticator = BearerTokenAuthenticator {
            return await TokenManager.shared.getToken()
        }
        
        // Create REST endpoint
        let api = RestEndpoint(baseURL: baseURL, authenticator: authenticator)
        
        do {
            // Direct API calls using the DSL
            let products = try await api.getProducts(category: "merchandise", isActive: true)
            print("Found \(products.count) merchandise products")
            
            let news = try await api.getNews(isPublished: true, isImportant: false)
            print("Found \(news.count) published news articles")
            
        } catch {
            print("Direct API call failed: \(error)")
        }
    }
    
    func customEndpointExample() async {
        let baseURL = URL(string: "https://api.autoloyalty.ru/v1")!
        
        do {
            // Using the raw Endpoint DSL for custom requests
            let customData: [String: Any] = try await Endpoint(baseURL: baseURL)
                .get("custom/endpoint")
                .parameter(key: "filter", value: "active")
                .parameter(key: "limit", value: "50")
                .call()
            
            print("Custom endpoint response: \(customData)")
            
        } catch {
            print("Custom endpoint failed: \(error)")
        }
    }
}