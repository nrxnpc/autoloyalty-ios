import CoreData

extension Sweepstakes {
    static func fillInDemo(context: NSManagedObjectContext) async throws {
        try await context.perform {
            let imageURL = URL(string: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSAJAsKTm8YK-JkPs8rcs87qY2_wD4fEG-j2A&s")!
            
            let products = try context.fetch(Product.allProductsFetchRequest())
            guard !products.isEmpty else { return }
            
            let account = try context.fetch(Account.current()).first
            guard let account else { return }
            
            // Active sweepstakes - iPhone 15 Pro
            let iphone = Sweepstakes(context: context)
            iphone.title = "Розыгрыш iPhone 15 Pro"
            iphone.promoDescription = "Сканируйте QR-коды и выигрывайте новейший iPhone 15 Pro с титановым корпусом"
            iphone.status = .active
            iphone.entryCondition = .minScans
            iphone.requiredValue = 10
            iphone.startDate = Calendar.current.date(byAdding: .day, value: -7, to: .now)!
            iphone.endDate = Calendar.current.date(byAdding: .day, value: 14, to: .now)!
            iphone.images = [Attachment.fromURL(imageURL, in: context)]
            if let prize = products.first(where: { $0.name.contains("iPhone") }) {
                iphone.prizes = [prize]
            }
            
            // Active sweepstakes - AirPods
            let airpods = Sweepstakes(context: context)
            airpods.title = "Еженедельный розыгрыш AirPods"
            airpods.promoDescription = "Каждую неделю разыгрываем беспроводные наушники AirPods Pro"
            airpods.status = .active
            airpods.entryCondition = .minScans
            airpods.requiredValue = 3
            airpods.startDate = Calendar.current.date(byAdding: .day, value: -3, to: .now)!
            airpods.endDate = Calendar.current.date(byAdding: .day, value: 4, to: .now)!
            airpods.images = [Attachment.fromURL(imageURL, in: context)]
            if let prize = products.first(where: { $0.name.contains("AirPods") }) {
                airpods.prizes = [prize]
            }
            
            // Upcoming sweepstakes - New Year
            let newYear = Sweepstakes(context: context)
            newYear.title = "Новогодний розыгрыш"
            newYear.promoDescription = "Грандиозный новогодний розыгрыш призов! Участие бесплатное для всех"
            newYear.status = .draft
            newYear.entryCondition = .free
            newYear.requiredValue = 0
            newYear.startDate = Calendar.current.date(byAdding: .day, value: 5, to: .now)!
            newYear.endDate = Calendar.current.date(byAdding: .day, value: 35, to: .now)!
            newYear.images = [Attachment.fromURL(imageURL, in: context)]
            if products.count >= 3 {
                newYear.prizes = Set(products.prefix(3))
            }
            
            // Finished sweepstakes - MacBook
            let macbook = Sweepstakes(context: context)
            macbook.title = "Розыгрыш MacBook Air M2"
            macbook.promoDescription = "Накопите баллы и участвуйте в розыгрыше ультратонкого ноутбука"
            macbook.status = .finished
            macbook.entryCondition = .minPoints
            macbook.requiredValue = 5000
            macbook.startDate = Calendar.current.date(byAdding: .day, value: -30, to: .now)!
            macbook.endDate = Calendar.current.date(byAdding: .day, value: -5, to: .now)!
            macbook.images = [Attachment.fromURL(imageURL, in: context)]
            if let prize = products.first(where: { $0.name.contains("MacBook") }) {
                macbook.prizes = [prize]
            }
            
            // Create demo entries
            let entry1 = SweepstakesEntry(context: context)
            entry1.sweepstakes = iphone
            entry1.account = account
            entry1.entryDate = Calendar.current.date(byAdding: .day, value: -5, to: .now)!
            entry1.isWinner = false
            
            let entry2 = SweepstakesEntry(context: context)
            entry2.sweepstakes = airpods
            entry2.account = account
            entry2.entryDate = Calendar.current.date(byAdding: .day, value: -2, to: .now)!
            entry2.isWinner = false
            
            let entry3 = SweepstakesEntry(context: context)
            entry3.sweepstakes = macbook
            entry3.account = account
            entry3.entryDate = Calendar.current.date(byAdding: .day, value: -20, to: .now)!
            entry3.isWinner = true
            if let prize = products.first(where: { $0.name.contains("MacBook") }) {
                entry3.wonProduct = prize
            }
            
            try context.save()
        }
    }
}
