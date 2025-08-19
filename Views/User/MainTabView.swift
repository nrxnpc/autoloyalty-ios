import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var dataManager: DataManager
    
    var body: some View {
        TabView {
            NavigationStack {
                HomeView()
            }
            .tabItem {
                Image(systemName: AppConstants.Images.house)
                Text("Главная")
            }
            
            NavigationStack {
                QRScannerMainView()
            }
            .tabItem {
                Image(systemName: AppConstants.Images.qrCode)
                Text("Сканер")
            }
            
            NavigationStack {
                CarTinderView()
            }
            .tabItem {
                Image(systemName: AppConstants.Images.car)
                Text("Автотиндер")
            }
            
            NavigationStack {
                CatalogView()
            }
            .tabItem {
                Image(systemName: AppConstants.Images.gift)
                Text("Каталог")
            }
            
            NavigationStack {
                ProfileView()
            }
            .tabItem {
                Image(systemName: AppConstants.Images.person)
                Text("Профиль")
            }
        }
        .accentColor(AppConstants.Colors.primary)
    }
}

struct HomeView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var dataManager: DataManager
    
    // Мемоизация результатов фильтрации
    private var recentScans: [QRScanResult] {
        dataManager.qrScansState.items
            .sorted { $0.timestamp > $1.timestamp }
            .prefix(3)
            .map { $0 }
    }
    
    private var activeNews: [NewsArticle] {
        dataManager.newsState.items
            .filter { $0.isPublished }
            .sorted { $0.createdAt > $1.createdAt }
            .prefix(2)
            .map { $0 }
    }
    
    private var activeLotteries: [Lottery] {
        dataManager.lotteriesState.items
            .filter { $0.isActive && $0.endDate > Date() }
            .prefix(1)
            .map { $0 }
    }
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: AppConstants.Spacing.large) {
                // Баланс баллов
                PointsBalanceCard()
                
                // Приветствие
                WelcomeSection()
                
                // Последние сканирования
                if !recentScans.isEmpty {
                    RecentScansSection(scans: recentScans)
                }
                
                // Новости
                if !activeNews.isEmpty {
                    NewsSection(articles: activeNews)
                }
                
                // Активные лотереи
                if !activeLotteries.isEmpty {
                    LotteriesSection(lotteries: activeLotteries)
                }
            }
            .padding()
        }
        .navigationTitle("NSP")
        .refreshable {
            await dataManager.loadDataIfNeeded()
        }
        .task {
            await dataManager.loadDataIfNeeded()
        }
    }
}

struct PointsBalanceCard: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        VStack(spacing: AppConstants.Spacing.small) {
            Text("Ваш баланс")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text("\(authViewModel.currentUser?.points ?? 0)")
                .font(.system(size: 48, weight: .bold))
                .foregroundColor(AppConstants.Colors.primary)
            
            Text("баллов")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.secondary.opacity(0.1))
        .cornerRadius(16)
    }
}

struct WelcomeSection: View {
    var body: some View {
        VStack(spacing: AppConstants.Spacing.small) {
            Text("Добро пожаловать в NSP!")
                .font(.title2)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            
            Text("Сканируйте QR-коды на автозапчастях\nи получайте баллы за покупки")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
    }
}

struct RecentScansSection: View {
    let scans: [QRScanResult]
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppConstants.Spacing.medium) {
            HStack {
                Text("Последние сканирования")
                    .font(.headline)
                Spacer()
                NavigationLink("Все", destination: QRScanHistoryView())
                    .font(.subheadline)
                    .foregroundColor(AppConstants.Colors.primary)
            }
            
            LazyVStack(spacing: AppConstants.Spacing.small) {
                ForEach(scans, id: \.id) { scan in
                    QRScanHistoryRow(scan: scan)
                        .equatable(by: scan.id)
                }
            }
        }
    }
}

struct NewsSection: View {
    let articles: [NewsArticle]
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppConstants.Spacing.medium) {
            HStack {
                Text("Новости")
                    .font(.headline)
                Spacer()
                NavigationLink("Все", destination: NewsListView())
                    .font(.subheadline)
                    .foregroundColor(AppConstants.Colors.primary)
            }
            
            LazyVStack(spacing: AppConstants.Spacing.small) {
                ForEach(articles, id: \.id) { article in
                    NewsCardView(article: article)
                        .equatable(by: article.id)
                }
            }
        }
    }
}

struct LotteriesSection: View {
    let lotteries: [Lottery]
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppConstants.Spacing.medium) {
            HStack {
                Text("Активные розыгрыши")
                    .font(.headline)
                Spacer()
                NavigationLink("Все", destination: LotteriesView())
                    .font(.subheadline)
                    .foregroundColor(AppConstants.Colors.primary)
            }
            
            LazyVStack(spacing: AppConstants.Spacing.small) {
                ForEach(lotteries, id: \.id) { lottery in
                    LotteryCardView(lottery: lottery)
                        .equatable(by: lottery.id)
                }
            }
        }
    }
}

#Preview {
    MainTabView()
        .environmentObject(AuthViewModel())
        .environmentObject(DataManager())
}
