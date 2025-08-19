import Foundation

struct DemoDataLoader {
    
    // MARK: - Cars
    static func loadCars() -> [Car] {
        return [
            Car(
                id: "1",
                brand: "BMW",
                model: "X5",
                year: 2023,
                price: "от 4 500 000₽",
                imageURL: "",
                description: "Премиум кроссовер с мощным двигателем",
                specifications: Car.CarSpecifications(
                    engine: "3.0L Twin Turbo",
                    transmission: "Автомат",
                    fuelType: "Бензин",
                    bodyType: "Кроссовер",
                    drivetrain: "Полный привод",
                    color: "Чёрный"
                ),
                isActive: true,
                createdAt: Date()
            ),
            
            Car(
                id: "2",
                brand: "Mercedes",
                model: "C-Class",
                year: 2023,
                price: "от 3 200 000₽",
                imageURL: "",
                description: "Элегантный бизнес седан",
                specifications: Car.CarSpecifications(
                    engine: "2.0L Turbo",
                    transmission: "Автомат",
                    fuelType: "Бензин",
                    bodyType: "Седан",
                    drivetrain: "Задний привод",
                    color: "Серебристый"
                ),
                isActive: true,
                createdAt: Date()
            ),
            
            Car(
                id: "3",
                brand: "Audi",
                model: "A4",
                year: 2024,
                price: "от 2 800 000₽",
                imageURL: "",
                description: "Современный бизнес седан с передовыми технологиями",
                specifications: Car.CarSpecifications(
                    engine: "2.0L TFSI",
                    transmission: "S-tronic",
                    fuelType: "Бензин",
                    bodyType: "Седан",
                    drivetrain: "Quattro",
                    color: "Белый"
                ),
                isActive: true,
                createdAt: Date()
            )
        ]
    }
    
    // MARK: - Products
    static func loadProducts() -> [Product] {
        return [
            Product(
                id: "1",
                name: "Кружка NSP",
                category: .merchandise,
                pointsCost: 200,
                imageURL: "",
                description: "Фирменная керамическая кружка с логотипом NSP",
                stockQuantity: 50,
                isActive: true,
                createdAt: Date(),
                deliveryOptions: [.pickup, .delivery]
            ),
            
            Product(
                id: "2",
                name: "Футболка NSP",
                category: .merchandise,
                pointsCost: 500,
                imageURL: "",
                description: "Качественная футболка из 100% хлопка",
                stockQuantity: 30,
                isActive: true,
                createdAt: Date(),
                deliveryOptions: [.pickup, .delivery]
            ),
            
            Product(
                id: "3",
                name: "Скидка 15%",
                category: .discounts,
                pointsCost: 300,
                imageURL: "",
                description: "Скидка 15% на следующую покупку запчастей",
                stockQuantity: 100,
                isActive: true,
                createdAt: Date(),
                deliveryOptions: [.digital]
            ),
            
            Product(
                id: "4",
                name: "Брелок NSP",
                category: .accessories,
                pointsCost: 150,
                imageURL: "",
                description: "Стильный металлический брелок с логотипом",
                stockQuantity: 75,
                isActive: true,
                createdAt: Date(),
                deliveryOptions: [.pickup, .delivery]
            ),
            
            Product(
                id: "5",
                name: "Диагностика автомобиля",
                category: .services,
                pointsCost: 800,
                imageURL: "",
                description: "Полная компьютерная диагностика автомобиля",
                stockQuantity: 20,
                isActive: true,
                createdAt: Date(),
                deliveryOptions: [.pickup]
            )
        ]
    }
    
    // MARK: - Users
    static func loadUsers() -> [User] {
        return [
            User(
                id: "1",
                name: "Иван Петров",
                email: "ivan@example.com",
                phone: "+7 (999) 123-45-67",
                userType: .individual,
                points: 1250,
                role: .user,
                registrationDate: Date().addingTimeInterval(-86400 * 30),
                isActive: true
            ),
            
            User(
                id: "2",
                name: "Анна Сидорова",
                email: "anna@example.com",
                phone: "+7 (999) 234-56-78",
                userType: .individual,
                points: 850,
                role: .user,
                registrationDate: Date().addingTimeInterval(-86400 * 15),
                isActive: true
            ),
            
            User(
                id: "3",
                name: "ООО \"Автозапчасти\"",
                email: "info@autoparts.com",
                phone: "+7 (999) 345-67-89",
                userType: .business,
                points: 3200,
                role: .user,
                registrationDate: Date().addingTimeInterval(-86400 * 60),
                isActive: true
            )
        ]
    }
    
