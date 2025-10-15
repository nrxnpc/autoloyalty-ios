import Dependencies
import Foundation
import Combine

@MainActor
class AuthViewModel: ObservableObject {
    @Dependency(\.endpoint) var endpoint: RestEndpoint
    
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    @Published var isLoading = false
    @Published var errorMessage = ""
    
    private let tokenManager = TokenManager.shared
    private var authTask: Task<Void, Never>?
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // TODO: Use authenticator
        // Подписываемся на изменения состояния токена
        // tokenManager.$isAuthenticated
        //     .sink { [weak self] isAuth in
        //         guard let self = self else { return }
        //         if !isAuth && self.isAuthenticated == true {
        //             // Токен был очищен, выходим
        //             Task { @MainActor in
        //                 self.logout()
        //             }
        //         }
        //     }
        //     .store(in: &cancellables)
        
        // Проверяем есть ли сохраненный токен при запуске
        checkSavedAuth()
    }
    
    private func checkSavedAuth() {
        // TODO: Use authenticator
        // if tokenManager.isAuthenticated, let _ = tokenManager.getToken() {
        //     // В реальном приложении здесь бы проверялась валидность токена
        //     // Для демо просто восстанавливаем состояние
        //     restoreUserFromToken()
        // }
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
            let loginResponse = try await endpoint.login(.init(email: email, password: password))
            guard let user = loginResponse.user else {
                await MainActor.run {
                    self.isLoading = false
                    self.errorMessage = "Ошибка входа"
                }
                return
            }
            
            let currentUser = User(
                id: user.id, 
                name: user.name, 
                email: user.email, 
                phone: user.phone, 
                userType: .init(rawValue: user.userType.rawValue) ?? .individual, 
                points: user.points, 
                role: .init(rawValue: user.role.rawValue) ?? .customer, 
                registrationDate: .now, 
                isActive: user.isActive, 
                preferences: .default, 
                statistics: .default
            )
            
            await MainActor.run {
                self.currentUser = currentUser
                self.isAuthenticated = true
                self.isLoading = false
                self.errorMessage = ""
                
                if let token = loginResponse.token {
                    self.tokenManager.saveToken(token)
                }
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
            let registerResponse = try await endpoint.register(.init(
                name: name, 
                email: email, 
                phone: phone, 
                password: password, 
                userType: RestEndpoint.UserType(rawValue: userType.rawValue) ?? .individual,
                deviceInfo: nil
            ))
            
            guard let user = registerResponse.user else {
                await MainActor.run {
                    self.isLoading = false
                    self.errorMessage = "Ошибка регистрации"
                }
                return
            }
            
            let currentUser = User(
                id: user.id, 
                name: user.name, 
                email: user.email, 
                phone: user.phone, 
                userType: .init(rawValue: user.userType.rawValue) ?? .individual, 
                points: user.points, 
                role: .init(rawValue: user.role.rawValue) ?? .customer, 
                registrationDate: .now, 
                isActive: user.isActive, 
                preferences: .default, 
                statistics: .default
            )
            
            await MainActor.run {
                self.currentUser = currentUser
                self.isAuthenticated = true
                self.isLoading = false
                self.errorMessage = ""
                
                if let token = registerResponse.token {
                    self.tokenManager.saveToken(token)
                }
                
                NotificationCenter.default.post(name: .userRegistered, object: user)
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
        
        // TODO: Use authenticator
        // Очищаем токен
        // tokenManager.clearToken()
        
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
        
        Task {
            do {
                if let userId = currentUser?.id {
                    // try await endpoint.updateUserProfile(userId: userId, name: name, email: email, phone: phone)
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
        syncPointsWithServer()
    }
    
    func spendPoints(_ points: Int) -> Bool {
        guard let user = currentUser, user.points >= points else {
            return false
        }
        
        currentUser?.points -= points
        syncPointsWithServer()
        
        return true
    }
    
    private func syncPointsWithServer() {
        Task {
            do {
                if let userId = currentUser?.id {
                    // try await endpoint.syncUserData(userId: userId)
                }
            } catch {
                print("Ошибка синхронизации баллов: \(error)")
            }
        }
    }
    
    func refreshUserData() async {
        guard let userId = currentUser?.id else { return }
        
        do {
            // try await endpoint.syncUserData(userId: userId)
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
        true
    }
    
    var isNetworkLoading: Bool {
        isLoading
    }
}
