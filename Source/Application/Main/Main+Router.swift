import Foundation
import SwiftUI
import EndpointUI
 
extension Main {
    @MainActor
    final class Router: ObservableObject {
        enum Destination: String {
            case empty
        }
        
        enum SheetDestination  {
            case createAccount(Authentication)
            case changeAboutMe(AboutMe)
            case console
        }
        
        @Published var destination: Destination?
        @Published var sheet: SheetDestination?
        
        init() {
            injectNetworkLogger()
        }
        
        private func injectNetworkLogger() {
            NetworkLogger.enableNetworkLoggerProxy()
        }
    }
}

// MARK: - Public Interface

extension Main.Router {
    func route(to destination: Destination) {
        self.destination = destination
    }
    
    func route(sheet destination: SheetDestination) {
        self.sheet = destination
    }
}

// MARK: - Destination Processor

extension Main {
    struct DestinationProcessor: ViewModifier {
        typealias Destination = Main.Router.Destination
        typealias Sheet = Main.Router.SheetDestination
        
        // MARK: - Dependencies
        
        @Binding var destination: Destination?
        @Binding var sheet: Sheet?
        
        // MARK: -
        
        public func body(content: Content) -> some View {
            content
                .navigationDestination(item: $destination) { destination in
                    switch destination {
                    case .empty: EmptyView()
                    }
                }
                .sheet(item: $sheet) { destination in
                    switch destination {
                    case .createAccount(let application):
                        NavigationView {
                            CreateAccountView()
                                .environmentObject(application)
                        }
                        .presentationDetents([.large])
                        .presentationDragIndicator(.visible)
                    case .changeAboutMe(let application):
                        NavigationView {
                            ChangeAboutMeView()
                                .environmentObject(application)
                        }
                        .presentationDetents([.large])
                        .presentationDragIndicator(.visible)
                    case .console:
                        NavigationView {
                            PulseConsoleView()
                        }
                        .presentationDetents([.large])
                        .presentationDragIndicator(.visible)
                    }
                }
        }
    }
}

// MARK: - Utilitites

 extension Main.Router.Destination: Identifiable {
     var id: String {
         rawValue
     }
 }

 extension Main.Router.SheetDestination: Identifiable {
     var id: String {
         switch self {
         case .createAccount: return "createAccount"
         case .changeAboutMe: return "changeAboutMe"
         case .console: return "console"
         }
     }
 }
