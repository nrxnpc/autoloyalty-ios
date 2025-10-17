import SwiftUI
import Charts

// MARK: - Interactive Stats View

struct InteractiveStatsView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var achievementService = AchievementService.shared
    @State private var selectedPeriod: StatsPeriod = .week
    @State private var animateCharts = false
    @State private var showAchievements = false
    
    enum StatsPeriod: String, CaseIterable {
        case week = "Неделя"
        case month = "Месяц"
        case year = "Год"
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: DesignSystem.Spacing.large) {
                    // Заголовок с анимацией
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Ваша статистика")
                                .font(DesignSystem.Typography.largeTitle)
                                .fontWeight(.bold)
                            
                            Text("Отслеживайте свой прогресс")
                                .font(DesignSystem.Typography.callout)
                                .foregroundColor(DesignSystem.Colors.secondaryText)
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            showAchievements = true
                        }) {
                            ZStack {
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [DesignSystem.Colors.accent, Color.orange],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 50, height: 50)
                                
                                Image(systemName: "trophy.fill")
                                    .font(.system(size: 24))
                                    .foregroundColor(.white)
                                    .floating(amplitude: 3, duration: 2)
                            }
                        }
                        .scaleOnPress()
                    }
                    .slideIn(from: .top, delay: 0.1)
                    
                    // Период выбора
                    StatsPeriodSelector(selectedPeriod: $selectedPeriod)
                        .slideIn(from: .leading, delay: 0.2)
                    
                    // Основные метрики
                    StatsMetricsGrid()
                        .slideIn(from: .bottom, delay: 0.3)
                    
                    // График активности
                    ActivityChart(period: selectedPeriod, animate: animateCharts)
                        .slideIn(from: .trailing, delay: 0.4)
                    
                    // Прогресс по категориям
                    CategoryProgressView()
                        .slideIn(from: .bottom, delay: 0.5)
                    
                    // Последние достижения
                    RecentAchievementsView()
                        .slideIn(from: .leading, delay: 0.6)
                }
                .padding()
            }
            .background(DesignSystem.Colors.background)
            .navigationBarHidden(true)
            .onAppear {
                withAnimation(AnimationSystem.Spring.smooth.delay(0.5)) {
                    animateCharts = true
                }
                
                if let user = authViewModel.currentUser {
                    achievementService.checkAchievements(for: user)
                }
            }
            .sheet(isPresented: $showAchievements) {
                AchievementsView()
            }
        }
    }
}

// MARK: - Stats Period Selector

struct StatsPeriodSelector: View {
    @Binding var selectedPeriod: InteractiveStatsView.StatsPeriod
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(InteractiveStatsView.StatsPeriod.allCases, id: \.self) { period in
                Button(action: {
                    HapticService.shared.selectionChanged()
                    withAnimation(AnimationSystem.Spring.snappy) {
                        selectedPeriod = period
                    }
                }) {
                    Text(period.rawValue)
                        .font(DesignSystem.Typography.callout)
                        .fontWeight(.medium)
                        .foregroundColor(selectedPeriod == period ? .white : DesignSystem.Colors.text)
                        .padding(.horizontal, DesignSystem.Spacing.large)
                        .padding(.vertical, DesignSystem.Spacing.small)
                        .background(
                            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
                                .fill(
                                    selectedPeriod == period ?
                                        LinearGradient(
                                            colors: [DesignSystem.Colors.primary, DesignSystem.Colors.primaryLight],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        ) :
                                        LinearGradient(
                                            colors: [.clear, .clear],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                )
                        )
                }
            }
        }
        .padding(4)
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large)
                .fill(DesignSystem.Colors.secondaryBackground)
        )
    }
}

// MARK: - Stats Metrics Grid

struct StatsMetricsGrid: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: DesignSystem.Spacing.medium) {
            StatsMetricCard(
                title: "Всего баллов",
                value: "\(authViewModel.currentUser?.points ?? 0)",
                icon: "star.fill",
                color: DesignSystem.Colors.accent,
                gradient: [DesignSystem.Colors.accent, Color.orange]
            )
            
