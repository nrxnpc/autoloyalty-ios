import CoreData

extension Sweepstakes {
    static func fillInDemo(context: NSManagedObjectContext) async throws {
        try await context.perform {
            
            let products = try context.fetch(Product.allProductsFetchRequest())
            guard !products.isEmpty else { return }
            
            let account = try context.fetch(Account.current()).first
            guard let account else { return }
            
            let calendar = Calendar.current
            let now = Date()
            
            // Current month start
            let startOfCurrentMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: now))!
            
            // MARK: - Active Sweepstakes (Current Month - March)
            
            // Active #1 - Тест-драйв (started early March, ends late March)
            let testDrive = Sweepstakes(context: context)
            testDrive.title = "Розыгрыш тест-драйва на автотреке"
            testDrive.promoDescription = "Испытайте настоящие эмоции от вождения на спортивном автомобиле! Сканируйте QR-коды и получите шанс выиграть незабываемый опыт на профессиональном автотреке."
            testDrive.status = .active
            testDrive.entryCondition = .minScans
            testDrive.requiredValue = 10
            testDrive.startDate = calendar.date(byAdding: .day, value: 5, to: startOfCurrentMonth)!
            testDrive.endDate = calendar.date(byAdding: .day, value: 25, to: startOfCurrentMonth)!
            testDrive.images = [Attachment.fromURL(URL(string: "https://images.unsplash.com/photo-1568605117036-5fe5e7bab0b7")!, in: context)]
            if let prize = products.first(where: { $0.name.contains("Тест-драйв") }) {
                testDrive.prizes = [prize]
            }
            
            // Active #2 - Химчистка салона (started mid March, ends end of March)
            let cleaning = Sweepstakes(context: context)
            cleaning.title = "Еженедельный розыгрыш химчистки салона"
            cleaning.promoDescription = "Каждую неделю разыгрываем профессиональную химчистку салона автомобиля. Ваш салон снова будет выглядеть как новый!"
            cleaning.status = .active
            cleaning.entryCondition = .minScans
            cleaning.requiredValue = 3
            cleaning.startDate = calendar.date(byAdding: .day, value: 15, to: startOfCurrentMonth)!
            cleaning.endDate = calendar.date(byAdding: .day, value: 28, to: startOfCurrentMonth)!
            cleaning.images = [Attachment.fromURL(URL(string: "https://images.unsplash.com/photo-1607860108855-64acf2078ed9")!, in: context)]
            if let prize = products.first(where: { $0.name.contains("Химчистка") }) {
                cleaning.prizes = [prize]
            }
            
            // MARK: - Upcoming Sweepstakes
            
            // Draft #1 - Next Month (April) - Скидка OZON
            let aprilGiveaway = Sweepstakes(context: context)
            aprilGiveaway.title = "Весенний розыгрыш скидок на OZON"
            aprilGiveaway.promoDescription = "Встречайте весну с выгодными покупками! Разыгрываем промокоды на скидку 1000₽ в магазине NSP Group на OZON. Бесплатное участие для всех!"
            aprilGiveaway.status = .draft
            aprilGiveaway.entryCondition = .free
            aprilGiveaway.requiredValue = 0
            aprilGiveaway.startDate = calendar.date(byAdding: .month, value: 1, to: startOfCurrentMonth)!
            aprilGiveaway.endDate = calendar.date(byAdding: DateComponents(month: 1, day: 20), to: startOfCurrentMonth)!
            aprilGiveaway.images = [Attachment.fromURL(URL(string: "https://images.unsplash.com/photo-1607083206869-4c7672e72a8a")!, in: context)]
            if let prize = products.first(where: { $0.name.contains("1000") && $0.name.contains("OZON") }) {
                aprilGiveaway.prizes = [prize]
            }
            
            // Draft #2 - +2 Months (May) - Комплексная мойка
            let mayGiveaway = Sweepstakes(context: context)
            mayGiveaway.title = "Майский розыгрыш комплексной мойки"
            mayGiveaway.promoDescription = "Грандиозный майский розыгрыш! Накопите баллы и выиграйте комплексную мойку автомобиля с полным сервисом."
            mayGiveaway.status = .draft
            mayGiveaway.entryCondition = .minPoints
            mayGiveaway.requiredValue = 3000
            mayGiveaway.startDate = calendar.date(byAdding: .month, value: 2, to: startOfCurrentMonth)!
            mayGiveaway.endDate = calendar.date(byAdding: DateComponents(month: 2, day: 25), to: startOfCurrentMonth)!
            mayGiveaway.images = [Attachment.fromURL(URL(string: "https://images.unsplash.com/photo-1601362840469-51e4d8d58785")!, in: context)]
            if let prize = products.first(where: { $0.name.contains("мойка") }) {
                mayGiveaway.prizes = [prize]
            }
            
            // MARK: - Finished Sweepstakes
            
            // Finished #1 - Previous Month (February) - Балансировка колес
            let februaryGiveaway = Sweepstakes(context: context)
            februaryGiveaway.title = "Февральский розыгрыш балансировки колес"
            februaryGiveaway.promoDescription = "Розыгрыш сертификата на проверку и балансировку колес. Улучшите управляемость и продлите срок службы шин."
            februaryGiveaway.status = .finished
            februaryGiveaway.entryCondition = .minScans
            februaryGiveaway.requiredValue = 5
            februaryGiveaway.startDate = calendar.date(byAdding: .month, value: -1, to: startOfCurrentMonth)!
            februaryGiveaway.endDate = calendar.date(byAdding: DateComponents(month: -1, day: 25), to: startOfCurrentMonth)!
            februaryGiveaway.images = [Attachment.fromURL(URL(string: "https://images.unsplash.com/photo-1486262715619-67b85e0b08d3")!, in: context)]
            if let prize = products.first(where: { $0.name.contains("балансировка") || $0.name.contains("колес") }) {
                februaryGiveaway.prizes = [prize]
            }
            
            // Finished #2 - -2 Months (January) - User WON! - Диагностика
            let januaryGiveaway = Sweepstakes(context: context)
            januaryGiveaway.title = "Новогодний розыгрыш компьютерной диагностики"
            januaryGiveaway.promoDescription = "Грандиозный новогодний розыгрыш! Накопите баллы и выиграйте бесплатную компьютерную диагностику автомобиля."
            januaryGiveaway.status = .finished
            januaryGiveaway.entryCondition = .minPoints
            januaryGiveaway.requiredValue = 5000
            januaryGiveaway.startDate = calendar.date(byAdding: .month, value: -2, to: startOfCurrentMonth)!
            januaryGiveaway.endDate = calendar.date(byAdding: DateComponents(month: -2, day: 28), to: startOfCurrentMonth)!
            januaryGiveaway.images = [Attachment.fromURL(URL(string: "https://images.unsplash.com/photo-1487754180451-c456f719a1fc")!, in: context)]
            if let prize = products.first(where: { $0.name.contains("диагностика") }) {
                januaryGiveaway.prizes = [prize]
            }
            
            // MARK: - Create Demo Entries
            
            // Entry for test drive (active, not winner)
            let entry1 = SweepstakesEntry(context: context)
            entry1.sweepstakes = testDrive
            entry1.account = account
            entry1.entryDate = calendar.date(byAdding: .day, value: 7, to: startOfCurrentMonth)!
            entry1.isWinner = false
            
            // Entry for cleaning (active, not winner)
            let entry2 = SweepstakesEntry(context: context)
            entry2.sweepstakes = cleaning
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
            if let prize = products.first(where: { $0.name.contains("диагностика") }) {
                entry4.wonProduct = prize
            }
            
            try context.save()
        }
    }
}
