import Foundation
import Combine
import Dependencies

@MainActor
class DataManager: ObservableObject {
    @Dependency(\.endpoint) var endpoint: RestEndpoint
    
    @Published var carsState = CollectionState<Car>()
    @Published var productsState = CollectionState<Product>()
    @Published var usersState = CollectionState<User>()
    @Published var ordersState = CollectionState<Order>()
    @Published var priceRequestsState = CollectionState<PriceRequest>()
    @Published var newsState = CollectionState<NewsArticle>()
    @Published var lotteriesState = CollectionState<Lottery>()
    @Published var pointTransactionsState = CollectionState<PointTransaction>()
    @Published var supportTicketsState = CollectionState<SupportTicket>()
    @Published var qrScansState = CollectionState<QRScanResult>()
    
    private var loadedDataTypes: Set<DataType> = []
    private var cancellables = Set<AnyCancellable>()
    
    enum DataType: CaseIterable {
        case cars, products, users, orders, priceRequests, news, lotteries, pointTransactions, supportTickets, qrScans
    }
    
    init() {
        // Подписываемся на выход пользователя для очистки данных
        NotificationCenter.default.publisher(for: .userLoggedOut)
            .sink { [weak self] _ in
                Task { @MainActor in
                    self?.clearAllData()
                }
            }
            .store(in: &cancellables)
        
        // Подписываемся на регистрацию нового пользователя
        NotificationCenter.default.publisher(for: .userRegistered)
            .sink { [weak self] notification in
                if let user = notification.object as? User {
                    Task { @MainActor in
                        self?.addUser(user)
                    }
                }
            }
            .store(in: &cancellables)
    }
    
    // Ленивая загрузка всех необходимых данных
    func loadDataIfNeeded() async {
        for dataType in DataType.allCases {
            if !loadedDataTypes.contains(dataType) {
                await loadDataType(dataType)
            }
        }
    }
    
    // Загружаем конкретный тип данных только когда он нужен
    func loadDataType(_ type: DataType) async {
        guard !loadedDataTypes.contains(type) else { return }
        loadedDataTypes.insert(type)
        
        switch type {
        case .cars: await loadCars()
        case .products: await loadProducts()
        case .users: await loadUsers()
        case .orders: await loadOrders()
        case .priceRequests: await loadPriceRequests()
        case .news: await loadNews()
        case .lotteries: await loadLotteries()
        case .pointTransactions: await loadPointTransactions()
        case .supportTickets: await loadSupportTickets()
        case .qrScans: await loadQRScans()
        }
    }
    
    // MARK: - Private Loading Methods
    private func loadCars() async {
        await carsState.loadItems {
            do {
                let response = try await self.endpoint.getCars()
                return response.cars.map { $0.toCar() }
            } catch {
                return DemoDataLoader.loadCars()
            }
        }
    }
    
    private func loadProducts() async {
        await productsState.loadItems {
            do {
                let response = try await self.endpoint.getProducts()
                return response.products.map { $0.toProduct() }
            } catch {
                return DemoDataLoader.loadProducts()
            }
        }
    }
    
    private func loadUsers() async {
        await usersState.loadItems {
            return DemoDataLoader.loadUsers()
        }
    }
    
    private func loadOrders() async {
        await ordersState.loadItems {
            return DemoDataLoader.loadOrders()
        }
    }
    
    private func loadPriceRequests() async {
        await priceRequestsState.loadItems {
            return DemoDataLoader.loadPriceRequests()
        }
    }
    
    private func loadNews() async {
        await newsState.loadItems {
            do {
                let response = try await self.endpoint.getNews()
                return response.news.map { $0.toNewsArticle() }
            } catch {
                return DemoDataLoader.loadNews()
            }
        }
    }
    
    private func loadLotteries() async {
        await lotteriesState.loadItems {
            return DemoDataLoader.loadLotteries()
        }
    }
    
    private func loadPointTransactions() async {
        await pointTransactionsState.loadItems {
            do {
                let response = try await self.endpoint.getUserTransactions()
                return response.transactions.map { $0.toPointTransaction() }
            } catch {
                return DemoDataLoader.loadPointTransactions()
            }
        }
    }
    
