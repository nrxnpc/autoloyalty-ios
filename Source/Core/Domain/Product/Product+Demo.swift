import CoreData

extension Product {
    static func fillInDemo(context: NSManagedObjectContext) async throws {
        try await context.perform {
            let products = [
                ("iPhone 15 Pro", "Новейший смартфон Apple с титановым корпусом", 15000),
                ("AirPods Pro", "Беспроводные наушники с активным шумоподавлением", 3500),
                ("MacBook Air M2", "Ультратонкий ноутбук для работы и творчества", 25000),
                ("Apple Watch Series 9", "Умные часы с передовыми функциями здоровья", 8000),
                ("iPad Pro 12.9", "Профессиональный планшет для креативных задач", 18000),
                ("Magic Keyboard", "Беспроводная клавиатура для Mac и iPad", 2500),
                ("Studio Display", "27-дюймовый 5K дисплей для профессионалов", 35000),
                ("HomePod mini", "Умная колонка с отличным звуком", 1800)
            ]
            let imageURL = URL(string: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSAJAsKTm8YK-JkPs8rcs87qY2_wD4fEG-j2A&s")!
            
            for (name, description, cost) in products {
                let product = Product(context: context)
                product.name = name
                product.productDescription = description
                product.pointsCost = cost
                product.images = [
                    Attachment.fromURL(imageURL, in: context)
                ]
            }
            
            try context.save()
        }
    }
}