    // MARK: - News
    static func loadNews() -> [NewsArticle] {
        return [
            NewsArticle(
                id: "1",
                title: "Новая программа лояльности!",
                content: "Мы запустили обновлённую программу лояльности с увеличенными бонусами за сканирование QR-кодов. Теперь вы можете получать до 100 баллов за каждое сканирование!",
                imageURL: "",
                isImportant: true,
                createdAt: Date().addingTimeInterval(-86400 * 3),
                publishedAt: Date().addingTimeInterval(-86400 * 3),
                isPublished: true,
                authorId: "admin-1",
                tags: ["новости", "программа лояльности"]
            ),
            
            NewsArticle(
                id: "2",
                title: "Розыгрыш iPhone 15 Pro",
                content: "Участвуйте в розыгрыше iPhone 15 Pro! Для участия необходимо набрать минимум 100 баллов до конца месяца. Победитель будет выбран случайным образом.",
                imageURL: "",
                isImportant: false,
                createdAt: Date().addingTimeInterval(-86400 * 5),
                publishedAt: Date().addingTimeInterval(-86400 * 5),
                isPublished: true,
                authorId: "admin-1",
                tags: ["розыгрыш", "приз"]
            ),
            
            NewsArticle(
                id: "3",
                title: "Новые товары в каталоге",
                content: "В каталоге появились новые товары: фирменные толстовки, автомобильные коврики и много других интересных призов. Обменивайте баллы на полезные подарки!",
                imageURL: "",
                isImportant: false,
                createdAt: Date().addingTimeInterval(-86400 * 7),
                publishedAt: Date().addingTimeInterval(-86400 * 7),
                isPublished: true,
                authorId: "admin-1",
                tags: ["каталог", "товары"]
            )
        ]
    }
    
    // MARK: - Lotteries
    static func loadLotteries() -> [Lottery] {
        return [
            Lottery(
                id: "1",
                title: "iPhone 15 Pro",
                description: "Розыгрыш iPhone 15 Pro среди активных пользователей",
                prize: "iPhone 15 Pro 256GB",
                startDate: Date().addingTimeInterval(-86400 * 10),
                endDate: Date().addingTimeInterval(86400 * 20),
                isActive: true,
                participants: ["1", "2", "3"],
                winnerId: nil,
                minPointsRequired: 100,
                createdAt: Date()
            ),
            
            Lottery(
                id: "2",
                title: "Набор автомобильных инструментов",
                description: "Профессиональный набор инструментов для автомобилистов",
                prize: "Набор инструментов 120 предметов",
                startDate: Date().addingTimeInterval(86400 * 5),
                endDate: Date().addingTimeInterval(86400 * 35),
                isActive: true,
                participants: [],
                winnerId: nil,
                minPointsRequired: 50,
                createdAt: Date()
            )
        ]
    }
    
    // MARK: - Point Transactions
    static func loadPointTransactions() -> [PointTransaction] {
        return [
            PointTransaction(
                id: "1",
                userId: "1",
                type: .earned,
                amount: 50,
                description: "Сканирование QR-кода (Тормозные колодки)",
                timestamp: Date().addingTimeInterval(-3600),
                relatedId: "scan-1"
            ),
            
            PointTransaction(
                id: "2",
                userId: "1",
                type: .earned,
                amount: 75,
                description: "Сканирование QR-кода (Масляный фильтр)",
                timestamp: Date().addingTimeInterval(-7200),
                relatedId: "scan-2"
            ),
            
            PointTransaction(
                id: "3",
                userId: "1",
                type: .spent,
                amount: 200,
                description: "Обмен на кружку NSP",
                timestamp: Date().addingTimeInterval(-86400),
                relatedId: "order-1"
            )
        ]
    }
    
    // MARK: - QR Scans
    static func loadQRScans() -> [QRScanResult] {
        return [
            QRScanResult(
                id: "1",
                pointsEarned: 50,
                productName: "Тормозные колодки Brembo",
                productCategory: "Тормозная система",
                timestamp: Date().addingTimeInterval(-3600),
                qrCode: "QR1234567890",
                location: "Москва"
            ),
            
            QRScanResult(
                id: "2",
                pointsEarned: 75,
                productName: "Масляный фильтр Mann",
                productCategory: "Система смазки",
                timestamp: Date().addingTimeInterval(-7200),
                qrCode: "QR0987654321",
                location: "Москва"
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
    
    // MARK: - Support Tickets
    static func loadSupportTickets() -> [SupportTicket] {
        return [
            SupportTicket(
                id: "1",
                userId: "1",
                subject: "Проблема со сканированием QR-кода",
                messages: [
                    SupportMessage(
                        id: "1",
                        content: "Не могу отсканировать QR-код с упаковки масляного фильтра",
                        senderId: "1",
                        senderRole: .user,
                        timestamp: Date().addingTimeInterval(-3600),
                        attachments: []
                    )
                ],
                status: .open,
                createdAt: Date().addingTimeInterval(-3600),
                updatedAt: Date().addingTimeInterval(-3600),
                priority: .medium
            )
        ]
    }
}