            StatsMetricCard(
                title: "Сканирований",
                value: "\(authViewModel.currentUser?.statistics.totalPurchases ?? 0)",
                icon: "qrcode.viewfinder",
                color: DesignSystem.Colors.primary,
                gradient: [DesignSystem.Colors.primary, DesignSystem.Colors.primaryLight]
            )
            
            StatsMetricCard(
                title: "Уровень",
                value: getLevelName(points: authViewModel.currentUser?.points ?? 0),
                icon: "crown.fill",
                color: DesignSystem.Colors.warning,
                gradient: [DesignSystem.Colors.warning, Color.yellow]
            )
            
            StatsMetricCard(
                title: "Достижения",
                value: "\(AchievementService.shared.achievements.filter { $0.isUnlocked }.count)",
                icon: "trophy.fill",
                color: DesignSystem.Colors.success,
                gradient: [DesignSystem.Colors.success, Color.green]
            )
        }
    }
    
    private func getLevelName(points: Int) -> String {
        if points < 5000 { return "Бронза" }
        if points < 15000 { return "Серебро" }
        return "Золото"
    }
}

// MARK: - Stats Metric Card

struct StatsMetricCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    let gradient: [Color]
    
    @State private var animateValue = false
    
    var body: some View {
        ModernCard {
            VStack(spacing: DesignSystem.Spacing.medium) {
                HStack {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: gradient,
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 40, height: 40)
                        
                        Image(systemName: icon)
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "arrow.up.right")
                        .font(.system(size: 12))
                        .foregroundColor(color)
                        .opacity(0.6)
                }
                
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                    Text(value)
                        .font(DesignSystem.Typography.title2)
                        .fontWeight(.bold)
                        .foregroundColor(DesignSystem.Colors.text)
                        .scaleEffect(animateValue ? 1.05 : 1.0)
                        .animation(AnimationSystem.Spring.bouncy, value: animateValue)
                    
                    Text(title)
                        .font(DesignSystem.Typography.caption)
                        .foregroundColor(DesignSystem.Colors.secondaryText)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .onAppear {
            withAnimation(AnimationSystem.Spring.bouncy.delay(Double.random(in: 0.1...0.5))) {
                animateValue = true
            }
        }
    }
}

// MARK: - Activity Chart

struct ActivityChart: View {
    let period: InteractiveStatsView.StatsPeriod
    let animate: Bool
    
    @State private var chartData: [ActivityDataPoint] = []
    
    struct ActivityDataPoint: Identifiable {
        let id = UUID()
        let date: Date
        let value: Int
    }
    
    var body: some View {
        ModernCard {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.medium) {
                HStack {
                    Text("Активность")
                        .font(DesignSystem.Typography.headline)
                        .fontWeight(.semibold)
                    
                    Spacer()
                    
                    Text(period.rawValue)
                        .font(DesignSystem.Typography.caption)
                        .foregroundColor(DesignSystem.Colors.secondaryText)
                }
                
                // Простой график активности
                HStack(alignment: .bottom, spacing: 4) {
                    ForEach(0..<7) { index in
                        VStack {
                            RoundedRectangle(cornerRadius: 2)
                                .fill(
                                    LinearGradient(
                                        colors: [DesignSystem.Colors.primary, DesignSystem.Colors.primaryLight],
                                        startPoint: .bottom,
                                        endPoint: .top
                                    )
                                )
                                .frame(width: 20, height: animate ? CGFloat.random(in: 20...80) : 0)
                                .animation(
                                    AnimationSystem.Spring.bouncy.delay(Double(index) * 0.1),
                                    value: animate
                                )
                            
                            Text(getDayName(for: index))
                                .font(DesignSystem.Typography.caption2)
                                .foregroundColor(DesignSystem.Colors.tertiaryText)
                        }
                    }
                }
                .frame(height: 100)
            }
        }
    }
    
    private func getDayName(for index: Int) -> String {
        let days = ["Пн", "Вт", "Ср", "Чт", "Пт", "Сб", "Вс"]
        return days[index]
    }
}

