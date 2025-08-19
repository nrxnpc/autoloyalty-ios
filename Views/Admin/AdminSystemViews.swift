import SwiftUI

// MARK: - Admin Statistics

struct AdminStatsView: View {
    @EnvironmentObject var dataManager: DataManager
    
    private var totalPoints: Int {
        dataManager.pointTransactionsState.items
            .filter { $0.type == .earned }
            .reduce(0) { $0 + $1.amount }
    }
    
    private var activeUsers: Int {
        dataManager.usersState.items.filter { $0.isActive }.count
    }
    
    private var averagePoints: Int {
        guard !dataManager.usersState.items.isEmpty else { return 0 }
        return dataManager.usersState.items.reduce(0) { $0 + $1.points } / dataManager.usersState.items.count
    }
    
    private var maxPoints: Int {
        dataManager.usersState.items.max(by: { $0.points < $1.points })?.points ?? 0
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: AppConstants.Spacing.large) {
                Text("Статистика системы")
                    .font(.title)
                    .fontWeight(.bold)
                
                // Основная статистика
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                    StatCard(title: "Всего пользователей", value: "\(dataManager.usersState.items.count)", color: .blue)
                    StatCard(title: "Активных пользователей", value: "\(activeUsers)", color: .green)
                    StatCard(title: "Всего сканирований", value: "\(dataManager.qrScansState.items.count)", color: .purple)
                    StatCard(title: "Выданных баллов", value: "\(totalPoints)", color: .orange)
                    StatCard(title: "Средний баланс", value: "\(averagePoints)", color: .cyan)
                    StatCard(title: "Максимальный баланс", value: "\(maxPoints)", color: .pink)
                }
                .padding()
                
                // Популярные товары
                PopularProductsSection()
                
                // Статистика по категориям
                CategoryStatsSection()
                
                // Активность по дням
                ActivityByDaysSection()
            }
        }
        .navigationTitle("Статистика")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await dataManager.loadDataIfNeeded()
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: AppConstants.Spacing.small) {
            Text(value)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

struct PopularProductsSection: View {
    @EnvironmentObject var dataManager: DataManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppConstants.Spacing.medium) {
            Text("Популярные товары")
                .font(.headline)
                .padding(.horizontal)
            
            ForEach(dataManager.productsState.items.prefix(5), id: \.id) { product in
                HStack {
                    Text(product.name)
                        .font(.subheadline)
                    
                    Spacer()
                    
                    Text("\(product.pointsCost) баллов")
                        .font(.caption)
                        .foregroundColor(AppConstants.Colors.primary)
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
                .background(Color.white)
                .cornerRadius(8)
                .shadow(radius: 1)
            }
            .padding(.horizontal)
        }
    }
}

struct CategoryStatsSection: View {
    @EnvironmentObject var dataManager: DataManager
    
    private var categoryStats: [(Product.ProductCategory, Int)] {
        var stats: [Product.ProductCategory: Int] = [:]
        
        for product in dataManager.productsState.items {
            stats[product.category, default: 0] += 1
        }
        
        return stats.sorted { $0.value > $1.value }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppConstants.Spacing.medium) {
            Text("Товары по категориям")
                .font(.headline)
                .padding(.horizontal)
            
            ForEach(categoryStats, id: \.0) { category, count in
                HStack {
                    Text(category.displayName)
                        .font(.subheadline)
                    
                    Spacer()
                    
                    Text("\(count)")
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
                .background(Color.white)
                .cornerRadius(8)
                .shadow(radius: 1)
            }
            .padding(.horizontal)
        }
    }
}

struct ActivityByDaysSection: View {
    @EnvironmentObject var dataManager: DataManager
    
    private var dailyActivity: [(String, Int)] {
        let calendar = Calendar.current
        let now = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM"
        
        var activity: [String: Int] = [:]
        
        for i in 0..<7 {
            let date = calendar.date(byAdding: .day, value: -i, to: now)!
            let dateString = formatter.string(from: date)
            activity[dateString] = 0
        }
        
        for scan in dataManager.qrScansState.items {
            let dateString = formatter.string(from: scan.timestamp)
            if let currentCount = activity[dateString] {
                activity[dateString] = currentCount + 1
            }
        }
        
        return activity.sorted { $0.key > $1.key }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppConstants.Spacing.medium) {
            Text("Активность за неделю")
                .font(.headline)
                .padding(.horizontal)
            
            ForEach(dailyActivity, id: \.0) { date, count in
                HStack {
                    Text(date)
                        .font(.subheadline)
                    
                    Spacer()
                    
                    Text("\(count) сканирований")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
                .background(Color.white)
                .cornerRadius(8)
                .shadow(radius: 1)
            }
            .padding(.horizontal)
        }
    }
}

