import SwiftUI

struct UserManagementView: View {
    @EnvironmentObject private var dataManager: DataManager
    @State private var searchText = ""
    @State private var selectedRole: User.UserRole?
    @State private var showingUserDetail = false
    @State private var selectedUser: User?
    
    private var filteredUsers: [User] {
        var users = dataManager.usersState.items
        
        if !searchText.isEmpty {
            users = users.filter { user in
                user.name.localizedCaseInsensitiveContains(searchText) ||
                user.email.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        if let role = selectedRole {
            users = users.filter { $0.role == role }
        }
        
        return users.sorted { $0.name < $1.name }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Поиск и фильтры
            VStack(spacing: 12) {
                SearchBar(text: $searchText)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        FilterButton(title: "Все", isSelected: selectedRole == nil) {
                            selectedRole = nil
                        }
                        
                        ForEach(User.UserRole.allCases, id: \.self) { role in
                            FilterButton(
                                title: role.displayName,
                                isSelected: selectedRole == role
                            ) {
                                selectedRole = role
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .padding(.vertical)
            
            // Список пользователей
            List {
                ForEach(filteredUsers) { user in
                    UserRow(user: user) {
                        selectedUser = user
                        showingUserDetail = true
                    }
                }
            }
            .listStyle(PlainListStyle())
        }
        .navigationTitle("Управление пользователями")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingUserDetail) {
            if let user = selectedUser {
                UserDetailView(user: user)
            }
        }
        .task {
            await dataManager.loadDataType(.users)
        }
    }
}

struct UserRow: View {
    let user: User
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // Аватар
                Circle()
                    .fill(Color.blue.opacity(0.2))
                    .frame(width: 50, height: 50)
                    .overlay(
                        Text(String(user.name.prefix(1)))
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.blue)
                    )
                
                // Информация о пользователе
                VStack(alignment: .leading, spacing: 4) {
                    Text(user.name)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(user.email)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    HStack {
                        RoleBadge(role: user.role)
                        
                        Spacer()
                        
                        Text("\(user.points) баллов")
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                }
                
                Spacer()
                
                // Статус активности
                Circle()
                    .fill(user.isActive ? Color.green : Color.red)
                    .frame(width: 12, height: 12)
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct RoleBadge: View {
    let role: User.UserRole
    
    var body: some View {
        Text(role.displayName)
            .font(.caption)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(roleColor.opacity(0.2))
            .foregroundColor(roleColor)
            .cornerRadius(6)
    }
    
    private var roleColor: Color {
        switch role {
        case .customer: return .blue
        case .participant: return .green
        case .supplierAdmin: return .orange
        case .supplierManager: return .yellow
        case .platformAdmin: return .red
        case .platformOperator: return .purple
        }
    }
}

struct UserDetailView: View {
    @State var user: User
    @EnvironmentObject private var dataManager: DataManager
    @Environment(\.dismiss) private var dismiss
    @State private var showingRoleChange = false
    @State private var showingPointsAdjustment = false
    @State private var pointsAdjustment = ""
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Профиль пользователя
                    UserProfileCard(user: user)
                    
                    // Статистика
                    UserStatsCard(user: user)
                    
                    // Действия администратора
                    AdminActionsCard(
                        user: user,
                        onRoleChange: { showingRoleChange = true },
                        onPointsAdjustment: { showingPointsAdjustment = true },
                        onToggleActive: { toggleUserActive() }
                    )
                    
                    // История активности
                    UserActivityCard(user: user)
                }
                .padding()
            }
            .navigationTitle("Пользователь")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Готово") { dismiss() }
                }
            }
        }
        .sheet(isPresented: $showingRoleChange) {
            RoleChangeView(user: $user)
        }
        .sheet(isPresented: $showingPointsAdjustment) {
            PointsAdjustmentView(user: $user)
        }
    }
    
    private func toggleUserActive() {
        user.isActive.toggle()
        dataManager.updateUser(user)
    }
}

struct UserProfileCard: View {
    let user: User
    
