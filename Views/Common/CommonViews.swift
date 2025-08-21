import SwiftUI

// MARK: - News Components

struct NewsCardView: View {
    let article: NewsArticle
    
    var body: some View {
        NavigationLink(value: article) {
            HStack(spacing: AppConstants.Spacing.medium) {
                // Изображение новости
                NewsImageView(article: article)
                
                VStack(alignment: .leading, spacing: 4) {
                    if article.isImportant {
                        ImportantBadge()
                    }
                    
                    Text(article.title)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .lineLimit(2)
                        .foregroundColor(.primary)
                    
                    Text(article.content)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(3)
                    
                    if let publishedAt = article.publishedAt {
                        Text(publishedAt.timeAgoDisplay())
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
            }
            .padding()
            .background(Color.white)
            .cornerRadius(12)
            .shadow(radius: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct NewsImageView: View {
    let article: NewsArticle
    
    var body: some View {
        if let imageData = article.imageData, let image = UIImage(data: imageData) {
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 80, height: 80)
                .clipped()
                .cornerRadius(8)
        } else {
            Rectangle()
                .fill(Color.secondary.opacity(0.3))
                .frame(width: 80, height: 80)
                .cornerRadius(8)
                .overlay(
                    Image(systemName: "newspaper")
                        .font(.title2)
                        .foregroundColor(.secondary)
                )
        }
    }
}

struct ImportantBadge: View {
    var body: some View {
        HStack {
            Text("ВАЖНО")
                .font(.caption2)
                .fontWeight(.bold)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(AppConstants.Colors.primary)
                .foregroundColor(.white)
                .cornerRadius(4)
            Spacer()
        }
    }
}

struct NewsListView: View {
    @EnvironmentObject var dataManager: DataManager
    
    private var publishedNews: [NewsArticle] {
        dataManager.newsState.items
            .filter { $0.isPublished }
            .sorted { $0.createdAt > $1.createdAt }
    }
    
    var body: some View {
        NavigationStack {
            Group {
                if dataManager.newsState.isLoading {
                    ProgressView("Загрузка новостей...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if publishedNews.isEmpty {
                    EmptyNewsView()
                } else {
                    List {
                        ForEach(publishedNews, id: \.id) { article in
                            NewsCardView(article: article)
                                .listRowSeparator(.hidden)
                                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                        }
                    }
                    .listStyle(PlainListStyle())
                    .navigationDestination(for: NewsArticle.self) { article in
                        NewsDetailView(article: article)
                    }
                }
            }
            .navigationTitle("Новости")
            .navigationBarTitleDisplayMode(.inline)
            .refreshable {
                await dataManager.loadDataType(.news)
            }
            .task {
                await dataManager.loadDataType(.news)
            }
        }
    }
}

struct EmptyNewsView: View {
    var body: some View {
        VStack(spacing: AppConstants.Spacing.medium) {
            Image(systemName: "newspaper")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text("Новостей пока нет")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text("Следите за обновлениями")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
    }
}



struct TagsView: View {
    let tags: [String]
    
    var body: some View {
        FlowLayout(spacing: AppConstants.Spacing.small) {
            ForEach(tags, id: \.self) { tag in
                Text("#\(tag)")
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.secondary.opacity(0.2))
                    .cornerRadius(8)
            }
        }
    }
}

// MARK: - Lottery Components

struct LotteryCardView: View {
    let lottery: Lottery
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppConstants.Spacing.medium) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(lottery.title)
                        .font(.headline)
                        .fontWeight(.bold)
                    
                    Text(lottery.description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                Spacer()
                
                VStack(spacing: 4) {
                    Text("Приз:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(lottery.prize)
                        .font(.caption)
                        .fontWeight(.medium)
                        .multilineTextAlignment(.center)
                }
            }
            
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Участников: \(lottery.participants.count)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("Мин. баллов: \(lottery.minPointsRequired)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text("До окончания:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(lottery.endDate.timeAgoDisplay())
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(AppConstants.Colors.primary)
                }
            }
        }
        .padding()
        .background(LinearGradient(
            gradient: Gradient(colors: [AppConstants.Colors.primary.opacity(0.1), Color.orange.opacity(0.1)]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        ))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(AppConstants.Colors.primary.opacity(0.3), lineWidth: 1)
        )
    }
}

struct LotteriesView: View {
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var authViewModel: AuthViewModel
    
    private var activeLotteries: [Lottery] {
        dataManager.lotteriesState.items.filter { $0.isActive }
    }
    
    var body: some View {
        Group {
            if dataManager.lotteriesState.isLoading {
                ProgressView("Загрузка розыгрышей...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if activeLotteries.isEmpty {
                EmptyLotteriesView()
            } else {
                List {
                    ForEach(activeLotteries, id: \.id) { lottery in
                        LotteryDetailCard(lottery: lottery)
                            .listRowSeparator(.hidden)
                            .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                    }
                }
                .listStyle(PlainListStyle())
            }
        }
        .navigationTitle("Розыгрыши")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await dataManager.loadDataType(.lotteries)
        }
    }
}

struct EmptyLotteriesView: View {
    var body: some View {
        VStack(spacing: AppConstants.Spacing.medium) {
            Image(systemName: "trophy")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text("Нет активных розыгрышей")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text("Розыгрыши появятся в ближайшее время")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}

struct LotteryDetailCard: View {
    let lottery: Lottery
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppConstants.Spacing.medium) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(lottery.title)
                        .font(.title3)
                        .fontWeight(.bold)
                    
                    Text(lottery.description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            
            if let imageData = lottery.imageData, let image = UIImage(data: imageData) {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 120)
                    .clipped()
                    .cornerRadius(8)
            }
            
            LotteryInfoSection(lottery: lottery)
            
            ParticipateButton(lottery: lottery)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

struct LotteryInfoSection: View {
    let lottery: Lottery
    
    var body: some View {
        VStack(spacing: AppConstants.Spacing.small) {
            InfoRow(label: "Приз:", value: lottery.prize)
            InfoRow(label: "Участников:", value: "\(lottery.participants.count)")
            InfoRow(label: "Минимум баллов:", value: "\(lottery.minPointsRequired)")
            InfoRow(label: "Окончание:", value: lottery.endDate.formattedDate())
        }
    }
}

struct InfoRow: View {
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

struct ParticipateButton: View {
    let lottery: Lottery
    @EnvironmentObject var authViewModel: AuthViewModel
    
    private var canParticipate: Bool {
        (authViewModel.currentUser?.points ?? 0) >= lottery.minPointsRequired &&
        !lottery.participants.contains(authViewModel.currentUser?.id ?? "") &&
        lottery.endDate > Date()
    }
    
    private var buttonText: String {
        if lottery.participants.contains(authViewModel.currentUser?.id ?? "") {
            return "Вы участвуете"
        } else if lottery.endDate <= Date() {
            return "Розыгрыш завершён"
        } else if (authViewModel.currentUser?.points ?? 0) < lottery.minPointsRequired {
            return "Недостаточно баллов"
        } else {
            return "Участвовать"
        }
    }
    
    var body: some View {
        Button(action: {
            participateInLottery()
        }) {
            Text(buttonText)
                .frame(maxWidth: .infinity)
                .padding()
                .background(canParticipate ? AppConstants.Colors.primary : Color.secondary)
                .foregroundColor(.white)
                .cornerRadius(8)
        }
        .disabled(!canParticipate)
    }
    
    private func participateInLottery() {
        guard let userId = authViewModel.currentUser?.id else { return }
        
        // Проверяем возможность участия
        guard canParticipate else { return }
        
        // Списываем баллы
        if authViewModel.spendPoints(lottery.minPointsRequired) {
            // Добавляем пользователя в участники
            var updatedLottery = lottery
            updatedLottery.participants.append(userId)
            
            // Обновляем лотерею в данных
            // dataManager.updateLottery(updatedLottery)
        }
    }
}

// MARK: - Settings and Info Views

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var notificationsEnabled = true
    @State private var emailNotifications = true
    @State private var pushNotifications = true
    @State private var biometricEnabled = false
    @State private var autoSync = true
    
    var body: some View {
        NavigationStack {
            List {
                Section("Уведомления") {
                    Toggle("Push-уведомления", isOn: $pushNotifications)
                        .tint(AppConstants.Colors.primary)
                    
                    Toggle("Email уведомления", isOn: $emailNotifications)
                        .tint(AppConstants.Colors.primary)
                }
                
                Section("Безопасность") {
                    Toggle("Биометрическая аутентификация", isOn: $biometricEnabled)
                        .tint(AppConstants.Colors.primary)
                }
                
                Section("Синхронизация") {
                    Toggle("Автоматическая синхронизация", isOn: $autoSync)
                        .tint(AppConstants.Colors.primary)
                }
                
                Section("О приложении") {
                    HStack {
                        Text("Версия")
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



// MARK: - Custom Layout for Tags

struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(
            in: proposal.replacingUnspecifiedDimensions().width,
            subviews: subviews,
            spacing: spacing
        )
        return result.bounds
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(
            in: bounds.width,
            subviews: subviews,
            spacing: spacing
        )
        
        for (index, subview) in subviews.enumerated() {
            subview.place(at: result.frames[index].origin, proposal: .unspecified)
        }
    }
    
    struct FlowResult {
        var frames: [CGRect] = []
        var bounds: CGSize = .zero
        
        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var currentX: CGFloat = 0
            var currentY: CGFloat = 0
            var rowHeight: CGFloat = 0
            
            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)
                
                if currentX + size.width > maxWidth && currentX > 0 {
                    // Переход на новую строку
                    currentX = 0
                    currentY += rowHeight + spacing
                    rowHeight = 0
                }
                
                frames.append(CGRect(
                    x: currentX,
                    y: currentY,
                    width: size.width,
                    height: size.height
                ))
                
                currentX += size.width + spacing
                rowHeight = max(rowHeight, size.height)
            }
            
            bounds = CGSize(
                width: maxWidth,
                height: currentY + rowHeight
            )
        }
    }
}

#Preview {
    NavigationStack {
        NewsListView()
            .environmentObject(DataManager())
    }
}
