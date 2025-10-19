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
                Image(systemName: "house.fill")
                Text("Главная")
            }
            
            NavigationStack {
                QRScannerMainView()
            }
            .tabItem {
                Image(systemName: "qrcode.viewfinder")
                Text("Сканер")
            }
            
            NavigationStack {
                CarTinderView()
            }
            .tabItem {
                Image(systemName: "car.fill")
                Text("Авто")
            }
            
            NavigationStack {
                CatalogView()
            }
            .tabItem {
                Image(systemName: "gift.fill")
                Text("Каталог")
            }
            
            NavigationStack {
                ProfileView()
            }
            .tabItem {
                Image(systemName: "person.fill")
                Text("Профиль")
            }
        }
        .accentColor(DesignSystem.Colors.primary)
        .background(DesignSystem.Colors.background)
    }
}

struct HomeView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var dataManager: DataManager
    
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
            LazyVStack(spacing: DesignSystem.Spacing.large) {
                // Баланс баллов и уровень
                ModernPointsBalanceCard()
                
                // Быстрые действия
                HomeQuickActionsSection()
                
                // Последние сканирования
                if !recentScans.isEmpty {
                    ModernRecentScansSection(scans: recentScans)
                }
                
                // Новости
                if !activeNews.isEmpty {
                    ModernNewsSection(articles: activeNews)
                }
                
                // Активные лотереи
                if !activeLotteries.isEmpty {
                    ModernLotteriesSection(lotteries: activeLotteries)
                }
            }
            .padding(DesignSystem.Spacing.medium)
        }
        .background(DesignSystem.Colors.background)
        .navigationTitle("Автолояльность")
        .navigationBarTitleDisplayMode(.large)
        .refreshable {
            await dataManager.loadDataIfNeeded()
        }
        .task {
            await dataManager.loadDataIfNeeded()
        }
    }
}

struct ModernPointsBalanceCard: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var animatePoints = false
    @State private var showConfetti = false
    
    private var currentPoints: Int {
        authViewModel.currentUser?.points ?? 0
    }
    
    private var nextLevelPoints: Int {
        if currentPoints < 5000 { return 5000 }
        if currentPoints < 15000 { return 15000 }
        return 25000
    }
    
    private var progressValue: Double {
        let basePoints = currentPoints < 5000 ? 0 : (currentPoints < 15000 ? 5000 : 15000)
        let maxPoints = nextLevelPoints - basePoints
        let currentProgress = currentPoints - basePoints
        return Double(currentProgress) / Double(maxPoints)
    }
    
    var body: some View {
        ModernCard {
            VStack(spacing: DesignSystem.Spacing.medium) {
                // Главная информация
                HStack {
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                        HStack {
                            Text("Баланс")
                                .font(DesignSystem.Typography.callout)
                                .foregroundColor(DesignSystem.Colors.secondaryText)
                            
                            Image(systemName: "sparkles")
                                .font(.system(size: 12))
                                .foregroundColor(DesignSystem.Colors.accent)
                                .pulse()
                        }
                        
                        HStack(spacing: DesignSystem.Spacing.xs) {
                            Text("\(currentPoints)")
                                .font(DesignSystem.Typography.title1)
                                .fontWeight(.bold)
                                .foregroundColor(DesignSystem.Colors.primary)
                                .scaleEffect(animatePoints ? 1.1 : 1.0)
                                .animation(AnimationSystem.Spring.bouncy, value: animatePoints)
                            
                            Image(systemName: "star.fill")
                                .font(.system(size: 20))
                                .foregroundColor(DesignSystem.Colors.accent)
                                .floating(amplitude: 3, duration: 2.5)
                        }
                    }
                    
                    Spacer()
                    
                    if let user = authViewModel.currentUser {
                        VStack(spacing: DesignSystem.Spacing.xs) {
                            LevelBadge(tierName: user.statistics.loyaltyTier, points: user.points)
                            
                            Text("Уровень \(getLevelNumber(points: currentPoints))")
                                .font(DesignSystem.Typography.caption2)
                                .foregroundColor(DesignSystem.Colors.tertiaryText)
                        }
                    }
                }
                
                // Прогресс бар
                if let user = authViewModel.currentUser {
                    VStack(spacing: DesignSystem.Spacing.small) {
                        HStack {
                            Text("Прогресс до следующего уровня")
                                .font(DesignSystem.Typography.caption)
                                .foregroundColor(DesignSystem.Colors.secondaryText)
                            
                            Spacer()
                            
                            Text("\(nextLevelPoints - currentPoints) баллов")
                                .font(DesignSystem.Typography.caption)
                                .fontWeight(.medium)
                                .foregroundColor(DesignSystem.Colors.primary)
                        }
                        
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                Rectangle()
                                    .fill(DesignSystem.Colors.secondary)
                                    .frame(height: 8)
                                    .cornerRadius(4)
                                
                                Rectangle()
                                    .fill(
                                        LinearGradient(
                                            colors: [DesignSystem.Colors.primary, DesignSystem.Colors.accent],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .frame(width: geometry.size.width * progressValue, height: 8)
                                    .cornerRadius(4)
                                    .animation(AnimationSystem.Spring.smooth.delay(0.3), value: progressValue)
                                
                                // Блик на прогресс баре
                                if progressValue > 0 {
                                    Rectangle()
                                        .fill(
                                            LinearGradient(
                                                colors: [.clear, .white.opacity(0.6), .clear],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                        .frame(width: 30, height: 8)
                                        .cornerRadius(4)
                                        .offset(x: -15)
                                        .shimmer()
                                }
                            }
                        }
                        .frame(height: 8)
                    }
                }
            }
        }
        .onAppear {
            withAnimation(AnimationSystem.Spring.bouncy.delay(0.5)) {
                animatePoints = true
            }
        }
        .onChange(of: currentPoints) { oldValue, newValue in
            if newValue > oldValue {
                HapticService.shared.scanSuccess()
                withAnimation(AnimationSystem.Spring.bouncy) {
                    animatePoints.toggle()
                }
            }
        }
    }
    
    private func getLevelNumber(points: Int) -> Int {
        if points < 5000 { return 1 }
        if points < 15000 { return 2 }
        return 3
    }
}