// MARK: - Admin Reports

struct AdminReportsView: View {
    var body: some View {
        List {
            NavigationLink(destination: SalesReportView()) {
                ReportMenuItem(
                    icon: "chart.line.uptrend.xyaxis",
                    title: "Отчёт по продажам",
                    subtitle: "Статистика обменов баллов"
                )
            }
            
            NavigationLink(destination: UsersReportView()) {
                ReportMenuItem(
                    icon: "person.3.sequence",
                    title: "Отчёт по пользователям",
                    subtitle: "Анализ активности пользователей"
                )
            }
            
            NavigationLink(destination: ScansReportView()) {
                ReportMenuItem(
                    icon: "qrcode",
                    title: "Отчёт по сканированиям",
                    subtitle: "Статистика QR-сканирований"
                )
            }
            
            NavigationLink(destination: PointsReportView()) {
                ReportMenuItem(
                    icon: "creditcard",
                    title: "Отчёт по балансу баллов",
                    subtitle: "Движение баллов в системе"
                )
            }
        }
        .navigationTitle("Отчёты")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct ReportMenuItem: View {
    let icon: String
    let title: String
    let subtitle: String
    
    var body: some View {
        HStack(spacing: AppConstants.Spacing.medium) {
            Image(systemName: icon)
                .foregroundColor(AppConstants.Colors.primary)
                .frame(width: 24, height: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(.vertical, 2)
    }
}

struct SalesReportView: View {
    @EnvironmentObject var dataManager: DataManager
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppConstants.Spacing.large) {
                Text("Отчёт по продажам")
                    .font(.title2)
                    .fontWeight(.bold)
                
                ReportSection(title: "Общая статистика") {
                    ReportRow(label: "Всего заказов", value: "\(dataManager.ordersState.items.count)")
                    ReportRow(label: "Потрачено баллов", value: "\(totalSpentPoints)")
                    ReportRow(label: "Средний чек", value: "\(averageOrderValue) баллов")
                }
                
                ReportSection(title: "По категориям товаров") {
                    ForEach(categoryOrders, id: \.0) { category, count in
                        ReportRow(label: category.displayName, value: "\(count)")
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Продажи")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var totalSpentPoints: Int {
        dataManager.ordersState.items.reduce(0) { $0 + $1.pointsSpent }
    }
    
    private var averageOrderValue: Int {
        guard !dataManager.ordersState.items.isEmpty else { return 0 }
        return totalSpentPoints / dataManager.ordersState.items.count
    }
    
    private var categoryOrders: [(Product.ProductCategory, Int)] {
        var stats: [Product.ProductCategory: Int] = [:]
        
        for order in dataManager.ordersState.items {
            stats[order.product.category, default: 0] += 1
        }
        
        return stats.sorted { $0.value > $1.value }
    }
}

struct UsersReportView: View {
    @EnvironmentObject var dataManager: DataManager
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppConstants.Spacing.large) {
                Text("Отчёт по пользователям")
                    .font(.title2)
                    .fontWeight(.bold)
                
                ReportSection(title: "Общая статистика") {
                    ReportRow(label: "Всего пользователей", value: "\(dataManager.usersState.items.count)")
                    ReportRow(label: "Активных пользователей", value: "\(activeUsers)")
                    ReportRow(label: "Физических лиц", value: "\(individualUsers)")
                    ReportRow(label: "Юридических лиц", value: "\(businessUsers)")
                }
                
                ReportSection(title: "По балансу баллов") {
                    ReportRow(label: "Средний баланс", value: "\(averagePoints) баллов")
                    ReportRow(label: "Максимальный баланс", value: "\(maxPoints) баллов")
                    ReportRow(label: "Пользователей с балансом > 1000", value: "\(richUsers)")
                }
            }
            .padding()
        }
        .navigationTitle("Пользователи")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var activeUsers: Int {
        dataManager.usersState.items.filter { $0.isActive }.count
    }
    
    private var individualUsers: Int {
        dataManager.usersState.items.filter { $0.userType == .individual }.count
    }
    
    private var businessUsers: Int {
        dataManager.usersState.items.filter { $0.userType == .business }.count
    }
    
    private var averagePoints: Int {
        guard !dataManager.usersState.items.isEmpty else { return 0 }
        return dataManager.usersState.items.reduce(0) { $0 + $1.points } / dataManager.usersState.items.count
    }
    
    private var maxPoints: Int {
        dataManager.usersState.items.max(by: { $0.points < $1.points })?.points ?? 0
    }
    
    private var richUsers: Int {
        dataManager.usersState.items.filter { $0.points > 1000 }.count
    }
}

struct ScansReportView: View {
    @EnvironmentObject var dataManager: DataManager
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppConstants.Spacing.large) {
                Text("Отчёт по сканированиям")
                    .font(.title2)
                    .fontWeight(.bold)
                
                ReportSection(title: "Общая статистика") {
                    ReportRow(label: "Всего сканирований", value: "\(dataManager.qrScansState.items.count)")
                    ReportRow(label: "Всего выдано баллов", value: "\(totalEarnedPoints)")
                    ReportRow(label: "Среднее за сканирование", value: "\(averagePointsPerScan) баллов")
                }
                
                ReportSection(title: "За последние дни") {
                    ForEach(dailyScans, id: \.0) { date, count in
                        ReportRow(label: date, value: "\(count)")
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Сканирования")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var totalEarnedPoints: Int {
        dataManager.qrScansState.items.reduce(0) { $0 + $1.pointsEarned }
    }
    
    private var averagePointsPerScan: Int {
        guard !dataManager.qrScansState.items.isEmpty else { return 0 }
        return totalEarnedPoints / dataManager.qrScansState.items.count
    }
    
    private var dailyScans: [(String, Int)] {
        let calendar = Calendar.current
        let now = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        
        var scans: [String: Int] = [:]
        
        for i in 0..<7 {
            let date = calendar.date(byAdding: .day, value: -i, to: now)!
            let dateString = formatter.string(from: date)
            scans[dateString] = 0
        }
        
        for scan in dataManager.qrScansState.items {
            let dateString = formatter.string(from: scan.timestamp)
            if let currentCount = scans[dateString] {
                scans[dateString] = currentCount + 1
            }
        }
        
        return scans.sorted { $0.key > $1.key }
    }
}

struct PointsReportView: View {
    @EnvironmentObject var dataManager: DataManager
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppConstants.Spacing.large) {
                Text("Отчёт по балансу баллов")
                    .font(.title2)
                    .fontWeight(.bold)
                
                ReportSection(title: "Движение баллов") {
                    ReportRow(label: "Всего начислено", value: "\(totalEarned)")
                    ReportRow(label: "Всего потрачено", value: "\(totalSpent)")
                    ReportRow(label: "Баланс системы", value: "\(totalBalance)")
                }
                
                ReportSection(title: "По типам операций") {
                    ForEach(PointTransaction.TransactionType.allCases, id: \.self) { type in
                        let count = transactionsByType[type] ?? 0
                        ReportRow(label: type.displayName, value: "\(count)")
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Баллы")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var totalEarned: Int {
        dataManager.pointTransactionsState.items
            .filter { $0.type == .earned || $0.type == .bonus }
            .reduce(0) { $0 + $1.amount }
    }
    
    private var totalSpent: Int {
        dataManager.pointTransactionsState.items
            .filter { $0.type == .spent || $0.type == .penalty }
            .reduce(0) { $0 + $1.amount }
    }
    
    private var totalBalance: Int {
        totalEarned - totalSpent
    }
    
    private var transactionsByType: [PointTransaction.TransactionType: Int] {
        var stats: [PointTransaction.TransactionType: Int] = [:]
        
        for transaction in dataManager.pointTransactionsState.items {
            stats[transaction.type, default: 0] += 1
        }
        
        return stats
    }
}

struct ReportSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppConstants.Spacing.medium) {
            Text(title)
                .font(.headline)
            
            VStack(spacing: AppConstants.Spacing.small) {
                content
            }
            .padding()
            .background(Color.white)
            .cornerRadius(12)
            .shadow(radius: 2)
        }
    }
}

struct ReportRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
        }
    }
}

