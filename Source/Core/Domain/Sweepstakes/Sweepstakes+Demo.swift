import CoreData

extension Sweepstakes {
    static func fillInDemo(context: NSManagedObjectContext) async throws {
        try await context.perform {
            let imageURL = URL(string: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSAJAsKTm8YK-JkPs8rcs87qY2_wD4fEG-j2A&s")!
            
            let products = try context.fetch(Product.allProductsFetchRequest())
            guard !products.isEmpty else { return }
            
            let account = try context.fetch(Account.current()).first
            guard let account else { return }
            
            let calendar = Calendar.current
            let now = Date()
            
            // Current month start
            let startOfCurrentMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: now))!
            
            // MARK: - Active Sweepstakes (Current Month - March)
            
            // Active #1 - iPhone 15 Pro (started early March, ends late March)
            let iphone = Sweepstakes(context: context)
            iphone.title = "Розыгрыш iPhone 15 Pro"
            iphone.promoDescription = "Сканируйте QR-коды и выигрывайте новейший iPhone 15 Pro с титановым корпусом"
            iphone.status = .active
            iphone.entryCondition = .minScans
            iphone.requiredValue = 10
            iphone.startDate = calendar.date(byAdding: .day, value: 5, to: startOfCurrentMonth)!
            iphone.endDate = calendar.date(byAdding: .day, value: 25, to: startOfCurrentMonth)!
            iphone.images = [Attachment.fromURL(imageURL, in: context)]
            if let prize = products.first(where: { $0.name.contains("iPhone") }) {
                iphone.prizes = [prize]
            }
            
            // Active #2 - AirPods (started mid March, ends end of March)
            let airpods = Sweepstakes(context: context)
            airpods.title = "Еженедельный розыгрыш AirPods"
            airpods.promoDescription = "Каждую неделю разыгрываем беспроводные наушники AirPods Pro"
            airpods.status = .active
            airpods.entryCondition = .minScans
            airpods.requiredValue = 3
            airpods.startDate = calendar.date(byAdding: .day, value: 15, to: startOfCurrentMonth)!
            airpods.endDate = calendar.date(byAdding: .day, value: 28, to: startOfCurrentMonth)!
            airpods.images = [Attachment.fromURL(imageURL, in: context)]
            if let prize = products.first(where: { $0.name.contains("AirPods") }) {
                airpods.prizes = [prize]
            }
            
            // MARK: - Upcoming Sweepstakes
            
            // Draft #1 - Next Month (April)
            let aprilGiveaway = Sweepstakes(context: context)
            aprilGiveaway.title = "Весенний розыгрыш Apple Watch"
            aprilGiveaway.promoDescription = "Встречайте весну с новыми Apple Watch Series 9! Бесплатное участие для всех"
            aprilGiveaway.status = .draft
            aprilGiveaway.entryCondition = .free
            aprilGiveaway.requiredValue = 0
            aprilGiveaway.startDate = calendar.date(byAdding: .month, value: 1, to: startOfCurrentMonth)!
            aprilGiveaway.endDate = calendar.date(byAdding: DateComponents(month: 1, day: 20), to: startOfCurrentMonth)!
            aprilGiveaway.images = [Attachment.fromURL(imageURL, in: context)]
            if let prize = products.first(where: { $0.name.contains("Watch") }) {
                aprilGiveaway.prizes = [prize]
            }
            
            // Draft #2 - +2 Months (May)
            let mayGiveaway = Sweepstakes(context: context)
            mayGiveaway.title = "Майский розыгрыш iPad Pro"
            mayGiveaway.promoDescription = "Грандиозный майский розыгрыш! Выиграйте iPad Pro 12.9 для работы и творчества"
            mayGiveaway.status = .draft
            mayGiveaway.entryCondition = .minPoints
            mayGiveaway.requiredValue = 3000
            mayGiveaway.startDate = calendar.date(byAdding: .month, value: 2, to: startOfCurrentMonth)!
            mayGiveaway.endDate = calendar.date(byAdding: DateComponents(month: 2, day: 25), to: startOfCurrentMonth)!
            mayGiveaway.images = [Attachment.fromURL(imageURL, in: context)]
            if let prize = products.first(where: { $0.name.contains("iPad") }) {
                mayGiveaway.prizes = [prize]
            }
            
            // MARK: - Finished Sweepstakes
            
            // Finished #1 - Previous Month (February)
            let februaryGiveaway = Sweepstakes(context: context)
            februaryGiveaway.title = "Февральский розыгрыш Magic Keyboard"
            februaryGiveaway.promoDescription = "Розыгрыш беспроводной клавиатуры Magic Keyboard для Mac и iPad"
            februaryGiveaway.status = .finished
            februaryGiveaway.entryCondition = .minScans
            februaryGiveaway.requiredValue = 5
            februaryGiveaway.startDate = calendar.date(byAdding: .month, value: -1, to: startOfCurrentMonth)!
            februaryGiveaway.endDate = calendar.date(byAdding: DateComponents(month: -1, day: 25), to: startOfCurrentMonth)!
            februaryGiveaway.images = [Attachment.fromURL(imageURL, in: context)]
            if let prize = products.first(where: { $0.name.contains("Keyboard") }) {
                februaryGiveaway.prizes = [prize]
            }
            
            // Finished #2 - -2 Months (January) - User WON!
            let januaryGiveaway = Sweepstakes(context: context)
            januaryGiveaway.title = "Новогодний розыгрыш MacBook Air M2"
            januaryGiveaway.promoDescription = "Грандиозный новогодний розыгрыш! Накопите баллы и выиграйте ультратонкий ноутбук"
            januaryGiveaway.status = .finished
            januaryGiveaway.entryCondition = .minPoints
            januaryGiveaway.requiredValue = 5000
            januaryGiveaway.startDate = calendar.date(byAdding: .month, value: -2, to: startOfCurrentMonth)!
            januaryGiveaway.endDate = calendar.date(byAdding: DateComponents(month: -2, day: 28), to: startOfCurrentMonth)!
            januaryGiveaway.images = [Attachment.fromURL(imageURL, in: context)]
            if let prize = products.first(where: { $0.name.contains("MacBook") }) {
                januaryGiveaway.prizes = [prize]
            }
            
            // MARK: - Create Demo Entries
            
            // Entry for iPhone (active, not winner)
            let entry1 = SweepstakesEntry(context: context)
            entry1.sweepstakes = iphone
            entry1.account = account
            entry1.entryDate = calendar.date(byAdding: .day, value: 7, to: startOfCurrentMonth)!
            entry1.isWinner = false
            
            // Entry for AirPods (active, not winner)
            let entry2 = SweepstakesEntry(context: context)
            entry2.sweepstakes = airpods
            entry2.account = account
            entry2.entryDate = calendar.date(byAdding: .day, value: 16, to: startOfCurrentMonth)!
            entry2.isWinner = false
            
            // Entry for February (finished, not winner)
            let entry3 = SweepstakesEntry(context: context)
            entry3.sweepstakes = februaryGiveaway
            entry3.account = account
            entry3.entryDate = calendar.date(byAdding: DateComponents(month: -1, day: 10), to: startOfCurrentMonth)!
            entry3.isWinner = false
            
            // Entry for January (finished, WINNER!)
            let entry4 = SweepstakesEntry(context: context)
            entry4.sweepstakes = januaryGiveaway
            entry4.account = account
            entry4.entryDate = calendar.date(byAdding: DateComponents(month: -2, day: 15), to: startOfCurrentMonth)!
            entry4.isWinner = true
            if let prize = products.first(where: { $0.name.contains("MacBook") }) {
                entry4.wonProduct = prize
            }
            
            try context.save()
        }
    }
}
