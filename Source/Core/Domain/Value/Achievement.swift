import SwiftUI

// MARK: - Achievement System

struct Achievement: Identifiable, Codable, Equatable {
    let id: String
    let title: String
    let description: String
    let icon: String
    let category: AchievementCategory
    let requirement: Int
    let reward: AchievementReward
    let rarity: AchievementRarity
    var isUnlocked: Bool
    var progress: Int
    let unlockedAt: Date?
    
    enum AchievementCategory: String, CaseIterable, Codable {
        case scanning = "scanning"
        case loyalty = "loyalty"
        case social = "social"
        case special = "special"
        
        var displayName: String {
            switch self {
            case .scanning: return "Сканирование"
            case .loyalty: return "Лояльность"
            case .social: return "Социальные"
            case .special: return "Особые"
            }
        }
        
        var color: Color {
            switch self {
            case .scanning: return DesignSystem.Colors.primary
            case .loyalty: return DesignSystem.Colors.accent
            case .social: return DesignSystem.Colors.success
            case .special: return DesignSystem.Colors.warning
            }
        }
        
        var gradient: [Color] {
            switch self {
            case .scanning: return [DesignSystem.Colors.primary, DesignSystem.Colors.primaryLight]
            case .loyalty: return [DesignSystem.Colors.accent, Color.orange]
            case .social: return [DesignSystem.Colors.success, Color.green]
            case .special: return [DesignSystem.Colors.warning, Color.yellow]
            }
        }
    }
    
    enum AchievementRarity: String, CaseIterable, Codable {
        case common = "common"
        case rare = "rare"
        case epic = "epic"
        case legendary = "legendary"
        
        var displayName: String {
            switch self {
            case .common: return "Обычное"
            case .rare: return "Редкое"
            case .epic: return "Эпическое"
            case .legendary: return "Легендарное"
            }
        }
        
        var color: Color {
            switch self {
            case .common: return .gray
            case .rare: return .blue
            case .epic: return .purple
            case .legendary: return .orange
            }
        }
        
        var glowColor: Color {
            switch self {
            case .common: return .clear
            case .rare: return .blue.opacity(0.3)
            case .epic: return .purple.opacity(0.3)
            case .legendary: return .orange.opacity(0.5)
            }
        }
    }
    
    struct AchievementReward: Codable {
        let points: Int
        let title: String?
        let badge: String?
    }
    
    var progressPercentage: Double {
        guard requirement > 0 else { return 0 }
        return min(Double(progress) / Double(requirement), 1.0)
    }
    
    static func == (lhs: Achievement, rhs: Achievement) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Achievement Service

@MainActor
class AchievementService: ObservableObject {
    static let shared = AchievementService()
    
    @Published var achievements: [Achievement] = []
    @Published var recentUnlocks: [Achievement] = []
    
    private init() {
        loadAchievements()
    }
    
    private func loadAchievements() {
        achievements = [
            Achievement(
                id: "first_scan",
                title: "Первое сканирование",
                description: "Отсканируйте свой первый QR-код",
                icon: "qrcode.viewfinder",
                category: .scanning,
                requirement: 1,
                reward: Achievement.AchievementReward(points: 100, title: "Новичок", badge: "scanner_badge"),
                rarity: .common,
                isUnlocked: false,
                progress: 0,
                unlockedAt: nil
            ),
            Achievement(
                id: "scan_master",
                title: "Мастер сканирования",
                description: "Отсканируйте 100 QR-кодов",
                icon: "target",
                category: .scanning,
                requirement: 100,
                reward: Achievement.AchievementReward(points: 1000, title: "Мастер", badge: "master_badge"),
                rarity: .rare,
                isUnlocked: false,
                progress: 0,
                unlockedAt: nil
            ),
            Achievement(
                id: "loyalty_bronze",
                title: "Бронзовый статус",
                description: "Достигните бронзового уровня лояльности",
                icon: "star.fill",
                category: .loyalty,
                requirement: 1000,
                reward: Achievement.AchievementReward(points: 500, title: "Бронзовый", badge: "bronze_badge"),
                rarity: .common,
                isUnlocked: false,
                progress: 0,
                unlockedAt: nil
            ),
            Achievement(
                id: "loyalty_gold",
                title: "Золотой статус",
                description: "Достигните золотого уровня лояльности",
                icon: "crown.fill",
                category: .loyalty,
                requirement: 15000,
                reward: Achievement.AchievementReward(points: 2500, title: "Золотой", badge: "gold_badge"),
                rarity: .legendary,
                isUnlocked: false,
                progress: 0,
                unlockedAt: nil
            ),
            Achievement(
                id: "early_bird",
                title: "Ранняя пташка",
                description: "Войдите в приложение до 7 утра",
                icon: "sunrise.fill",
                category: .special,
                requirement: 1,
                reward: Achievement.AchievementReward(points: 200, title: "Ранняя пташка", badge: "early_badge"),
                rarity: .rare,
                isUnlocked: false,
                progress: 0,
                unlockedAt: nil
            )
        ]
    }
    
