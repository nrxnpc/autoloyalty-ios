import Foundation
import Combine

@MainActor
class AuthViewModel: ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    @Published var isLoading = false
    @Published var errorMessage = ""
    
    private let networkManager = NetworkManager.shared
    private let tokenManager = TokenManager.shared
    private var authTask: Task<Void, Never>?
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // Подписываемся на изменения состояния токена
        tokenManager.$isAuthenticated
            .sink { [weak self] isAuth in
                guard let self = self else { return }
                if !isAuth && self.isAuthenticated == true {
                    // Токен был очищен, выходим
                    Task { @MainActor in
                        self.logout()
                    }
                }
            }
            .store(in: &cancellables)
        
        // Проверяем есть ли сохраненный токен при запуске
        checkSavedAuth()
    }
    
    private func checkSavedAuth() {
        if tokenManager.isAuthenticated, let _ = tokenManager.getToken() {
            // В реальном приложении здесь бы проверялась валидность токена
            // Для демо просто восстанавливаем состояние
            restoreUserFromToken()
        }
    }
    
    private func restoreUserFromToken() {
        // Демо восстановление пользователя
        // В реальном приложении здесь был бы API запрос
        currentUser = User(
            id: "restored-user",
            name: "Восстановленный пользователь",
            email: "user@nsp.com",
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
        isAuthenticated = true
    }
    
    func login(email: String, password: String) {
        authTask?.cancel()
        authTask = Task.detached(priority: .userInitiated) { [weak self] in
            await self?.performLogin(email: email, password: password)
        }
    }
    
    private func performLogin(email: String, password: String) async {
        await MainActor.run {
            self.isLoading = true
            self.errorMessage = ""
        }
        
        do {
            let apiUser = try await networkManager.login(email: email, password: password)
            let user = apiUser.toUser()
            
            await MainActor.run {
                self.currentUser = user
                self.isAuthenticated = true
                self.isLoading = false
                self.errorMessage = ""
                
                // Сохраняем токен (в демо версии используем ID пользователя)
                self.tokenManager.saveToken(user.id)
            }
            
        } catch let error as NetworkError {
            await MainActor.run {
                self.isLoading = false
                self.errorMessage = error.localizedDescription
            }
        } catch {
            await MainActor.run {
                self.isLoading = false
                self.errorMessage = "Ошибка входа. Попробуйте еще раз."
            }
        }
    }
    
    func register(name: String, email: String, phone: String, password: String, userType: User.UserType) {
        authTask?.cancel()
        authTask = Task.detached(priority: .userInitiated) { [weak self] in
            await self?.performRegister(name: name, email: email, phone: phone, password: password, userType: userType)
        }
    }
    
    private func performRegister(name: String, email: String, phone: String, password: String, userType: User.UserType) async {
        await MainActor.run {
            self.isLoading = true
            self.errorMessage = ""
        }
        
        do {
            let userData = UserRegistration(
                name: name,
                email: email,
                phone: phone,
                password: password,
                userType: userType.rawValue
            )
            
            let apiUser = try await networkManager.register(userData: userData)
            let user = apiUser.toUser()
            
            await MainActor.run {
                self.currentUser = user
                self.isAuthenticated = true
                self.isLoading = false
                self.errorMessage = ""
                
                // Сохраняем токен
                self.tokenManager.saveToken(user.id)
                
                // Добавляем пользователя в DataManager
                NotificationCenter.default.post(name: .userRegistered, object: user)
            }
            
        } catch let error as NetworkError {
            await MainActor.run {
                self.isLoading = false
                self.errorMessage = error.localizedDescription
            }
        } catch {
            await MainActor.run {
                self.isLoading = false
                self.errorMessage = "Ошибка регистрации: \(error.localizedDescription)"
            }
        }
    }
    
    func logout() {
        authTask?.cancel()
        
        // Очищаем токен
        tokenManager.clearToken()
        
        // Очищаем состояние
        currentUser = nil
        isAuthenticated = false
        errorMessage = ""
        
        // Уведомляем о выходе пользователя для очистки данных
        NotificationCenter.default.post(name: .userLoggedOut, object: nil)
    }
    
    func updateProfile(name: String, email: String, phone: String) {
        currentUser?.name = name
        currentUser?.email = email
        currentUser?.phone = phone
        
        // В реальном приложении здесь был бы API запрос для обновления профиля
        Task {
            do {
                if let userId = currentUser?.id {
                    try await networkManager.syncUserData(userId: userId)
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = "Ошибка обновления профиля: \(error.localizedDescription)"
                }
            }
        }
    }
    
    func addPoints(_ points: Int) {
        currentUser?.points += points
        
        // Синхронизируем с сервером
        syncPointsWithServer()
    }
    
    func spendPoints(_ points: Int) -> Bool {
        guard let user = currentUser, user.points >= points else {
            return false
        }
        
        currentUser?.points -= points
        
        // Синхронизируем с сервером
        syncPointsWithServer()
        
        return true
    }
    
    private func syncPointsWithServer() {
        Task {
            do {
                if let userId = currentUser?.id {
                    try await networkManager.syncUserData(userId: userId)
                }
            } catch {
                // Логируем ошибку, но не показываем пользователю
                print("Ошибка синхронизации баллов: \(error)")
            }
        }
    }
    
    func refreshUserData() async {
        guard let userId = currentUser?.id else { return }
        
        do {
            try await networkManager.syncUserData(userId: userId)
        } catch {
            await MainActor.run {
                self.errorMessage = "Ошибка обновления данных: \(error.localizedDescription)"
            }
        }
    }
    
    deinit {
        authTask?.cancel()
        cancellables.removeAll()
    }
}

// MARK: - Network Status Integration
extension AuthViewModel {
    var isNetworkAvailable: Bool {
        networkManager.isConnected
    }
    
    var isNetworkLoading: Bool {
        networkManager.isLoading
    }
}
