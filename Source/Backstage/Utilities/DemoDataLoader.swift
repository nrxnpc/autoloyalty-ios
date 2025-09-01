import Foundation

class DemoDataLoader {
    
    // MARK: - Users
    static func loadUsers() -> [User] {
        let customer = User(
            id: "customer-001",
            name: "Иван Петров",
            email: "customer@nsp.com",
            phone: "+7 (999) 123-45-67",
            userType: .individual,
            points: 2500,
            role: .customer,
            registrationDate: Calendar.current.date(byAdding: .month, value: -6, to: Date()) ?? Date(),
            isActive: true,
            profileImageURL: nil,
            supplierID: nil,
            preferences: User.UserPreferences(
                notificationsEnabled: true,
                emailNotifications: true,
                pushNotifications: true,
                preferredCategories: [.autoparts, .oils]
            ),
            statistics: User.UserStatistics(
                totalPurchases: 15,
                totalSpent: 45000.0,
                averageOrderValue: 3000.0,
                loyaltyTier: "Бронза",
                joinedPromotions: 3,
                createdContent: 0,
                totalPointsEarned: 2500,
                lastActivityDate: Date()
            ),
            lastLoginDate: nil
        )
        
        let supplier = User(
            id: "supplier-001",
            name: "Алексей Козлов",
            email: "supplier@nsp.com",
            phone: "+7 (999) 234-56-78",
            userType: .business,
            points: 0,
            role: .supplier,
            registrationDate: Calendar.current.date(byAdding: .month, value: -4, to: Date()) ?? Date(),
            isActive: true,
            profileImageURL: nil,
            supplierID: nil,
            preferences: User.UserPreferences(
                notificationsEnabled: true,
                emailNotifications: false,
                pushNotifications: true,
                preferredCategories: [.tires, .accessories]
            ),
            statistics: User.UserStatistics(
                totalPurchases: 25,
                totalSpent: 75000.0,
                averageOrderValue: 3000.0,
                loyaltyTier: "Серебро",
                joinedPromotions: 8,
                createdContent: 12,
                totalPointsEarned: 8500,
                lastActivityDate: Date()
            ),
            lastLoginDate: nil
        )
        
        let platformAdmin = User(
            id: "platform-admin-001",
            name: "Дмитрий Смирнов",
            email: "admin@nsp.com",
            phone: "+7 (999) 345-67-89",
            userType: .business,
            points: 0,
            role: .platformAdmin,
            registrationDate: Calendar.current.date(byAdding: .year, value: -1, to: Date()) ?? Date(),
            isActive: true,
            profileImageURL: nil,
            supplierID: "supplier-001",
            preferences: User.UserPreferences(
                notificationsEnabled: true,
                emailNotifications: true,
                pushNotifications: false,
                preferredCategories: []
            ),
            statistics: User.UserStatistics(
                totalPurchases: 0,
                totalSpent: 0.0,
                averageOrderValue: 0.0,
                loyaltyTier: "Н/Д",
                joinedPromotions: 0,
                createdContent: 0,
                totalPointsEarned: 0,
                lastActivityDate: Date()
            ),
            lastLoginDate: nil
        )
        
        return [customer, supplier, platformAdmin]
    }
    
    // MARK: - Products
    static func loadProducts() -> [Product] {
        return [
            Product(
                id: "product-001",
                name: "Тормозные колодки Brembo",
                category: .merchandise,
                pointsCost: 500,
                imageURL: "https://example.com/brake-pads.jpg",
                description: "Высококачественные тормозные колодки для безопасного торможения",
                stockQuantity: 25,
                isActive: true,
                status: .approved,
                createdAt: Date(),
                deliveryOptions: [.pickup, .delivery],
                imageData: nil,
                supplierId: "supplier-001"
            ),
            Product(
                id: "product-002",
                name: "Масляный фильтр Mann",
                category: .merchandise,
                pointsCost: 200,
                imageURL: "https://example.com/oil-filter.jpg",
                description: "Оригинальный масляный фильтр для двигателя",
                stockQuantity: 50,
                isActive: false,
                status: .pending,
                createdAt: Date(),
                deliveryOptions: [.pickup],
                imageData: nil,
                supplierId: "supplier-001"
            )
        ]
    }
    