    private func loadSupportTickets() async {
        await supportTicketsState.loadItems {
            return DemoDataLoader.loadSupportTickets()
        }
    }
    
    private func loadQRScans() async {
        await qrScansState.loadItems {
            do {
                let response = try await self.endpoint.getUserScans()
                return response.scans.map { $0.toQRScanResult() }
            } catch {
                return DemoDataLoader.loadQRScans()
            }
        }
    }
    
    // MARK: - QR Code Processing
    func processQRScan(code: String, userId: String) async -> QRScanResult? {
        do {
            let request = QRScanRequest(qr_code: code, location: "Москва")
            let response = try await endpoint.scanQRCode(request: request)
            
            if response.valid, let scanId = response.scan_id, let productName = response.product_name {
                return QRScanResult(
                    id: scanId,
                    pointsEarned: response.points_earned ?? 0,
                    productName: productName,
                    productCategory: response.product_category ?? "",
                    timestamp: Date(),
                    qrCode: code,
                    location: "Москва"
                )
            }
            
            return await processQRScanLocally(code: code, userId: userId)
            
        } catch {
            return await processQRScanLocally(code: code, userId: userId)
        }
    }
    
    private func processQRScanLocally(code: String, userId: String) async -> QRScanResult {
        return await Task.detached(priority: .utility) {
            let pointsEarned = Int.random(in: 10...100)
            let productNames = ["Тормозные колодки Brembo", "Масляный фильтр Mann", "Свечи зажигания NGK", "Амортизаторы Bilstein", "Воздушный фильтр K&N"]
            let categories = ["Тормозная система", "Система смазки", "Система зажигания", "Подвеска", "Система впуска"]
            
            let randomIndex = Int.random(in: 0..<productNames.count)
            
            return QRScanResult(
                id: UUID().uuidString,
                pointsEarned: pointsEarned,
                productName: productNames[randomIndex],
                productCategory: categories[randomIndex],
                timestamp: Date(),
                qrCode: code,
                location: "Москва"
            )
        }.value
    }
    
    func addQRScan(_ scan: QRScanResult) {
        qrScansState.addItem(scan)
    }
    
    // MARK: - CRUD операции
    func addCar(_ car: Car) {
        carsState.addItem(car)
    }
    
    func updateCar(_ car: Car) {
        carsState.updateItem(car)
    }
    
    func deleteCar(_ carId: String) {
        carsState.removeItem(withId: carId)
    }
    
    func addProduct(_ product: Product) {
        productsState.addItem(product)
    }
    
    func updateProduct(_ product: Product) {
        productsState.updateItem(product)
    }
    
    func deleteProduct(_ productId: String) {
        productsState.removeItem(withId: productId)
    }
    
    func addUser(_ user: User) {
        usersState.addItem(user)
    }
    
    func updateUser(_ user: User) {
        usersState.updateItem(user)
    }
    
    func deleteUser(_ userId: String) {
        usersState.removeItem(withId: userId)
    }
    
    func addNews(_ news: NewsArticle) {
        newsState.addItem(news)
    }
    
    func updateNews(_ news: NewsArticle) {
        newsState.updateItem(news)
    }
    
    func deleteNews(_ newsId: String) {
        newsState.removeItem(withId: newsId)
    }
    
    func addLottery(_ lottery: Lottery) {
        lotteriesState.addItem(lottery)
    }
    
    func updateLottery(_ lottery: Lottery) {
        lotteriesState.updateItem(lottery)
    }
    
    func deleteLottery(_ lotteryId: String) {
        lotteriesState.removeItem(withId: lotteryId)
    }
    
    func createPriceRequest(userId: String, car: Car, message: String?) -> PriceRequest {
        let request = PriceRequest(
            id: UUID().uuidString,
            userId: userId,
            car: car,
            userMessage: message,
            status: .pending,
            createdAt: Date(),
            dealerResponse: nil,
            estimatedPrice: nil,
            respondedAt: nil
        )
        priceRequestsState.addItem(request)
        return request
    }
    
