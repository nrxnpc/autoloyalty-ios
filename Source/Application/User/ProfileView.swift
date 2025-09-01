import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var dataManager: DataManager
    @State private var showingSettings = false
    @State private var showingEditProfile = false
    @State private var showingLogoutAlert = false
    
    var body: some View {
        NavigationStack {
            List {
                ProfileHeaderSection()
                
                ActivitySection()
                
                SupportSection()
                
                SettingsSection(
                    showingSettings: $showingSettings,
                    showingLogoutAlert: $showingLogoutAlert
                )
            }
            .navigationTitle("Профиль")
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
            .sheet(isPresented: $showingEditProfile) {
                EditProfileView()
            }
            .alert("Выход из аккаунта", isPresented: $showingLogoutAlert) {
                Button("Отмена", role: .cancel) { }
                Button("Выйти", role: .destructive) {
                    authViewModel.logout()
                }
            } message: {
                Text("Вы уверены, что хотите выйти из аккаунта?")
            }
        }
    }
}

struct ProfileHeaderSection: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var showingEditProfile = false
    
    var body: some View {
        Section {
            HStack {
                ProfileAvatarView(user: authViewModel.currentUser)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(authViewModel.currentUser?.name ?? "Пользователь")
                        .font(.headline)
                    
                    Text(authViewModel.currentUser?.email ?? "")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    PointsBadge(points: authViewModel.currentUser?.points ?? 0)
                }
                
                Spacer()
                
                Button(action: { showingEditProfile = true }) {
                    Image(systemName: "pencil")
                        .foregroundColor(AppConstants.Colors.primary)
                }
            }
            .padding(.vertical, AppConstants.Spacing.small)
        }
        .sheet(isPresented: $showingEditProfile) {
            EditProfileView()
        }
    }
}

struct ProfileAvatarView: View {
    let user: User?
    
    var body: some View {
        Circle()
            .fill(AppConstants.Colors.primary.opacity(0.2))
            .frame(width: 60, height: 60)
            .overlay(
                Text(user?.name.prefix(1) ?? "U")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(AppConstants.Colors.primary)
            )
    }
}

struct PointsBadge: View {
    let points: Int
    
    var body: some View {
        Text("\(points) баллов")
            .font(.caption)
            .foregroundColor(AppConstants.Colors.primary)
            .fontWeight(.medium)
    }
}

struct ActivitySection: View {
    var body: some View {
        Section("Активность") {
            NavigationLink(destination: QRScanHistoryView()) {
                ProfileMenuItem(
                    icon: "qrcode",
                    title: "История сканирований",
                    subtitle: "Ваши QR-коды"
                )
            }
            
            NavigationLink(destination: MyOrdersView()) {
                ProfileMenuItem(
                    icon: "bag",
                    title: "Мои заказы",
                    subtitle: "Обмены баллов"
                )
            }
            
            NavigationLink(destination: PointsHistoryView()) {
                ProfileMenuItem(
                    icon: "creditcard",
                    title: "История баллов",
                    subtitle: "Начисления и списания"
                )
            }
            
            NavigationLink(destination: LikedCarsView(likedCarIds: [])) {
                ProfileMenuItem(
                    icon: "heart",
                    title: "Понравившиеся авто",
                    subtitle: "Избранные автомобили"
                )
            }
            
            NavigationLink(destination: PriceRequestsView()) {
                ProfileMenuItem(
                    icon: "questionmark.circle",
                    title: "Запросы цены",
                    subtitle: "Заявки дилерам"
                )
            }
        }
    }
}

struct SupportSection: View {
    var body: some View {
        Section("Поддержка") {
            NavigationLink(destination: SupportChatView()) {
                ProfileMenuItem(
                    icon: "message",
                    title: "Чат с поддержкой",
                    subtitle: "Онлайн помощь"
                )
            }
            
            NavigationLink(destination: SupportTicketsView()) {
                ProfileMenuItem(
                    icon: "folder",
                    title: "Мои обращения",
                    subtitle: "История тикетов"
                )
            }
            
            NavigationLink(destination: FAQView()) {
                ProfileMenuItem(
                    icon: "questionmark.circle",
                    title: "Часто задаваемые вопросы",
                    subtitle: "База знаний"
                )
            }
        }
    }
}