    var body: some View {
        VStack(spacing: 16) {
            // Аватар
            Circle()
                .fill(Color.blue.opacity(0.2))
                .frame(width: 80, height: 80)
                .overlay(
                    Text(String(user.name.prefix(1)))
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                )
            
            // Основная информация
            VStack(spacing: 8) {
                Text(user.name)
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text(user.email)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text(user.phone)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                HStack {
                    RoleBadge(role: user.role)
                    
                    Text(user.userType.displayName)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(6)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct UserStatsCard: View {
    let user: User
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Статистика")
                .font(.headline)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                StatItem(title: "Баллы", value: "\(user.points)")
                StatItem(title: "Покупки", value: "\(user.statistics.totalPurchases)")
                StatItem(title: "Потрачено", value: String(format: "%.0f ₽", user.statistics.totalSpent))
                StatItem(title: "Заработано", value: "\(user.statistics.totalPointsEarned)")
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct StatItem: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.blue)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.white)
        .cornerRadius(8)
    }
}

struct AdminActionsCard: View {
    let user: User
    let onRoleChange: () -> Void
    let onPointsAdjustment: () -> Void
    let onToggleActive: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Действия администратора")
                .font(.headline)
            
            VStack(spacing: 8) {
                ActionButton(
                    title: "Изменить роль",
                    icon: "person.badge.key",
                    action: onRoleChange
                )
                
                ActionButton(
                    title: "Корректировка баллов",
                    icon: "plus.minus",
                    action: onPointsAdjustment
                )
                
                ActionButton(
                    title: user.isActive ? "Деактивировать" : "Активировать",
                    icon: user.isActive ? "pause.circle" : "play.circle",
                    color: user.isActive ? .red : .green,
                    action: onToggleActive
                )
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct ActionButton: View {
    let title: String
    let icon: String
    var color: Color = .blue
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                
                Text(title)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
                    .font(.caption)
            }
            .padding()
            .background(Color.white)
            .cornerRadius(8)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct UserActivityCard: View {
    let user: User
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Активность")
                .font(.headline)
            
            VStack(alignment: .leading, spacing: 8) {
                ActivityItem(
                    title: "Регистрация",
                    date: user.registrationDate,
                    icon: "person.badge.plus"
                )
                
                ActivityItem(
                    title: "Последняя активность",
                    date: user.statistics.lastActivityDate,
                    icon: "clock"
                )
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct ActivityItem: View {
    let title: String
    let date: Date
    let icon: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 20)
            
            Text(title)
                .font(.subheadline)
            
            Spacer()
            
            Text(date.formatted(.dateTime.day().month().year()))
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(8)
    }
}

struct RoleChangeView: View {
    @Binding var user: User
    @EnvironmentObject private var dataManager: DataManager
    @Environment(\.dismiss) private var dismiss
    @State private var selectedRole: User.UserRole
    
    init(user: Binding<User>) {
        self._user = user
        self._selectedRole = State(initialValue: user.wrappedValue.role)
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Изменение роли пользователя")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text(user.name)
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                VStack(spacing: 12) {
                    ForEach(User.UserRole.allCases, id: \.self) { role in
                        RoleOption(
                            role: role,
                            isSelected: selectedRole == role
                        ) {
                            selectedRole = role
                        }
                    }
                }
                
                Spacer()
                
                Button("Сохранить") {
                    user.role = selectedRole
                    dataManager.updateUser(user)
                    dismiss()
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(12)
            }
            .padding()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Отмена") { dismiss() }
                }
            }
        }
    }
}

struct RoleOption: View {
    let role: User.UserRole
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(role.displayName)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(roleDescription)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.blue)
                }
            }
            .padding()
            .background(isSelected ? Color.blue.opacity(0.1) : Color(.systemGray6))
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var roleDescription: String {
        switch role {
        case .customer: return "Базовые функции лояльности"
        case .participant: return "Создание контента + модерация"
        case .supplierAdmin: return "Управление товарами и акциями"
        case .supplierManager: return "Ограниченные права управления"
        case .platformAdmin: return "Полный доступ к платформе"
        case .platformOperator: return "Модерация и аналитика"
        }
    }
}

struct PointsAdjustmentView: View {
    @Binding var user: User
    @EnvironmentObject private var dataManager: DataManager
    @Environment(\.dismiss) private var dismiss
    @State private var adjustmentAmount = ""
    @State private var adjustmentType: AdjustmentType = .add
    @State private var reason = ""
    
    enum AdjustmentType: String, CaseIterable {
        case add = "add"
        case subtract = "subtract"
        
        var displayName: String {
            switch self {
            case .add: return "Начислить"
            case .subtract: return "Списать"
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Корректировка баллов")
                    .font(.title2)
                    .fontWeight(.bold)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Текущий баланс: \(user.points) баллов")
                        .font(.headline)
                        .foregroundColor(.blue)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Тип операции")
                        .font(.headline)
                    
                    Picker("Тип", selection: $adjustmentType) {
                        ForEach(AdjustmentType.allCases, id: \.self) { type in
                            Text(type.displayName).tag(type)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Количество баллов")
                        .font(.headline)
                    
                    TextField("Введите количество", text: $adjustmentAmount)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.numberPad)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Причина")
                        .font(.headline)
                    
                    TextField("Укажите причину корректировки", text: $reason)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                Spacer()
                
                Button("Применить") {
                    applyAdjustment()
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(canApply ? Color.blue : Color.gray)
                .foregroundColor(.white)
                .cornerRadius(12)
                .disabled(!canApply)
            }
            .padding()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Отмена") { dismiss() }
                }
            }
        }
    }
    
    private var canApply: Bool {
        guard let amount = Int(adjustmentAmount), amount > 0, !reason.isEmpty else {
            return false
        }
        
        if adjustmentType == .subtract {
            return user.points >= amount
        }
        
        return true
    }
    
    private func applyAdjustment() {
        guard let amount = Int(adjustmentAmount) else { return }
        
        switch adjustmentType {
        case .add:
            user.points += amount
        case .subtract:
            user.points = max(0, user.points - amount)
        }
        
        dataManager.updateUser(user)
        
        // Создаем запись о транзакции
        let transaction = PointTransaction(
            id: UUID().uuidString,
            userId: user.id,
            type: adjustmentType == .add ? .bonus : .penalty,
            amount: amount,
            description: "Корректировка администратора: \(reason)",
            timestamp: Date(),
            relatedId: nil
        )
        
        Task {
            await dataManager.addPointTransaction(transaction)
        }
        
        dismiss()
    }
}

struct SearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            
            TextField("Поиск пользователей...", text: $text)
                .textFieldStyle(PlainTextFieldStyle())
            
            if !text.isEmpty {
                Button("Очистить") {
                    text = ""
                }
                .foregroundColor(.secondary)
                .font(.caption)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
        .padding(.horizontal)
    }
}

struct FilterButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.blue : Color(.systemGray6))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(20)
        }
    }
}

#Preview {
    NavigationStack {
        UserManagementView()
            .environmentObject(DataManager())
    }
}