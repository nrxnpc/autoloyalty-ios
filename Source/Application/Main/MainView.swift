import Dependencies
import SwiftUI

struct MainView: View {
    // MARK: - Depemdendencies
    
    @StateObject var router: Main.Router = .init()
    @StateObject var mainApplication: Main = .init()
    
    @StateObject private var authViewModel = AuthViewModel()
    @StateObject private var dataManager = DataManager()
    
    // MARK: -
    
    var body: some View {
        NavigationView {
            switch mainApplication.state {
            case .loading: makeLoading()
            case .authentication: makeLogin()
            case .session(let sessionID): makeCustomerSession(for: sessionID)
            case .guestSession: makeGuestSession()
            }
        }
        .animation(.smooth, value: mainApplication.state)
        .sensoryFeedback(.start, trigger: mainApplication.state)
        .environmentObject(mainApplication)
        .task {
            await mainApplication.restoreSession()
        }
    }
}

extension MainView {
    @ViewBuilder func makeLoading() -> some View {
        EmptyView()
    }
    
    @ViewBuilder func makeLogin() -> some View {
        LoginView()
    }
    
    @ViewBuilder func makeCustomerSession(for sessionID: String) -> some View {
        CustomerView()
            .id(sessionID)
    }
    
    @ViewBuilder func makeGuestSession() -> some View {
        CustomerView()
            .id("guest")
    }
    
    // MARK: - MAGA
    
    @ViewBuilder func makeAmericaGreatAgain() -> some View {
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
    
    @ViewBuilder func makeRootView() -> some View {
        ZStack {
            switch router.destination {
            default: router.destination.createContent()
            }
        }
        
        // Баннер уведомления
        VStack {
            NotificationOverlay()
            Spacer()
        }
        
        // Toast контейнер
        ToastContainer()
    }
}
