import Foundation
import ScopeGraph

public struct CreateBuiltInCatalogUseCase {
    private let scope: Scope
    public init(scope: Scope) {
        self.scope = scope
    }
    
    public func execute() async throws {
        let context = scope.createBackgroundContext()
        
        let products = try context.fetch(Product.allDrafts())
        guard products.isEmpty else {
            return
        }
        
        try await context.perform {
            let request =  Product.allProductsFetchRequest()
            let products = try context.fetch(request)
            guard products.isEmpty else {
                for product in products {
                    context.delete(product)
                }
                try context.save()
                return
            }
        }
        
        try await context.perform {
            let rawProducts = [
                ("Пакет ПВД", "Надежный полиэтиленовый пакет для повседневного использования, мероприятий и брендированной раздачи. Подходит для упаковки сувенирной продукции, документов и промоматериалов. Хорошо держит форму и выдерживает нагрузку.", "Упаковка", 50, 200, "https://firebasestorage.googleapis.com/v0/b/note-mess-8a48b.firebasestorage.app/o/nsp-content-pack%2F46C20FCE-D6ED-454D-BD8A-F1FAEA747A9A.jpg?alt=media&token=87f7576b-6d9e-4079-8ba4-c75efb4a49e8"),
                ("Пакет бумажный", "Элегантный бумажный пакет с премиальной soft-touch ламинацией. Используется для презентации подарков, деловых наборов и корпоративных сувениров. Приятный на ощупь, подчеркивает статус бренда.", "Упаковка", 100, 100, "https://firebasestorage.googleapis.com/v0/b/note-mess-8a48b.firebasestorage.app/o/nsp-content-pack%2FFB3697C2-9AB6-417D-A1B5-E10621283145.jpg?alt=media&token=cd609ade-c1eb-4c44-8e08-c705f1183b16"),
                ("Ручка шариковая soft-touch", "Удобная шариковая ручка с матовым soft-touch покрытием, обеспечивающим комфортный захват. Подходит для ежедневного использования в офисе, на встречах и мероприятиях.", "Канцелярия", 75, 300, "https://firebasestorage.googleapis.com/v0/b/note-mess-8a48b.firebasestorage.app/o/nsp-content-pack%2FBC344743-CE6E-44CE-970B-08CFBD46681C.jpg?alt=media&token=140009bc-b059-4aa2-821c-a2c9da028db9"),
                ("Блокнот А5 на пружине", "Функциональный блокнот для рабочих заметок, планирования и записей на встречах. Плотная обложка с ламинацией защищает блок от повреждений.", "Канцелярия", 150, 250, "https://firebasestorage.googleapis.com/v0/b/note-mess-8a48b.firebasestorage.app/o/nsp-content-pack%2F32D1C286-DBAB-4494-A5A6-5E8188D586F1.jpg?alt=media&token=927e088d-b0e6-4ba6-9305-36e2c29af88c"),
                ("Ежедневник Favor", "Классический недатированный ежедневник для планирования задач, встреч и личных целей. Лаконичный дизайн и качественная обложка делают его удобным рабочим инструментом.", "Канцелярия", 300, 100, "https://firebasestorage.googleapis.com/v0/b/note-mess-8a48b.firebasestorage.app/o/nsp-content-pack%2F0B662476-E4E2-4A3D-B465-8DCDB84FC29F.png?alt=media&token=a891b4f0-4ccb-443e-bac9-03218ea7d53d"),
                ("Футболка Sol's Imperial", "Универсальная хлопковая футболка с плотной тканью и комфортной посадкой. Подходит для повседневной носки, корпоративных мероприятий, промоакций и работы.", "Одежда", 400, 300, "https://firebasestorage.googleapis.com/v0/b/note-mess-8a48b.firebasestorage.app/o/nsp-content-pack%2F5B4DFD9A-0399-4F0E-B167-C4237092D442.png?alt=media&token=2b339c5e-9e5e-4a3d-a7d8-ea30cec8acd8"),
                ("Стальная кружка с двойными стенками", "Практичная кружка для горячих и холодных напитков. Двойные стенки помогают дольше сохранять температуру, а корпус из нержавеющей стали обеспечивает прочность и долговечность.", "Посуда", 800, 100, "https://firebasestorage.googleapis.com/v0/b/note-mess-8a48b.firebasestorage.app/o/nsp-content-pack%2F6432567D-12C8-4828-AFFB-F56399A23CCB.jpg?alt=media&token=21266d72-1ded-45bb-96e7-95d7f369bc8c"),
                ("Мультитул", "Компактный многофункциональный инструмент для повседневных задач, поездок и экстренных ситуаций. Полезный и запоминающийся сувенир, который всегда под рукой.", "Инструменты", 1200, 100, "https://firebasestorage.googleapis.com/v0/b/note-mess-8a48b.firebasestorage.app/o/nsp-content-pack%2FCF2BFBA4-817E-40BC-A289-B56CB1F1B5EF.png?alt=media&token=140f72d3-ec12-4fc7-bc4c-9c4b5355fee3"),
                ("Перчатки рабочие комбинированные", "Прочные рабочие перчатки для защиты рук при ремонте, обслуживании техники и работе в гараже. Комбинированные материалы обеспечивают баланс прочности, комфорта и износостойкости.", "Защита", 200, 500, "")
            ]
            
            for (name, description, category, pointsCost, stockQuantity, imageURL) in rawProducts {
                let product = Product(context: context)
                product.sync.isDraft = true
                product.name = name
                product.productDescription = description
                product.category = category
                product.pointsCost = pointsCost
                product.stockQuantity = stockQuantity
                product.isActive = true
                product.isOutOfStock = false
                product.isFavorite = false
                if !imageURL.isEmpty, let url = URL(string: imageURL) {
                    product.images = [.fromURL(url, in: context)]
                }
            }
            
            if context.hasChanges {
                try context.save()
            }
        }
    }
}
