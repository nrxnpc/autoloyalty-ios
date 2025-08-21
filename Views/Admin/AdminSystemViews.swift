import SwiftUI

// MARK: - System Statistics
struct AdminStatsView: View {
    @EnvironmentObject var dataManager: DataManager
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                // Общая статистика
                StatsSection(title: "Общая статистика") {
                    StatCard(title: "Всего пользователей", value: "\(dataManager.usersState.items.count)", icon: "person.3.fill", color: .blue)
                    StatCard(title: "Активных товаров", value: "\(dataManager.productsState.items.filter { $0.isActive }.count)", icon: "gift.fill", color: .green)
                    StatCard(title: "Всего сканирований", value: "\(dataManager.qrScansState.items.count)", icon: "qrcode", color: .purple)
                    StatCard(title: "Активных лотерей", value: "\(dataManager.lotteriesState.items.filter { $0.isActive }.count)", icon: "trophy.fill", color: .orange)
                }
                
                // Статистика по ролям
                StatsSection(title: "Пользователи по ролям") {
                    let customers = dataManager.usersState.items.filter { $0.role == .customer }.count
                    let suppliers = dataManager.usersState.items.filter { $0.role == .supplier }.count
                    let admins = dataManager.usersState.items.filter { $0.role == .platformAdmin }.count
                    
                    StatCard(title: "Покупатели", value: "\(customers)", icon: "person.fill", color: .blue)
                    StatCard(title: "Поставщики", value: "\(suppliers)", icon: "building.2.fill", color: .green)
                    StatCard(title: "Администраторы", value: "\(admins)", icon: "crown.fill", color: .red)
                }
                
                // Статистика по товарам
                StatsSection(title: "Товары по статусу") {
                    let approved = dataManager.productsState.items.filter { $0.status == .approved }.count
                    let pending = dataManager.productsState.items.filter { $0.status == .pending }.count
                    let rejected = dataManager.productsState.items.filter { $0.status == .rejected }.count
                    
                    StatCard(title: "Одобренные", value: "\(approved)", icon: "checkmark.circle.fill", color: .green)
                    StatCard(title: "На модерации", value: "\(pending)", icon: "clock.fill", color: .orange)
                    StatCard(title: "Отклоненные", value: "\(rejected)", icon: "xmark.circle.fill", color: .red)
                }
            }
            .padding()
        }
        .navigationTitle("Статистика")
        .task {
            await dataManager.loadDataIfNeeded()
        }
    }
}

struct StatsSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .padding(.horizontal)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                content
            }
            .padding(.horizontal)
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(color)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
            
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

// MARK: - Reports
struct AdminReportsView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var selectedPeriod = ReportPeriod.week
    
    enum ReportPeriod: String, CaseIterable {
        case day = "День"
        case week = "Неделя"
        case month = "Месяц"
        case year = "Год"
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Период отчета
                Picker("Период", selection: $selectedPeriod) {
                    ForEach(ReportPeriod.allCases, id: \.self) { period in
                        Text(period.rawValue).tag(period)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                // Отчеты
                ReportCard(
                    title: "Активность пользователей",
                    description: "Статистика входов и активности",
                    icon: "person.3.fill",
                    color: .blue
                ) {
                    // Действие для генерации отчета
                }
                
                ReportCard(
                    title: "Сканирования QR-кодов",
                    description: "Отчет по сканированиям за период",
                    icon: "qrcode",
                    color: .purple
                ) {
                    // Действие для генерации отчета
                }
                
                ReportCard(
                    title: "Обмены баллов",
                    description: "Статистика обменов на товары",
                    icon: "gift.fill",
                    color: .green
                ) {
                    // Действие для генерации отчета
                }
                
                ReportCard(
                    title: "Финансовый отчет",
                    description: "Движение баллов и транзакции",
                    icon: "chart.bar.fill",
                    color: .orange
                ) {
                    // Действие для генерации отчета
                }
            }
            .padding()
        }
        .navigationTitle("Отчеты")
    }
}

