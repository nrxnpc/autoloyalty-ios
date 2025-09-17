import Dependencies
import SwiftUI

struct MainView: View {
    // MARK: - Depemdendencies
    
    @StateObject var router: Main.Router = .init()
    @StateObject private var authViewModel = AuthViewModel()
    @StateObject private var dataManager = DataManager()
    
    // MARK: -
    
    var body: some View {
        ZStack {
            makeRootView()
                .environmentObject(router)
                .environmentObject(authViewModel)
                .environmentObject(dataManager)
        }
        .modifier(Main.OverallDestinationProcessor(destination: $router.overall))
        .onShake {
            router.route(overall: .console)
        }
        .task {
            // TODO: Move to first login use case
            await dataManager.loadDataIfNeeded()
        }
        .onChange(of: authViewModel.isAuthenticated) { oldValue, newValue in
            guard !newValue else {
                return router.route(to: .login)
            }
            
            if let role = authViewModel.currentUser?.role,
               [.platformAdmin, .supplier].contains(role) {
                router.route(to: .admin)
            } else {
                router.route(to: .user)
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .userLoggedOut)) { _ in
            // TODO: Move to logout use case
            dataManager.clearAllData()
        }
    }
}

extension MainView {
    @ViewBuilder func makeRootView() -> some View {
        ZStack {
            switch router.destination {
            default: router.destination.createContent()
            }
        }
        
        // Баннер статуса сети и уведомления
        VStack {
            NetworkStatusBanner()
            NotificationOverlay()
            Spacer()
        }
        
        // Toast контейнер
        ToastContainer()
    }
}