struct HomeQuickActionsSection: View {
    @State private var selectedAction: Int? = nil
    
    var body: some View {
        VStack(spacing: DesignSystem.Spacing.medium) {
            HStack {
                Text("Быстрые действия")
                    .font(DesignSystem.Typography.headline)
                    .foregroundColor(DesignSystem.Colors.text)
                
                Spacer()
                
                Image(systemName: "bolt.fill")
                    .font(.system(size: 16))
                    .foregroundColor(DesignSystem.Colors.accent)
                    .pulse()
            }
            
            HStack(spacing: DesignSystem.Spacing.medium) {
                NavigationLink(value: 0) {
                    HomeQuickActionButtonContent(
                        title: "Сканер",
                        icon: "qrcode.viewfinder",
                        color: DesignSystem.Colors.primary,
                        gradient: [DesignSystem.Colors.primary, DesignSystem.Colors.primaryLight],
                        isSelected: selectedAction == 0
                    )
                }
                .simultaneousGesture(TapGesture().onEnded {
                    selectedAction = 0
                    HapticService.shared.medium()
                })
                .slideIn(from: .leading, delay: 0.1)
                
                NavigationLink(value: 1) {
                    HomeQuickActionButtonContent(
                        title: "Каталог",
                        icon: "gift.fill",
                        color: DesignSystem.Colors.accent,
                        gradient: [DesignSystem.Colors.accent, Color.orange],
                        isSelected: selectedAction == 1
                    )
                }
                .simultaneousGesture(TapGesture().onEnded {
                    selectedAction = 1
                    HapticService.shared.medium()
                })
                .slideIn(from: .bottom, delay: 0.2)
                
                NavigationLink(value: 2) {
                    HomeQuickActionButtonContent(
                        title: "Авто",
                        icon: "car.fill",
                        color: DesignSystem.Colors.success,
                        gradient: [DesignSystem.Colors.success, Color.green],
                        isSelected: selectedAction == 2
                    )
                }
                .simultaneousGesture(TapGesture().onEnded {
                    selectedAction = 2
                    HapticService.shared.medium()
                })
                .slideIn(from: .trailing, delay: 0.3)
            }
            .navigationDestination(for: Int.self) { action in
                switch action {
                case 0: QRScannerMainView()
                case 1: CatalogView()
                case 2: CarTinderView()
                default: EmptyView()
                }
            }
        }
    }
}

struct HomeQuickActionButtonContent: View {
    let title: String
    let icon: String
    let color: Color
    let gradient: [Color]
    let isSelected: Bool
    
    @State private var isPressed = false
    @State private var showRipple = false
    