struct ReportCard: View {
    let title: String
    let description: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(color)
                    .frame(width: 40, height: 40)
                    .background(color.opacity(0.1))
                    .cornerRadius(8)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color.white)
            .cornerRadius(12)
            .shadow(radius: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - System Settings
struct AdminSettingsView: View {
    @State private var maintenanceMode = false
    @State private var allowRegistration = true
    @State private var requireEmailVerification = false
    @State private var maxPointsPerScan = 100
    @State private var minPointsForExchange = 50
    
    var body: some View {
        Form {
            Section("Системные настройки") {
                Toggle("Режим обслуживания", isOn: $maintenanceMode)
                Toggle("Разрешить регистрацию", isOn: $allowRegistration)
                Toggle("Требовать подтверждение email", isOn: $requireEmailVerification)
            }
            
            Section("Настройки баллов") {
                Stepper("Максимум баллов за скан: \(maxPointsPerScan)", value: $maxPointsPerScan, in: 1...1000, step: 10)
                Stepper("Минимум для обмена: \(minPointsForExchange)", value: $minPointsForExchange, in: 1...500, step: 5)
            }
            
            Section("Уведомления") {
                Button("Отправить push всем пользователям") {
                    // Действие для отправки push
                }
                .foregroundColor(.blue)
                
                Button("Отправить email рассылку") {
                    // Действие для email рассылки
                }
                .foregroundColor(.blue)
            }
            
            Section("Опасные действия") {
                Button("Очистить кеш системы") {
                    // Действие для очистки кеша
                }
                .foregroundColor(.orange)
                
                Button("Сбросить статистику") {
                    // Действие для сброса статистики
                }
                .foregroundColor(.red)
            }
        }
        .navigationTitle("Настройки системы")
    }
}

// MARK: - System Logs
struct AdminLogsView: View {
    @State private var logs: [SystemLog] = []
    @State private var selectedLogLevel = LogLevel.all
    
    enum LogLevel: String, CaseIterable {
        case all = "Все"
        case info = "Информация"
        case warning = "Предупреждения"
        case error = "Ошибки"
    }
    
    struct SystemLog: Identifiable {
        let id = UUID()
        let timestamp: Date
        let level: String
        let message: String
        let source: String
    }
    
    var body: some View {
        VStack {
            // Фильтр логов
            Picker("Уровень", selection: $selectedLogLevel) {
                ForEach(LogLevel.allCases, id: \.self) { level in
                    Text(level.rawValue).tag(level)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            
            // Список логов
            List {
                ForEach(filteredLogs) { log in
                    LogRow(log: log)
                }
            }
        }
        .navigationTitle("Логи системы")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Очистить") {
                    logs.removeAll()
                }
            }
        }
        .onAppear {
            loadDemoLogs()
        }
    }
    
    private var filteredLogs: [SystemLog] {
        if selectedLogLevel == .all {
            return logs
        }
        return logs.filter { $0.level.lowercased() == selectedLogLevel.rawValue.lowercased() }
    }
    
    private func loadDemoLogs() {
        logs = [
            SystemLog(timestamp: Date(), level: "INFO", message: "Пользователь вошел в систему", source: "AuthService"),
            SystemLog(timestamp: Date().addingTimeInterval(-300), level: "WARNING", message: "Превышен лимит запросов API", source: "NetworkManager"),
            SystemLog(timestamp: Date().addingTimeInterval(-600), level: "ERROR", message: "Ошибка подключения к базе данных", source: "DatabaseService"),
            SystemLog(timestamp: Date().addingTimeInterval(-900), level: "INFO", message: "Создан новый товар", source: "ProductService"),
            SystemLog(timestamp: Date().addingTimeInterval(-1200), level: "INFO", message: "QR-код отсканирован", source: "QRService")
        ]
    }
}

struct LogRow: View {
    let log: AdminLogsView.SystemLog
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(log.level)
                    .font(.caption)
                    .fontWeight(.medium)
                    .padding(.horizontal, 8)
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
            
            Text("Источник: \(log.source)")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
    
    private var levelColor: Color {
        switch log.level.lowercased() {
        case "error": return .red
        case "warning": return .orange
        case "info": return .blue
        default: return .gray
        }
    }
}

// MARK: - Backup Management
struct AdminBackupView: View {
    @State private var lastBackupDate: Date?
    @State private var isCreatingBackup = false
    @State private var backupSize = "0 MB"
    
    var body: some View {
        List {
            Section("Информация о резервной копии") {
                HStack {
                    Text("Последняя копия")
                    Spacer()
                    Text(lastBackupDate?.formattedDate() ?? "Никогда")
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Text("Размер копии")
                    Spacer()
                    Text(backupSize)
                        .foregroundColor(.secondary)
                }
            }
            
            Section("Действия") {
                Button(action: createBackup) {
                    HStack {
                        if isCreatingBackup {
                            ProgressView()
                                .scaleEffect(0.8)
                        } else {
                            Image(systemName: "externaldrive.badge.plus")
                        }
                        Text("Создать резервную копию")
                    }
                }
                .disabled(isCreatingBackup)
                
                Button("Восстановить из копии") {
                    // Действие для восстановления
                }
                .foregroundColor(.orange)
                
                Button("Экспорт данных") {
                    // Действие для экспорта
                }
                .foregroundColor(.blue)
            }
            
            Section("Автоматическое резервное копирование") {
                Toggle("Включить автобэкап", isOn: .constant(true))
                
                HStack {
                    Text("Частота")
                    Spacer()
                    Text("Ежедневно")
                        .foregroundColor(.secondary)
                }
            }
        }
        .navigationTitle("Резервное копирование")
        .onAppear {
            lastBackupDate = Date().addingTimeInterval(-86400) // Вчера
            backupSize = "15.2 MB"
        }
    }
    
    private func createBackup() {
        isCreatingBackup = true
        
        // Симуляция создания бэкапа
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            isCreatingBackup = false
            lastBackupDate = Date()
            backupSize = "16.1 MB"
        }
    }
}

// MARK: - Users Report
struct AdminUsersReportView: View {
    @EnvironmentObject var dataManager: DataManager
    
    var body: some View {
        List {
            ForEach(dataManager.usersState.items.sorted { $0.registrationDate > $1.registrationDate }, id: \.id) { user in
                UserReportRow(user: user)
            }
        }
        .navigationTitle("Отчет по пользователям")
        .task {
            await dataManager.loadDataType(.users)
        }
    }
}

struct UserReportRow: View {
    let user: User
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(user.name)
                        .font(.headline)
                    
                    Text(user.email)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text("\(user.points) баллов")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    
                    Text(user.role.displayName)
                        .font(.caption)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(roleColor.opacity(0.2))
                        .foregroundColor(roleColor)
                        .cornerRadius(4)
                }
            }
            
            HStack {
                Text("Регистрация: \(user.registrationDate.formattedDate())")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text(user.isActive ? "Активен" : "Заблокирован")
                    .font(.caption)
                    .foregroundColor(user.isActive ? .green : .red)
            }
        }
        .padding(.vertical, 4)
    }
    
    private var roleColor: Color {
        switch user.role {
        case .customer: return .blue
        case .supplier: return .green
        case .platformAdmin: return .red
        }
    }
}

#Preview {
    NavigationStack {
        AdminStatsView()
            .environmentObject(DataManager())
    }
}