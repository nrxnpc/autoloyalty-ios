import Foundation
import SwiftUI
import EndpointUI
 
extension Main {
    @MainActor
    final class Router: ObservableObject {
        enum Destination: String, Identifiable {
            case login
            case admin
            case user
        }
        
        enum OverallDestination: String, Identifiable  {
            case console
        }
        
        @Published var destination: Destination = .login
        @Published var overall: OverallDestination?
        
        init() {
            injectNetworkLogger()
        }
        
        private func injectNetworkLogger() {
            NetworkLogger.enableNetworkLoggerProxy()
        }
    }
}

extension Main.Router {
    func route(to destination: Destination) {
        self.destination = destination
    }
    
    func route(overall destination: OverallDestination) {
        self.overall = destination
    }
}

extension Main.Router.Destination {
    var id: String { self.rawValue }
    
    @MainActor @ViewBuilder func createContent() -> some View {
        switch self {
        case .login: AuthFlowView()
        case .admin: AdminMainView()
        case .user: MainTabView()
        }
    }
}

extension Main.Router.OverallDestination {
    var id: String { self.rawValue }
    
    @MainActor @ViewBuilder func createContent() -> some View {
        switch self {
        case .console: PulseConsoleView()
        }
    }
}

extension Main {
    struct OverallDestinationProcessor: ViewModifier {
        typealias Router = Main.Router
        typealias Destination = Router.OverallDestination
        
        // MARK: - Dependencies
        
        @Binding var destination: Destination?
        
        // MARK: -
        public func body(content: Content) -> some View {
            content
                .sheet(item: $destination) { destination in
                    NavigationView {
                        destination.createContent()
                    }
                    .presentationDetents([.large])
                    .presentationDragIndicator(.visible)
                }
        }
    }
}
