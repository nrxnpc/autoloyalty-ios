import Dependencies
import SwiftUI

struct MainView: View {
    // MARK: - Dependencies
    
    @StateObject var router: Main.Router = .init()
    @StateObject var application: Main = .init()
    
    // MARK: -
    
    var body: some View {
        NavigationStack {
            ZStack {
                switch application.state {
                case .loading: makeLoading()
                case .authentication: makeLogin()
                case .session(let sessionID): makeCustomerSession(for: sessionID)
                case .guestSession: makeGuestSession()
                }
            }
            .animation(.smooth, value: application.state)
            .sensoryFeedback(.start, trigger: application.state)
            .modifier(Main.DestinationProcessor(router: router))
            .environmentObject(router)
            .environmentObject(application)
        }
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
        FeedView()
            .id(sessionID)
    }
    
    @ViewBuilder func makeGuestSession() -> some View {
        FeedView()
            .id("guest")
    }
}

#Preview {
    MainView()
}