    func checkAchievements(for user: User) {
        var newUnlocks: [Achievement] = []
        
        for i in achievements.indices {
            if !achievements[i].isUnlocked {
                let shouldUnlock = checkAchievementCondition(achievements[i], for: user)
                
                if shouldUnlock {
                    achievements[i].isUnlocked = true
                    achievements[i].progress = achievements[i].requirement
                    newUnlocks.append(achievements[i])
                } else {
                    // Обновляем прогресс
                    achievements[i].progress = getProgressForAchievement(achievements[i], for: user)
                }
            }
        }
        
        // Показываем новые достижения
        for achievement in newUnlocks {
            showAchievementUnlock(achievement)
        }
        
        recentUnlocks.append(contentsOf: newUnlocks)
    }
    
    private func checkAchievementCondition(_ achievement: Achievement, for user: User) -> Bool {
        switch achievement.id {
        case "first_scan":
            return user.statistics.totalPurchases >= 1
        case "scan_master":
            return user.statistics.totalPurchases >= 100
        case "loyalty_bronze":
            return user.points >= 1000
        case "loyalty_gold":
            return user.points >= 15000
        case "early_bird":
            let hour = Calendar.current.component(.hour, from: Date())
            return hour < 7
        default:
            return false
        }
    }
    
    private func getProgressForAchievement(_ achievement: Achievement, for user: User) -> Int {
        switch achievement.id {
        case "first_scan", "scan_master":
            return min(user.statistics.totalPurchases, achievement.requirement)
        case "loyalty_bronze", "loyalty_gold":
            return min(user.points, achievement.requirement)
        default:
            return 0
        }
    }
    
    private func showAchievementUnlock(_ achievement: Achievement) {
        HapticService.shared.levelUp()
        ToastService.shared.success("🏆 Достижение разблокировано: \(achievement.title)")
    }
}

// MARK: - Achievement Card View

struct AchievementCard: View {
    let achievement: Achievement
    @State private var showDetails = false
    @State private var isGlowing = false
    
