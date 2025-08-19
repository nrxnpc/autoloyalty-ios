import SwiftUI

struct ContentView: View {
    @StateObject private var authViewModel = AuthViewModel()
    @StateObject private var dataManager = DataManager()
    
    var body: some View {
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

#Preview {
    ContentView()
}
