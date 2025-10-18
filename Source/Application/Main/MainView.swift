import Dependencies
import SwiftUI

struct MainView: View {
    // MARK: - Dependencies
    
    @StateObject var router: Main.Router = .init()
    @StateObject var application: Main = .init()
    
    @StateObject private var authViewModel = AuthViewModel()
    @StateObject private var dataManager = DataManager()
    
    // MARK: -
    
    var body: some View {
        NavigationView {
            switch application.state {
            case .loading: makeLoading()
            case .authentication: makeLogin()
            case .session(let sessionID): makeCustomerSession(for: sessionID)
            case .guestSession: makeGuestSession()
            }
        }
        .animation(.smooth, value: application.state)
        .sensoryFeedback(.start, trigger: application.state)
        .modifier(Main.DestinationProcessor(destination: $router.destination, sheet: $router.sheet))
        .environmentObject(router)
        .environmentObject(application)
        .onShake {
            router.route(sheet: .console)
        }
        .task {
            await application.restoreSession()
        }
    }
}

extension MainView {
    // MARK: - View Builders
    
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
}