// MARK: - Admin Settings

struct AdminSettingsView: View {
    @State private var pointsPerScan = "50"
    @State private var maxPointsPerDay = "500"
    @State private var maintenanceMode = false
    @State private var pushNotifications = true
    @State private var emailNotifications = true
    
    var body: some View {
        List {
            Section("Настройки баллов") {
                HStack {
                    Text("Баллов за сканирование")
                    Spacer()
                    TextField("50", text: $pointsPerScan)
                        .keyboardType(.numberPad)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(width: 80)
                }
                
                HStack {
                    Text("Максимум баллов в день")
                    Spacer()
                    TextField("500", text: $maxPointsPerDay)
                        .keyboardType(.numberPad)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(width: 80)
                }
            }
            
            Section("Режим работы") {
                Toggle("Режим обслуживания", isOn: $maintenanceMode)
                    .tint(AppConstants.Colors.primary)
            }
            
            Section("Уведомления") {
                Toggle("Push-уведомления", isOn: $pushNotifications)
                    .tint(AppConstants.Colors.primary)
                
                Toggle("Email-уведомления", isOn: $emailNotifications)
                    .tint(AppConstants.Colors.primary)
            }
            
            Section("Информация о системе") {
                HStack {
                    Text("Версия приложения")
                    Spacer()
                    Text(Bundle.main.version ?? "1.0.0")
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Text("Сборка")
                    Spacer()
                    Text(Bundle.main.buildNumber ?? "1")
                        .foregroundColor(.secondary)
                }
            }
        }
        .navigationTitle("Настройки")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Admin Logs

struct AdminLogsView: View {
    private let logs = [
        LogEntry(timestamp: Date(), level: "INFO", message: "Пользователь выполнил вход в систему"),
        LogEntry(timestamp: Date().addingTimeInterval(-300), level: "WARNING", message: "Превышен лимит запросов API"),
        LogEntry(timestamp: Date().addingTimeInterval(-600), level: "ERROR", message: "Ошибка подключения к базе данных"),
        LogEntry(timestamp: Date().addingTimeInterval(-900), level: "INFO", message: "Создан новый пользователь"),
        LogEntry(timestamp: Date().addingTimeInterval(-1200), level: "INFO", message: "Выполнено сканирование QR-кода"),
        LogEntry(timestamp: Date().addingTimeInterval(-1500), level: "WARNING", message: "Низкий уровень свободного места")
    ]
    
    var body: some View {
        List {
            ForEach(logs, id: \.id) { log in
                LogRow(log: log)
            }
        }
        .navigationTitle("Логи системы")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct LogEntry: Identifiable {
    let id = UUID()
    let timestamp: Date
    let level: String
    let message: String
}

struct LogRow: View {
    let log: LogEntry
    
    private var levelColor: Color {
        switch log.level {
        case "ERROR": return AppConstants.Colors.primary
        case "WARNING": return .orange
        case "INFO": return .blue
        default: return .secondary
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(log.level)
                    .font(.caption)
                    .fontWeight(.bold)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(levelColor.opacity(0.2))
                    .foregroundColor(levelColor)
                    .cornerRadius(4)
                
                Spacer()
                
                Text(log.timestamp.formattedDate())
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Text(log.message)
                .font(.subheadline)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Admin Backup

struct AdminBackupView: View {
    @State private var lastBackup = Date().addingTimeInterval(-86400) // 1 день назад
    @State private var isCreatingBackup = false
    @State private var showingSuccessAlert = false
    
    var body: some View {
        VStack(spacing: AppConstants.Spacing.large) {
            VStack(spacing: AppConstants.Spacing.medium) {
                Image(systemName: "externaldrive")
                    .font(.system(size: 60))
                    .foregroundColor(.blue)
                
                Text("Резервное копирование")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Последний бэкап: \(lastBackup.formattedDate())")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding()
            
            VStack(spacing: AppConstants.Spacing.medium) {
                Button(action: { createBackup() }) {
                    HStack {
                        if isCreatingBackup {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Image(systemName: "plus.circle")
                        }
                        Text("Создать резервную копию")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .disabled(isCreatingBackup)
                
                Button("Восстановить из копии") {
                    // Логика восстановления
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.secondary.opacity(0.2))
                .foregroundColor(.primary)
                .cornerRadius(12)
            }
            .padding(.horizontal)
            
            Spacer()
        }
        .navigationTitle("Резервные копии")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Резервная копия создана", isPresented: $showingSuccessAlert) {
            Button("OK") { }
        } message: {
            Text("Резервная копия успешно создана и сохранена.")
        }
    }
    
    private func createBackup() {
        isCreatingBackup = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            lastBackup = Date()
            isCreatingBackup = false
            showingSuccessAlert = true
        }
    }
}

struct AdminUsersReportView: View {
    @EnvironmentObject var dataManager: DataManager
    
    var body: some View {
        UsersReportView()
    }
}

#Preview {
    NavigationStack {
        AdminStatsView()
            .environmentObject(DataManager())
    }
}