    func addOrder(userId: String, product: Product, deliveryOption: Product.DeliveryOption, deliveryAddress: String?) -> Order {
        let order = Order(
            id: UUID().uuidString,
            userId: userId,
            product: product,
            pointsSpent: product.pointsCost,
            status: .pending,
            createdAt: Date(),
            deliveryAddress: deliveryAddress,
            deliveryOption: deliveryOption
        )
        ordersState.addItem(order)
        return order
    }
    
    func addPointTransaction(userId: String, type: PointTransaction.TransactionType, amount: Int, description: String, relatedId: String? = nil) {
        let transaction = PointTransaction(
            id: UUID().uuidString,
            userId: userId,
            type: type,
            amount: amount,
            description: description,
            timestamp: Date(),
            relatedId: relatedId
        )
        pointTransactionsState.addItem(transaction)
    }
    
    func clearAllData() {
        loadedDataTypes.removeAll()
        carsState = CollectionState<Car>()
        productsState = CollectionState<Product>()
        usersState = CollectionState<User>()
        ordersState = CollectionState<Order>()
        priceRequestsState = CollectionState<PriceRequest>()
        newsState = CollectionState<NewsArticle>()
        lotteriesState = CollectionState<Lottery>()
        pointTransactionsState = CollectionState<PointTransaction>()
        supportTicketsState = CollectionState<SupportTicket>()
        qrScansState = CollectionState<QRScanResult>()
    }
}

// MARK: - Extension methods for model conversion
extension RestEndpoint.Car {
    func toCar() -> Car {
        return Car(
            id: id,
            brand: brand,
            model: model,
            year: year,
            price: price,
            imageURL: imageURL,
            description: description,
            specifications: Car.CarSpecifications(
                engine: specifications.engine,
                transmission: specifications.transmission,
                fuelType: specifications.fuelType,
                bodyType: specifications.bodyType,
                drivetrain: specifications.drivetrain,
                color: specifications.color
            ),
            isActive: isActive,
            createdAt: ISO8601DateFormatter().date(from: createdAt) ?? Date()
        )
    }
}

extension RestEndpoint.Product {
    func toProduct() -> Product {
        return Product(
            id: id,
            name: name,
            category: Product.ProductCategory(rawValue: category) ?? .merchandise,
            pointsCost: pointsCost,
            imageURL: imageURL,
            description: description,
            stockQuantity: stockQuantity,
            isActive: isActive,
            status: .pending,
            createdAt: ISO8601DateFormatter().date(from: createdAt) ?? Date(),
            deliveryOptions: deliveryOptions.compactMap { Product.DeliveryOption(rawValue: $0) }, supplierId: nil
        )
    }
}

extension RestEndpoint.NewsArticle {
    func toNewsArticle() -> NewsArticle {
        return NewsArticle(
            id: id,
            title: title,
            content: content,
            imageURL: imageURL,
            isImportant: isImportant,
            createdAt: ISO8601DateFormatter().date(from: createdAt) ?? Date(),
            publishedAt: publishedAt.flatMap { ISO8601DateFormatter().date(from: $0) },
            isPublished: isPublished, status: .pending,
            authorId: authorId!,
            tags: tags
        )
    }
}

extension RestEndpoint.PointTransaction {
    func toPointTransaction() -> PointTransaction {
        return PointTransaction(
            id: id,
            userId: userId,
            type: PointTransaction.TransactionType(rawValue: type) ?? .earned,
            amount: amount,
            description: description,
            timestamp: ISO8601DateFormatter().date(from: timestamp) ?? Date(),
            relatedId: relatedId
        )
    }
}

extension RestEndpoint.UserScan {
    func toQRScanResult() -> QRScanResult {
        return QRScanResult(
            id: id,
            pointsEarned: points_earned,
            productName: product_name,
            productCategory: product_category,
            timestamp: ISO8601DateFormatter().date(from: timestamp) ?? Date(),
            qrCode: qr_code,
            location: location
        )
    }
}