// MARK: - Category Progress View

struct CategoryProgressView: View {
    let categories = [
        ("Сканирование", 0.8, DesignSystem.Colors.primary),
        ("Покупки", 0.6, DesignSystem.Colors.accent),
        ("Активность", 0.9, DesignSystem.Colors.success),
        ("Достижения", 0.4, DesignSystem.Colors.warning)
    ]
    
    @State private var animateProgress = false
    
    var body: some View {
        ModernCard {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.medium) {
                Text("Прогресс по категориям")
                    .font(DesignSystem.Typography.headline)
                    .fontWeight(.semibold)
                
                VStack(spacing: DesignSystem.Spacing.medium) {
                    ForEach(Array(categories.enumerated()), id: \.offset) { index, category in
                        VStack(spacing: DesignSystem.Spacing.xs) {
                            HStack {
                                Text(category.0)
                                    .font(DesignSystem.Typography.callout)
                                
                                Spacer()
                                
                                Text("\(Int(category.1 * 100))%")
                                    .font(DesignSystem.Typography.caption)
                                    .fontWeight(.medium)
                                    .foregroundColor(category.2)
                            }
                            
                            GeometryReader { geometry in
                                ZStack(alignment: .leading) {
                                    Rectangle()
                                        .fill(DesignSystem.Colors.separator)
                                        .frame(height: 6)
                                        .cornerRadius(3)
                                    
                                    Rectangle()
                                        .fill(
                                            LinearGradient(
                                                colors: [category.2, category.2.opacity(0.7)],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                        .frame(
                                            width: animateProgress ? geometry.size.width * category.1 : 0,
                                            height: 6
                                        )
                                        .cornerRadius(3)
                                        .animation(
                                            AnimationSystem.Spring.smooth.delay(Double(index) * 0.1),
                                            value: animateProgress
                                        )
                                }
                            }
                            .frame(height: 6)
                        }
                    }
                }
            }
        }
        .onAppear {
            withAnimation {
                animateProgress = true
            }
        }
    }
}

// MARK: - Recent Achievements View

struct RecentAchievementsView: View {
    @StateObject private var achievementService = AchievementService.shared
    
    var body: some View {
        if !achievementService.achievements.filter({ $0.isUnlocked }).isEmpty {
            ModernCard {
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.medium) {
                    HStack {
                        Text("Последние достижения")
                            .font(DesignSystem.Typography.headline)
                            .fontWeight(.semibold)
                        
                        Spacer()
                        
                        Button("Все") {
                            // Показать все достижения
                        }
                        .font(DesignSystem.Typography.caption)
                        .foregroundColor(DesignSystem.Colors.primary)
                    }
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: DesignSystem.Spacing.medium) {
                            ForEach(achievementService.achievements.filter { $0.isUnlocked }.prefix(3)) { achievement in
                                MiniAchievementCard(achievement: achievement)
                            }
                        }
                        .padding(.horizontal, 1)
                    }
                }
            }
        }
    }
}

// MARK: - Mini Achievement Card

struct MiniAchievementCard: View {
    let achievement: Achievement
    
    var body: some View {
        VStack(spacing: DesignSystem.Spacing.small) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: achievement.category.gradient,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 40, height: 40)
                
                Image(systemName: achievement.icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
            }
            
            Text(achievement.title)
                .font(DesignSystem.Typography.caption2)
                .fontWeight(.medium)
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .frame(width: 80)
    }
}

// MARK: - Achievements View

struct AchievementsView: View {
    @StateObject private var achievementService = AchievementService.shared
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: DesignSystem.Spacing.medium) {
                    ForEach(achievementService.achievements) { achievement in
                        AchievementCard(achievement: achievement)
                    }
                }
                .padding()
            }
            .navigationTitle("Достижения")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Готово") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    InteractiveStatsView()
        .environmentObject(AuthViewModel())
}