    // MARK: - Cars
    static func loadCars() -> [Car] {
        return [
            Car(
                id: "car-001",
                brand: "BMW",
                model: "X5",
                year: 2020,
                price: "3 500 000 ₽",
                imageURL: "https://example.com/bmw-x5.jpg",
                description: "Премиальный кроссовер BMW X5 в отличном состоянии",
                specifications: Car.CarSpecifications(
                    engine: "3.0L бензиновый",
                    transmission: "Автоматическая",
                    fuelType: "Бензин",
                    bodyType: "Кроссовер",
                    drivetrain: "Полный",
                    color: "Черный"
                ),
                isActive: true,
                createdAt: Date(),
                imageData: nil
            ),
            Car(
                id: "car-002",
                brand: "Mercedes-Benz",
                model: "C-Class",
                year: 2019,
                price: "2 800 000 ₽",
                imageURL: "https://example.com/mercedes-c.jpg",
                description: "Элегантный седан Mercedes-Benz C-Class с полной комплектацией",
                specifications: Car.CarSpecifications(
                    engine: "2.0L турбо",
                    transmission: "Автоматическая",
                    fuelType: "Бензин",
                    bodyType: "Седан",
                    drivetrain: "Задний",
                    color: "Белый"
                ),
                isActive: true,
                createdAt: Date(),
                imageData: nil
            ),
            Car(
                id: "car-003",
                brand: "Audi",
                model: "Q7",
                year: 2021,
                price: "4 200 000 ₽",
                imageURL: "https://example.com/audi-q7.jpg",
                description: "Роскошный внедорожник Audi Q7 с передовыми технологиями",
                specifications: Car.CarSpecifications(
                    engine: "3.0L V6 турбо",
                    transmission: "Автоматическая",
                    fuelType: "Бензин",
                    bodyType: "Внедорожник",
                    drivetrain: "Полный",
                    color: "Серый"
                ),
                isActive: true,
                createdAt: Date(),
                imageData: nil
            ),
            Car(
                id: "car-004",
                brand: "Toyota",
                model: "Camry",
                year: 2022,
                price: "2 100 000 ₽",
                imageURL: "https://example.com/toyota-camry.jpg",
                description: "Надежный седан Toyota Camry с гибридной силовой установкой",
                specifications: Car.CarSpecifications(
                    engine: "2.5L гибрид",
                    transmission: "Вариатор",
                    fuelType: "Гибрид",
                    bodyType: "Седан",
                    drivetrain: "Передний",
                    color: "Синий"
                ),
                isActive: true,
                createdAt: Date(),
                imageData: nil
            ),
            Car(
                id: "car-005",
                brand: "Volkswagen",
                model: "Tiguan",
                year: 2018,
                price: "1 950 000 ₽",
                imageURL: "https://example.com/vw-tiguan.jpg",
                description: "Практичный кроссовер Volkswagen Tiguan в хорошем состоянии",
                specifications: Car.CarSpecifications(
                    engine: "2.0L турбо",
                    transmission: "Автоматическая",
                    fuelType: "Бензин",
                    bodyType: "Кроссовер",
                    drivetrain: "Полный",
                    color: "Красный"
                ),
                isActive: true,
                createdAt: Date(),
                imageData: nil
            )
        ]
    }
    
    // MARK: - News
    static func loadNews() -> [NewsArticle] {
        return [
            NewsArticle(
                id: "news-001",
                title: "Новые поступления автозапчастей",
                content: "В нашем каталоге появились новые качественные запчасти от ведущих производителей.",
                imageURL: "https://example.com/news1.jpg",
                isImportant: true,
                createdAt: Date(),
                publishedAt: Date(),
                isPublished: true,
                status: .approved,
                authorId: "platform-admin-001",
                tags: ["новости", "запчасти"],
                imageData: nil
            ),
            NewsArticle(
                id: "news-002",
                title: "Новая линейка фильтров",
                content: "Представляем новую линейку высококачественных фильтров.",
                imageURL: "https://example.com/news2.jpg",
                isImportant: false,
                createdAt: Date(),
                publishedAt: nil,
                isPublished: false,
                status: .pending,
                authorId: "supplier-001",
                tags: ["фильтры"],
                imageData: nil
            )
        ]
    }
    
    // MARK: - QR Scans
    static func loadQRScans() -> [QRScanResult] {
        return [
            QRScanResult(
                id: "scan-001",
                pointsEarned: 50,
                productName: "Тормозные колодки",
                productCategory: "Тормозная система",
                timestamp: Date(),
                qrCode: "QR123456789",
                location: "Москва"
            )
        ]
    }
    
    // MARK: - Point Transactions
    static func loadPointTransactions() -> [PointTransaction] {
        return [
            PointTransaction(
                id: "transaction-001",
                userId: "customer-001",
                type: .earned,
                amount: 50,
                description: "Сканирование QR-кода",
                timestamp: Date(),
                relatedId: "scan-001"
            )
        ]
    }
    
    // MARK: - Orders
    static func loadOrders() -> [Order] {
        return []
    }
    
    // MARK: - Price Requests
    static func loadPriceRequests() -> [PriceRequest] {
        return []
    }
    
    // MARK: - Lotteries
    static func loadLotteries() -> [Lottery] {
        return [
            Lottery(
                id: "lottery-001",
                title: "Розыгрыш iPhone 15 Pro",
                description: "Участвуйте в розыгрыше нового iPhone 15 Pro!",
                prize: "iPhone 15 Pro 256GB",
                startDate: Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date(),
                endDate: Calendar.current.date(byAdding: .day, value: 14, to: Date()) ?? Date(),
                isActive: true,
                participants: ["customer-001"],
                winnerId: nil,
                minPointsRequired: 100,
                createdAt: Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date(),
                imageData: nil
            ),
            Lottery(
                id: "lottery-002",
                title: "Набор автозапчастей",
                description: "Выиграйте полный набор автозапчастей!",
                prize: "Набор запчастей на 50,000 рублей",
                startDate: Calendar.current.date(byAdding: .day, value: -3, to: Date()) ?? Date(),
                endDate: Calendar.current.date(byAdding: .day, value: 10, to: Date()) ?? Date(),
                isActive: true,
                participants: [],
                winnerId: nil,
                minPointsRequired: 50,
                createdAt: Calendar.current.date(byAdding: .day, value: -3, to: Date()) ?? Date(),
                imageData: nil
            )
        ]
    }
    
    // MARK: - Support Tickets
    static func loadSupportTickets() -> [SupportTicket] {
        return []
    }
}