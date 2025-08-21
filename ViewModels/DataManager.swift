import Foundation
import Combine

@MainActor
class DataManager: ObservableObject {
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
    
    private let networkManager = NetworkManager.shared
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
            try await Task.detached(priority: .utility) {
                try await Task.sleep(nanoseconds: 100_000_000) // 0.1 сек
                return DemoDataLoader.loadCars()
            }.value
        }
    }
    
    private func loadProducts() async {
        await productsState.loadItems {
            if self.networkManager.isConnected {
                let apiProducts = try await self.networkManager.getProducts()
                return apiProducts.map { $0.toProduct() }
            } else {
                // Загружаем из локального источника если нет сети
                return DemoDataLoader.loadProducts()
            }
        }
    }
    
    private func loadUsers() async {
        await usersState.loadItems {
            if self.networkManager.isConnected {
                let apiUsers = try await self.networkManager.getUsers()
                return apiUsers.map { $0.toUser() }
            } else {
                return DemoDataLoader.loadUsers()
            }
        }
    }
    
    private func loadOrders() async {
        await ordersState.loadItems {
            try await Task.detached(priority: .utility) {
                try await Task.sleep(nanoseconds: 50_000_000)
                return DemoDataLoader.loadOrders()
            }.value
        }
    }
    
    private func loadPriceRequests() async {
        await priceRequestsState.loadItems {
            try await Task.detached(priority: .utility) {
                try await Task.sleep(nanoseconds: 50_000_000)
                return DemoDataLoader.loadPriceRequests()
            }.value
        }
    }
    
    private func loadNews() async {
        await newsState.loadItems {
            if self.networkManager.isConnected {
                let apiNews = try await self.networkManager.getNews()
                return apiNews.map { $0.toNewsArticle() }
            } else {
                return DemoDataLoader.loadNews()
            }
        }
    }
    
    private func loadLotteries() async {
        await lotteriesState.loadItems {
            try await Task.detached(priority: .utility) {
                try await Task.sleep(nanoseconds: 50_000_000)
                return DemoDataLoader.loadLotteries()
            }.value
        }
    }
    
    private func loadPointTransactions() async {
        await pointTransactionsState.loadItems {
            if self.networkManager.isConnected {
                // В реальном приложении здесь был бы userId из AuthViewModel
                let apiTransactions = try await self.networkManager.getUserTransactions(userId: "current-user")
                return apiTransactions.map { $0.toPointTransaction() }
            } else {
                return DemoDataLoader.loadPointTransactions()
            }
        }
    }
    
    private func loadSupportTickets() async {
        await supportTicketsState.loadItems {
            try await Task.detached(priority: .utility) {
                try await Task.sleep(nanoseconds: 50_000_000)
                return DemoDataLoader.loadSupportTickets()
            }.value
        }
    }
    
    private func loadQRScans() async {
        await qrScansState.loadItems {
            if self.networkManager.isConnected {
                let apiScans = try await self.networkManager.getUserScans(userId: "current-user")
                return apiScans.map { $0.toQRScanResult() }
            } else {
                return DemoDataLoader.loadQRScans()
            }
        }
    }
    
    // MARK: - QR Code Processing
    func processQRScan(code: String, userId: String) async -> QRScanResult? {
        do {
            if networkManager.isConnected {
                let request = QRScanRequest(
                    qrCode: code,
                    userId: userId,
                    timestamp: Date().ISO8601String,
                    location: "Москва" // В реальном приложении получать из GPS
                )
                
                let response = try await networkManager.scanQRCode(request: request)
                
                if response.success, let apiScan = response.scan {
                    return apiScan.toQRScanResult()
                }
            }
            
            // Fallback к локальной обработке если нет сети
            return await processQRScanLocally(code: code, userId: userId)
            
        } catch {
            // При ошибке API обрабатываем локально
            return await processQRScanLocally(code: code, userId: userId)
        }
    }
    
    private func processQRScanLocally(code: String, userId: String) async -> QRScanResult {
        return await Task.detached(priority: .utility) {
            // Симуляция обработки QR-кода
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
        
        // Пытаемся синхронизировать с сервером
        Task {
            do {
                try await networkManager.uploadQRScan(scan)
            } catch {
                // Ошибка синхронизации - данные останутся локально до следующей попытки
                print("Не удалось синхронизировать скан: \(error)")
            }
        }
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
