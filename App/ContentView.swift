import SwiftUI

struct ContentView: View {
    @StateObject private var authViewModel = AuthViewModel()
    @StateObject private var dataManager = DataManager()
    @StateObject private var networkManager = NetworkManager.shared
    
    var body: some View {
        ZStack {
            Group {
                if authViewModel.isAuthenticated {
                    if authViewModel.currentUser?.role == .admin {
                        AdminMainView()
                    } else {
                        MainTabView()
                    }
                } else {
                    AuthFlowView()
                }
            }
            .environmentObject(authViewModel)
            .environmentObject(dataManager)
            .environmentObject(networkManager)
            
            // Баннер статуса сети
            VStack {
                NetworkStatusBanner()
                Spacer()
            }
        }
        .task {
            // Отложенная инициализация данных
            await dataManager.loadDataIfNeeded()
        }
        .onReceive(NotificationCenter.default.publisher(for: .userLoggedOut)) { _ in
            // Очищаем данные при выходе пользователя
            dataManager.clearAllData()
        }
    }
}

// MARK: - Preview
#Preview {
    ContentView()
}