    var body: some View {
        ZStack {
            // Основной фон
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large)
                .fill(
                    LinearGradient(
                        colors: isSelected ? gradient : [color.opacity(0.1), color.opacity(0.05)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large)
                        .stroke(
                            LinearGradient(
                                colors: [color.opacity(0.3), color.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
            
            VStack(spacing: DesignSystem.Spacing.small) {
                ZStack {
                    // Тень иконки
                    Image(systemName: icon)
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundColor(.black.opacity(0.1))
                        .offset(x: 1, y: 1)
                    
                    // Основная иконка
                    Image(systemName: icon)
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundColor(isSelected ? .white : color)
                        .scaleEffect(isPressed ? 0.9 : 1.0)
                }
                
                Text(title)
                    .font(DesignSystem.Typography.caption)
                    .fontWeight(.medium)
                    .foregroundColor(isSelected ? .white : DesignSystem.Colors.text)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 80)
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .animation(AnimationSystem.Interactive.press, value: isPressed)
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
        .shadow(
            color: color.opacity(0.3),
            radius: isSelected ? 8 : 4,
            x: 0,
            y: isSelected ? 4 : 2
        )
        .animation(AnimationSystem.Spring.smooth, value: isSelected)
    }
}

struct ModernRecentScansSection: View {
    let scans: [QRScanResult]
    
    var body: some View {
        ModernCard {
            VStack(spacing: DesignSystem.Spacing.medium) {
                SectionHeader(
                    "Последние сканирования",
                    actionTitle: "Все"
                ) {
                    // Переход к истории
                }
                
                LazyVStack(spacing: DesignSystem.Spacing.small) {
                    ForEach(scans, id: \.id) { scan in
                        ModernScanRow(scan: scan)
                    }
                }
            }
        }
    }
}

struct ModernScanRow: View {
    let scan: QRScanResult
    
    var body: some View {
        HStack(spacing: DesignSystem.Spacing.medium) {
            Image(systemName: "qrcode")
                .font(.system(size: 20))
                .foregroundColor(DesignSystem.Colors.primary)
                .frame(width: 32, height: 32)
                .background(DesignSystem.Colors.primary.opacity(0.1))
                .cornerRadius(DesignSystem.CornerRadius.small)
            
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                Text(scan.productName)
                    .font(DesignSystem.Typography.bodyMedium)
                    .foregroundColor(DesignSystem.Colors.text)
                
                Text(scan.timestamp.formattedDate())
                    .font(DesignSystem.Typography.caption)
                    .foregroundColor(DesignSystem.Colors.secondaryText)
            }
            
            Spacer()
            
            PointsDisplay(points: scan.pointsEarned, size: .small)
        }
        .padding(.vertical, DesignSystem.Spacing.xs)
    }
}

struct ModernNewsSection: View {
    let articles: [NewsArticle]
    
    var body: some View {
        VStack(spacing: DesignSystem.Spacing.medium) {
            SectionHeader(
                "Новости",
                actionTitle: "Все"
            ) {
                // Переход к новостям
            }
            
            LazyVStack(spacing: DesignSystem.Spacing.medium) {
                ForEach(articles, id: \.id) { article in
                    ModernNewsCard(article: article)
                }
            }
        }
    }
}

struct ModernNewsCard: View {
    let article: NewsArticle
    @State private var isPressed = false
    @State private var showDetails = false
    
    var body: some View {
        HapticButton(hapticType: .light, action: {
            showDetails = true
        }) {
            ZStack {
                // Основная карточка
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large)
                    .fill(
                        LinearGradient(
                            colors: [
                                DesignSystem.Colors.cardBackground,
                                DesignSystem.Colors.secondaryBackground
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large)
                            .stroke(
                                LinearGradient(
                                    colors: [DesignSystem.Colors.border.opacity(0.5), .clear],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
                
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.medium) {
                    // Заголовок с бейджем
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                            if article.isImportant {
                                HStack {
                                    Image(systemName: "exclamationmark.triangle.fill")
                                        .font(.system(size: 12))
                                        .foregroundColor(DesignSystem.Colors.error)
                                        .pulse()
                                    
                                    Text("ВАЖНО")
                                        .font(DesignSystem.Typography.caption2)
                                        .fontWeight(.bold)
                                        .foregroundColor(DesignSystem.Colors.error)
                                }
                                .padding(.horizontal, DesignSystem.Spacing.small)
                                .padding(.vertical, DesignSystem.Spacing.xs)
                                .background(
                                    Capsule()
                                        .fill(DesignSystem.Colors.error.opacity(0.1))
                                )
                            }
                            
                            Text(article.title)
                                .font(DesignSystem.Typography.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(DesignSystem.Colors.text)
                                .lineLimit(2)
                                .multilineTextAlignment(.leading)
                        }
                        
                        Spacer()
                        
                        // Иконка новости
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [DesignSystem.Colors.info, DesignSystem.Colors.primary],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 40, height: 40)
                            
                            Image(systemName: "newspaper.fill")
                                .font(.system(size: 18))
                                .foregroundColor(.white)
                                .floating(amplitude: 2, duration: 3)
                        }
                    }
                    
                    // Контент
                    Text(article.content)
                        .font(DesignSystem.Typography.body)
                        .foregroundColor(DesignSystem.Colors.secondaryText)
                        .lineLimit(3)
                        .multilineTextAlignment(.leading)
                    
                    // Нижняя часть
                    HStack {
                        HStack(spacing: DesignSystem.Spacing.xs) {
                            Image(systemName: "clock.fill")
                                .font(.system(size: 10))
                                .foregroundColor(DesignSystem.Colors.tertiaryText)
                            
                            Text(article.createdAt.timeAgoDisplay())
                                .font(DesignSystem.Typography.caption)
                                .foregroundColor(DesignSystem.Colors.tertiaryText)
                        }
                        
                        Spacer()
                        
                        HStack(spacing: DesignSystem.Spacing.xs) {
                            Text("Читать")
                                .font(DesignSystem.Typography.caption)
                                .fontWeight(.medium)
                                .foregroundColor(DesignSystem.Colors.primary)
                            
                            Image(systemName: "arrow.right")
                                .font(.system(size: 10, weight: .semibold))
                                .foregroundColor(DesignSystem.Colors.primary)
                        }
                        .padding(.horizontal, DesignSystem.Spacing.small)
                        .padding(.vertical, DesignSystem.Spacing.xs)
                        .background(
                            Capsule()
                                .fill(DesignSystem.Colors.primary.opacity(0.1))
                        )
                    }
                }
                .padding(DesignSystem.Spacing.medium)
            }
        }
        .shadow(
            color: DesignSystem.Colors.cardShadow,
            radius: isPressed ? 2 : 6,
            x: 0,
            y: isPressed ? 1 : 3
        )
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .animation(AnimationSystem.Interactive.press, value: isPressed)
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
        .sheet(isPresented: $showDetails) {
            NewsDetailView(article: article)
        }
    }
}



struct ModernLotteriesSection: View {
    let lotteries: [Lottery]
    
    var body: some View {
        VStack(spacing: DesignSystem.Spacing.medium) {
            SectionHeader(
                "Активные розыгрыши",
                actionTitle: "Все"
            ) {
                // Переход к лотереям
            }
            
            LazyVStack(spacing: DesignSystem.Spacing.medium) {
                ForEach(lotteries, id: \.id) { lottery in
                    ModernLotteryCard(lottery: lottery)
                }
            }
        }
    }
}

struct ModernLotteryCard: View {
    let lottery: Lottery
    
    var body: some View {
        ModernCard {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.medium) {
                HStack {
                    Image(systemName: "trophy.fill")
                        .font(.system(size: 24))
                        .foregroundColor(DesignSystem.Colors.accent)
                    
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                        Text(lottery.title)
                            .font(DesignSystem.Typography.headline)
                            .foregroundColor(DesignSystem.Colors.text)
                        
                        Text(lottery.prize)
                            .font(DesignSystem.Typography.callout)
                            .foregroundColor(DesignSystem.Colors.accent)
                    }
                    
                    Spacer()
                }
                
                Text(lottery.description)
                    .font(DesignSystem.Typography.body)
                    .foregroundColor(DesignSystem.Colors.secondaryText)
                    .lineLimit(2)
                
                HStack {
                    Text("Участников: \(lottery.participants.count)")
                        .font(DesignSystem.Typography.caption)
                        .foregroundColor(DesignSystem.Colors.tertiaryText)
                    
                    Spacer()
                    
                    Text("До \(lottery.endDate.formattedDate())")
                        .font(DesignSystem.Typography.caption)
                        .foregroundColor(DesignSystem.Colors.warning)
                }
                
                PrimaryButton("Участвовать") {
                    // Участие в лотерее
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