struct SettingsSection: View {
    @Binding var showingSettings: Bool
    @Binding var showingLogoutAlert: Bool
    
    var body: some View {
        Section("Настройки") {
            Button(action: { showingSettings = true }) {
                ProfileMenuItem(
                    icon: "gear",
                    title: "Настройки приложения",
                    subtitle: "Уведомления, безопасность"
                )
            }
            .foregroundColor(.primary)
            
            NavigationLink(destination: AboutView()) {
                ProfileMenuItem(
                    icon: "info.circle",
                    title: "О приложении",
                    subtitle: "Версия и контакты"
                )
            }
        }
        
        Section {
            Button(action: { showingLogoutAlert = true }) {
                HStack {
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                        .foregroundColor(AppConstants.Colors.primary)
                        .frame(width: 24, height: 24)
                    
                    Text("Выйти из аккаунта")
                        .foregroundColor(AppConstants.Colors.primary)
                    
                    Spacer()
                }
            }
        }
    }
}

struct ProfileMenuItem: View {
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

struct MyOrdersView: View {
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var authViewModel: AuthViewModel
    
    private var userOrders: [Order] {
        dataManager.ordersState.items.filter { $0.userId == authViewModel.currentUser?.id }
    }
    
    var body: some View {
        Group {
            if dataManager.ordersState.isLoading {
                ProgressView("Загрузка заказов...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if userOrders.isEmpty {
                EmptyOrdersView()
            } else {
                List {
                    ForEach(userOrders.sorted(by: { $0.createdAt > $1.createdAt }), id: \.id) { order in
                        OrderRow(order: order)
                            .listRowSeparator(.hidden)
                            .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                    }
                }
                .listStyle(PlainListStyle())
            }
        }
        .navigationTitle("Мои заказы")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await dataManager.loadDataType(.orders)
        }
    }
}

struct EmptyOrdersView: View {
    var body: some View {
        VStack(spacing: AppConstants.Spacing.medium) {
            Image(systemName: "bag")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text("У вас пока нет заказов")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text("Обменивайте баллы на товары в каталоге")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}

struct OrderRow: View {
    let order: Order
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppConstants.Spacing.medium) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(order.product.name)
                        .font(.headline)
                        .fontWeight(.medium)
                    
                    Text("Заказ #\(order.id.prefix(8))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text("\(order.pointsSpent)")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(AppConstants.Colors.primary)
                    Text("баллов")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            HStack {
                Text(order.status.displayName)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(order.status.color.opacity(0.2))
                    .foregroundColor(order.status.color)
                    .cornerRadius(8)
                
                Spacer()
                
                Text(order.createdAt.formattedDate())
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            if let deliveryAddress = order.deliveryAddress {
                Text("Адрес: \(deliveryAddress)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

struct PointsHistoryView: View {
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var authViewModel: AuthViewModel
    
    private var userTransactions: [PointTransaction] {
        dataManager.pointTransactionsState.items.filter { $0.userId == authViewModel.currentUser?.id }
    }
    
    var body: some View {
        Group {
            if dataManager.pointTransactionsState.isLoading {
                ProgressView("Загрузка истории...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if userTransactions.isEmpty {
                EmptyTransactionsView()
            } else {
                List {
                    ForEach(userTransactions.sorted(by: { $0.timestamp > $1.timestamp }), id: \.id) { transaction in
                        PointTransactionRow(transaction: transaction)
                            .listRowSeparator(.hidden)
                            .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                    }
                }
                .listStyle(PlainListStyle())
            }
        }
        .navigationTitle("История баллов")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await dataManager.loadDataType(.pointTransactions)
        }
    }
}

struct EmptyTransactionsView: View {
    var body: some View {
        VStack(spacing: AppConstants.Spacing.medium) {
            Image(systemName: "creditcard")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text("История операций пуста")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text("Сканируйте QR-коды для получения баллов")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}

struct PointTransactionRow: View {
    let transaction: PointTransaction
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(transaction.description)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(transaction.type.displayName)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(transaction.timestamp.timeAgoDisplay())
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text("\(transaction.type.sign)\(transaction.amount)")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(transaction.type.color)
                
                Text("баллов")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 1)
    }
}

struct PriceRequestsView: View {
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var authViewModel: AuthViewModel
    
    private var userRequests: [PriceRequest] {
        dataManager.priceRequestsState.items.filter { $0.userId == authViewModel.currentUser?.id }
    }
    
    var body: some View {
        Group {
            if dataManager.priceRequestsState.isLoading {
                ProgressView("Загрузка запросов...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if userRequests.isEmpty {
                EmptyPriceRequestsView()
            } else {
                List {
                    ForEach(userRequests.sorted(by: { $0.createdAt > $1.createdAt }), id: \.id) { request in
                        PriceRequestRow(request: request)
                            .listRowSeparator(.hidden)
                            .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                    }
                }
                .listStyle(PlainListStyle())
            }
        }
        .navigationTitle("Запросы цены")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await dataManager.loadDataType(.priceRequests)
        }
    }
}

struct EmptyPriceRequestsView: View {
    var body: some View {
        VStack(spacing: AppConstants.Spacing.medium) {
            Image(systemName: "questionmark.circle")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text("Нет запросов цены")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text("Найдите автомобиль в Автотиндере и запросите цену")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}

struct PriceRequestRow: View {
    let request: PriceRequest
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppConstants.Spacing.medium) {
            HStack(spacing: AppConstants.Spacing.medium) {
                if let imageData = request.car.imageData, let image = UIImage(data: imageData) {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 60, height: 45)
                        .clipped()
                        .cornerRadius(6)
                } else {
                    Rectangle()
                        .fill(Color.secondary.opacity(0.3))
                        .frame(width: 60, height: 45)
                        .cornerRadius(6)
                        .overlay(
                            Image(systemName: AppConstants.Images.car)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        )
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("\(request.car.brand) \(request.car.model)")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    Text("\(request.car.year) год")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text(request.status.displayName)
                        .font(.caption)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(request.status.color.opacity(0.2))
                        .foregroundColor(request.status.color)
                        .cornerRadius(4)
                    
                    Text(request.createdAt.formattedDate())
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            if let message = request.userMessage {
                Text("Сообщение: \(message)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            if let response = request.dealerResponse {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Ответ дилера:")
                        .font(.caption)
                        .fontWeight(.medium)
                    
                    Text(response)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    if let price = request.estimatedPrice {
                        Text("Цена: \(price)")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(AppConstants.Colors.primary)
                    }
                }
                .padding()
                .background(Color.green.opacity(0.1))
                .cornerRadius(8)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

struct EditProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var email = ""
    @State private var phone = ""
    
    var body: some View {
        NavigationStack {
            VStack(spacing: AppConstants.Spacing.large) {
                VStack(spacing: AppConstants.Spacing.medium) {
                    ProfileFieldRow(
                        icon: "person",
                        placeholder: "Имя",
                        text: $name
                    )
                    
                    ProfileFieldRow(
                        icon: "envelope",
                        placeholder: "Email",
                        text: $email,
                        keyboardType: .emailAddress
                    )
                    
                    ProfileFieldRow(
                        icon: "phone",
                        placeholder: "Телефон",
                        text: $phone,
                        keyboardType: .phonePad
                    )
                }
                .padding()
                
                Spacer()
                
                Button("Сохранить изменения") {
                    authViewModel.updateProfile(name: name, email: email, phone: phone)
                    dismiss()
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(AppConstants.Colors.primary)
                .foregroundColor(.white)
                .cornerRadius(12)
                .padding(.horizontal)
            }
            .navigationTitle("Редактировать профиль")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                name = authViewModel.currentUser?.name ?? ""
                email = authViewModel.currentUser?.email ?? ""
                phone = authViewModel.currentUser?.phone ?? ""
            }
        }
    }
}

struct ProfileFieldRow: View {
    let icon: String
    let placeholder: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.secondary)
                .frame(width: 20)
            
            TextField(placeholder, text: $text)
                .keyboardType(keyboardType)
        }
        .padding()
        .background(Color.secondary.opacity(0.1))
        .cornerRadius(12)
    }
}

#Preview {
    NavigationStack {
        ProfileView()
            .environmentObject(AuthViewModel())
            .environmentObject(DataManager())
    }
}
