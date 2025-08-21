import SwiftUI

struct AdminMainView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var dataManager: DataManager
    
    private var isSupplier: Bool {
        authViewModel.currentUser?.role == .supplier
    }
    
    var body: some View {
        TabView {
            NavigationStack {
                AdminDashboardView()
            }
            .tabItem {
                Image(systemName: "chart.bar.fill")
                Text("Дашборд")
            }
            
            if !isSupplier {
                NavigationStack {
                    UserManagementView()
                }
                .tabItem {
                    Image(systemName: "person.3.fill")
                    Text("Пользователи")
                }
                
                NavigationStack {
                    AdminCarsView()
                }
                .tabItem {
                    Image(systemName: "car.fill")
                    Text("Автомобили")
                }
            }
            
            NavigationStack {
                AdminProductsView()
            }
            .tabItem {
                Image(systemName: "gift.fill")
                Text("Товары")
            }
            
            NavigationStack {
                AdminNewsView()
            }
            .tabItem {
                Image(systemName: "newspaper.fill")
                Text("Новости")
            }
            
            if !isSupplier {
                NavigationStack {
                    ModerationView()
                }
                .tabItem {
                    Image(systemName: "checkmark.shield.fill")
                    Text("Модерация")
                }
            }
            
            NavigationStack {
                AdminLotteriesView()
            }
            .tabItem {
                Image(systemName: "trophy.fill")
                Text("Лотереи")
            }
            
            NavigationStack {
                AdminProfileView()
            }
            .tabItem {
                Image(systemName: "person.fill")
                Text("Профиль")
            }
        }
        .accentColor(AppConstants.Colors.primary)
    }
}

struct AdminDashboardView: View {
    @EnvironmentObject var dataManager: DataManager
    
    var body: some View {
        ScrollView {
            VStack(spacing: AppConstants.Spacing.large) {
                Text("Добро пожаловать в админ-панель!")
                    .font(.title)
                    .fontWeight(.bold)
                
                // Статистические карточки
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                    AdminStatCard(
                        title: "Пользователи",
                        value: "\(dataManager.usersState.items.count)",
                        icon: "person.3.fill",
                        color: .blue
                    )
                    AdminStatCard(
                        title: "Автомобили",
                        value: "\(dataManager.carsState.items.count)",
                        icon: "car.fill",
                        color: .green
                    )
                    AdminStatCard(
                        title: "Товары",
                        value: "\(dataManager.productsState.items.count)",
                        icon: "gift.fill",
                        color: .orange
                    )
                    AdminStatCard(
                        title: "Сканирования",
                        value: "\(dataManager.qrScansState.items.count)",
                        icon: "qrcode",
                        color: .purple
                    )
                    AdminStatCard(
                        title: "Новости",
                        value: "\(dataManager.newsState.items.count)",
                        icon: "newspaper",
                        color: .cyan
                    )
                    AdminStatCard(
                        title: "Лотереи",
                        value: "\(dataManager.lotteriesState.items.count)",
                        icon: "trophy",
                        color: .pink
                    )
                }
                
                // Последняя активность
                RecentActivitySection()
                
                // Быстрые действия
                QuickActionsSection()
            }
            .padding()
        }
        .navigationTitle("Админ-панель")
        .refreshable {
            await dataManager.loadDataIfNeeded()
        }
        .task {
            await dataManager.loadDataIfNeeded()
        }
    }
}

struct AdminStatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: AppConstants.Spacing.medium) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(color)
                .frame(width: 32, height: 32)
            
            Text(value)
                .font(.title)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

struct RecentActivitySection: View {
    @EnvironmentObject var dataManager: DataManager
    
    private var recentScans: [QRScanResult] {
        dataManager.qrScansState.items
            .sorted { $0.timestamp > $1.timestamp }
            .prefix(5)
            .map { $0 }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppConstants.Spacing.medium) {
            HStack {
                Text("Последняя активность")
                    .font(.headline)
                Spacer()
                NavigationLink("Все", destination: AdminActivityView())
                    .font(.subheadline)
                    .foregroundColor(AppConstants.Colors.primary)
            }
            
            if recentScans.isEmpty {
                Text("Нет активности")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else {
                VStack(spacing: AppConstants.Spacing.small) {
                    ForEach(recentScans, id: \.id) { scan in
                        ActivityRow(scan: scan)
                    }
                }
            }
        }
    }
}

struct ActivityRow: View {
    let scan: QRScanResult
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(scan.productName)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(scan.timestamp.timeAgoDisplay())
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text("+\(scan.pointsEarned)")
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.green)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color.white)
        .cornerRadius(8)
        .shadow(radius: 1)
    }
}

struct QuickActionsSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: AppConstants.Spacing.medium) {
            Text("Быстрые действия")
                .font(.headline)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                QuickActionButton(
                    title: "Добавить товар",
                    icon: "plus.circle",
                    color: .green,
                    destination: AnyView(AdminProductEditView(product: nil))
                )
                
                QuickActionButton(
                    title: "Создать новость",
                    icon: "newspaper.circle",
                    color: .blue,
                    destination: AnyView(AdminNewsEditView(article: nil))
                )
                