    var body: some View {
        HapticButton(hapticType: .light, action: {
            showDetails = true
        }) {
            ZStack {
                // Основной фон
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large)
                    .fill(
                        LinearGradient(
                            colors: achievement.isUnlocked ? 
                                achievement.category.gradient : 
                                [DesignSystem.Colors.secondaryBackground, DesignSystem.Colors.tertiaryBackground],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large)
                            .stroke(
                                achievement.rarity.color.opacity(achievement.isUnlocked ? 0.8 : 0.3),
                                lineWidth: achievement.isUnlocked ? 2 : 1
                            )
                    )
                
                // Эффект свечения для редких достижений
                if achievement.isUnlocked && achievement.rarity != .common {
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large)
                        .stroke(achievement.rarity.glowColor, lineWidth: 4)
                        .blur(radius: 8)
                        .opacity(isGlowing ? 0.8 : 0.4)
                        .animation(
                            Animation.easeInOut(duration: 2.0).repeatForever(autoreverses: true),
                            value: isGlowing
                        )
                }
                
                VStack(spacing: DesignSystem.Spacing.medium) {
                    // Иконка достижения
                    ZStack {
                        Circle()
                            .fill(
                                achievement.isUnlocked ? 
                                    LinearGradient(
                                        colors: achievement.category.gradient,
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ) :
                                    LinearGradient(
                                        colors: [DesignSystem.Colors.border, DesignSystem.Colors.separator],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                            )
                            .frame(width: 60, height: 60)
                        
                        Image(systemName: achievement.icon)
                            .font(.system(size: 28, weight: .semibold))
                            .foregroundColor(achievement.isUnlocked ? .white : DesignSystem.Colors.secondaryText)
                            .scaleEffect(achievement.isUnlocked ? 1.0 : 0.8)
                    }
                    
                    // Информация о достижении
                    VStack(spacing: DesignSystem.Spacing.xs) {
                        Text(achievement.title)
                            .font(DesignSystem.Typography.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(achievement.isUnlocked ? .white : DesignSystem.Colors.text)
                            .multilineTextAlignment(.center)
                        
                        Text(achievement.description)
                            .font(DesignSystem.Typography.caption)
                            .foregroundColor(achievement.isUnlocked ? .white.opacity(0.8) : DesignSystem.Colors.secondaryText)
                            .multilineTextAlignment(.center)
                            .lineLimit(2)
                    }
                    
                    // Прогресс бар
                    if !achievement.isUnlocked {
                        VStack(spacing: DesignSystem.Spacing.xs) {
                            ProgressView(value: achievement.progressPercentage)
                                .progressViewStyle(LinearProgressViewStyle(tint: achievement.category.color))
                                .background(DesignSystem.Colors.separator)
                                .cornerRadius(2)
                            
                            Text("\(achievement.progress)/\(achievement.requirement)")
                                .font(DesignSystem.Typography.caption2)
                                .foregroundColor(DesignSystem.Colors.tertiaryText)
                        }
                    } else {
                        // Награда
                        HStack(spacing: DesignSystem.Spacing.xs) {
                            Image(systemName: "star.fill")
                                .font(.system(size: 12))
                                .foregroundColor(.yellow)
                            
                            Text("+\(achievement.reward.points) баллов")
                                .font(DesignSystem.Typography.caption)
                                .fontWeight(.medium)
                                .foregroundColor(.white)
                        }
                        .padding(.horizontal, DesignSystem.Spacing.small)
                        .padding(.vertical, DesignSystem.Spacing.xs)
                        .background(
                            Capsule()
                                .fill(.white.opacity(0.2))
                        )
                    }
                }
                .padding(DesignSystem.Spacing.medium)
            }
        }
        .shadow(
            color: achievement.isUnlocked ? achievement.rarity.glowColor : DesignSystem.Colors.cardShadow,
            radius: achievement.isUnlocked ? 8 : 4,
            x: 0,
            y: achievement.isUnlocked ? 4 : 2
        )
        .onAppear {
            if achievement.isUnlocked && achievement.rarity != .common {
                isGlowing = true
            }
        }
        .sheet(isPresented: $showDetails) {
            AchievementDetailView(achievement: achievement)
        }
    }
}

// MARK: - Achievement Detail View

struct AchievementDetailView: View {
    let achievement: Achievement
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: DesignSystem.Spacing.xl) {
                    // Большая иконка
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: achievement.category.gradient,
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 120, height: 120)
                        
                        Image(systemName: achievement.icon)
                            .font(.system(size: 60, weight: .semibold))
                            .foregroundColor(.white)
                    }
                    .floating(amplitude: 8, duration: 3)
                    
                    VStack(spacing: DesignSystem.Spacing.medium) {
                        Text(achievement.title)
                            .font(DesignSystem.Typography.largeTitle)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                        
                        Text(achievement.description)
                            .font(DesignSystem.Typography.body)
                            .foregroundColor(DesignSystem.Colors.secondaryText)
                            .multilineTextAlignment(.center)
                        
                        // Статистика
                        VStack(spacing: DesignSystem.Spacing.small) {
                            HStack {
                                Text("Категория:")
                                Spacer()
                                Text(achievement.category.displayName)
                                    .fontWeight(.medium)
                            }
                            
                            HStack {
                                Text("Редкость:")
                                Spacer()
                                Text(achievement.rarity.displayName)
                                    .fontWeight(.medium)
                                    .foregroundColor(achievement.rarity.color)
                            }
                            
                            HStack {
                                Text("Награда:")
                                Spacer()
                                Text("+\(achievement.reward.points) баллов")
                                    .fontWeight(.medium)
                                    .foregroundColor(DesignSystem.Colors.success)
                            }
                        }
                        .padding()
                        .background(DesignSystem.Colors.secondaryBackground)
                        .cornerRadius(DesignSystem.CornerRadius.medium)
                    }
                }
                .padding()
            }
            .navigationTitle("Достижение")
            .navigationBarTitleDisplayMode(.inline)
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