                QuickActionButton(
                    title: "Новая лотерея",
                    icon: "trophy.circle",
                    color: .orange,
                    destination: AnyView(AdminLotteryEditView(lottery: nil))
                )
                
                QuickActionButton(
                    title: "Добавить авто",
                    icon: "car.circle",
                    color: .purple,
                    destination: AnyView(AdminCarEditView(car: nil))
                )
            }
        }
    }
}

struct QuickActionButton: View {
    let title: String
    let icon: String
    let color: Color
    let destination: AnyView
    
    var body: some View {
        NavigationLink(destination: destination) {
            VStack(spacing: AppConstants.Spacing.small) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(color)
                    .frame(width: 24, height: 24)
                
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.primary)
            }
            .padding()
            .background(Color.white)
            .cornerRadius(12)
            .shadow(radius: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct AdminActivityView: View {
    @EnvironmentObject var dataManager: DataManager
    
    var body: some View {
        List {
            ForEach(dataManager.qrScansState.items.sorted { $0.timestamp > $1.timestamp }, id: \.id) { scan in
                ActivityRow(scan: scan)
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
            }
        }
        .listStyle(PlainListStyle())
        .navigationTitle("Активность системы")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct AdminProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var showingUserMode = false
    @State private var showingLogoutAlert = false
    
    var body: some View {
        List {
            Section {
                HStack {
                    Circle()
                        .fill(AppConstants.Colors.primary.opacity(0.8))
                        .frame(width: 60, height: 60)
                        .overlay(
                            Image(systemName: "crown.fill")
                                .font(.title2)
                                .foregroundColor(.white)
                        )
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(authViewModel.currentUser?.name ?? "Администратор")
                            .font(.headline)
                        
                        Text("Администратор системы")
                            .font(.subheadline)
                            .foregroundColor(AppConstants.Colors.primary)
                            .fontWeight(.medium)
                        
                        Text(authViewModel.currentUser?.email ?? "")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                }
                .padding(.vertical, AppConstants.Spacing.small)
            }
            
            Section("Управление системой") {
                NavigationLink(destination: AdminStatsView()) {
                    AdminMenuItem(icon: "chart.bar", title: "Статистика системы", subtitle: "Аналитика и отчеты")
                }
                
                NavigationLink(destination: AdminReportsView()) {
                    AdminMenuItem(icon: "doc.text", title: "Отчёты", subtitle: "Детальная отчетность")
                }
                
                NavigationLink(destination: AdminSettingsView()) {
                    AdminMenuItem(icon: "gear", title: "Настройки системы", subtitle: "Конфигурация приложения")
                }
            }
            
            Section("Переключение режима") {
                Button(action: { showingUserMode = true }) {
                    AdminMenuItem(
                        icon: "person.crop.circle.fill.badge.checkmark",
                        title: "Режим пользователя",
                        subtitle: "Тестирование как пользователь"
                    )
                }
                .foregroundColor(.blue)
            }
            
            Section("Системные функции") {
                NavigationLink(destination: AdminLogsView()) {
                    AdminMenuItem(icon: "doc.text", title: "Логи системы", subtitle: "Журнал событий")
                }
                
                NavigationLink(destination: AdminBackupView()) {
                    AdminMenuItem(icon: "externaldrive", title: "Резервное копирование", subtitle: "Бэкап и восстановление")
                }
                
                NavigationLink(destination: AdminUsersReportView()) {
                    AdminMenuItem(icon: "person.3", title: "Отчёт по пользователям", subtitle: "Статистика пользователей")
                }
            }
            
            Section {
                Button(action: { showingLogoutAlert = true }) {
                    HStack {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                            .foregroundColor(AppConstants.Colors.primary)
                            .frame(width: 24, height: 24)
                        
                        Text("Выйти из системы")
                            .foregroundColor(AppConstants.Colors.primary)
                        
                        Spacer()
                    }
                }
            }
        }
        .navigationTitle("Админ профиль")
        .alert("Переключиться в режим пользователя?", isPresented: $showingUserMode) {
            Button("Отмена", role: .cancel) { }
            Button("Переключиться") {
                authViewModel.currentUser = User(
                    id: "temp-user",
                    name: "Администратор (режим пользователя)",
                    email: "admin@nsp.com",
                    phone: "+7 (999) 123-45-67",
                    userType: .individual,
                    points: 1250,
                    role: .customer,
                    registrationDate: Date(),
                    isActive: true,
                    profileImageURL: nil,
                    supplierID: nil,
                    preferences: User.UserPreferences.default,
                    statistics: User.UserStatistics.default,
                    lastLoginDate: nil
                )
            }
        } message: {
            Text("Вы перейдете в режим обычного пользователя для тестирования приложения")
        }
        .alert("Выход из системы", isPresented: $showingLogoutAlert) {
            Button("Отмена", role: .cancel) { }
            Button("Выйти", role: .destructive) {
                authViewModel.logout()
            }
        } message: {
            Text("Вы уверены, что хотите выйти из системы?")
        }
    }
}

struct AdminMenuItem: View {
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

#Preview {
    AdminMainView()
        .environmentObject(AuthViewModel())
        .environmentObject(DataManager())
}
