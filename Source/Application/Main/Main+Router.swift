import Foundation
import SwiftUI
import SwiftUIComponents
import EndpointUI
 
extension Main {
    @MainActor
    final class Router: ObservableObject {
        enum Destination: String {
            case aboutMe
            case inbox
            case commingSoon
        }
        
        enum SheetDestination {
            case createAccount(Authentication)
            case changeAboutMe(AboutMe)
            case productDetails(String)
            case howTo(HowTo)
            case transactionHistory
            case orders
            case inboxMessage(InboxMessage)
            case scanner
            case scanHistory
            case reauthenticationView
            case contacSupport
            case console
        }
        
        enum FullScreenDestination: String {
            case scanner
        }
        
        // MARK: - Output
        
        @Published var destination: Destination?
        @Published var sheet: SheetDestination?
        @Published var fullScreen: FullScreenDestination?
        
        init() {
            injectNetworkLogger()
        }
        
        private func injectNetworkLogger() {
            NetworkLogger.enableNetworkLoggerProxy()
        }
        
        func reset() {
            destination = nil
            sheet = nil
            fullScreen = nil
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
    
    func route(fullScreen destination: FullScreenDestination) {
        self.fullScreen = destination
    }
    
    func openSettings() {
        guard let settingsURL = URL(string: "App-Prefs:root=General") else {
            return
        }
        
        if UIApplication.shared.canOpenURL(settingsURL) {
            UIApplication.shared.open(settingsURL) { success in
                guard success else {
                    return
                }
                
                UINotificationFeedbackGenerator().notificationOccurred(.error)
            }
        }
    }
}

// MARK: - Destination Processor

extension Main {
    struct CommingSoon: View, ComponentBuilder {
        var body: some View {
            MakeUnderConstructionBarrier(title: "Coming soon...", reason: "This view is currently under construction.")
        }
    }

    struct DestinationProcessor: ViewModifier {
        // MARK: - Dependencies
        
        @StateObject var router: Main.Router
        
        // MARK: -
        
        public func body(content: Content) -> some View {
            content
                .navigationDestination(item: $router.destination) { destination in
                    switch destination {
                    case .aboutMe:
                        AboutMeView()
                            .environmentObject(router)
                    case .inbox:
                        InboxView()
                            .environmentObject(router)
                    case .commingSoon:
                        CommingSoon()
                    }
                }
                .fullScreenCover(item: $router.fullScreen) { destination in
                    switch destination {
                    case .scanner:
                        NavigationView {
                            QRScannerView()
                                .environmentObject(router)
                        }
                    }
                }
                .sheet(item: $router.sheet) { destination in
                    switch destination {
                    case .createAccount(let application):
                        NavigationView {
                            CreateAccountView()
                                .environmentObject(application)
                                .environmentObject(router)
                        }
                        .presentationDetents([.large])
                        .presentationDragIndicator(.visible)
                    case .changeAboutMe(let application):
                        NavigationView {
                            ChangeAboutMeView()
                                .environmentObject(application)
                                .environmentObject(router)
                        }
                        .presentationDetents([.large])
                        .presentationDragIndicator(.visible)
                    case .productDetails(let id):
                        RewardDetailsView(id: id)
                            .presentationDetents([.large])
                            .presentationDragIndicator(.visible)
                    case .howTo(let howTo):
                        switch howTo {
                        case .topUpYourBalance:
                            NavigationView {
                                HowToTopUpYourBalanceView()
                            }
                            .presentationDetents([.large])
                            .presentationDragIndicator(.visible)
                        case .howToRedeemGiftCards:
                            NavigationView {
                                HowToRedeemGiftCardsView()
                            }
                            .presentationDetents([.large])
                            .presentationDragIndicator(.visible)
                        }
                    case .transactionHistory:
                        NavigationView {
                            BalanceTransactionsView()
                        }
                        .presentationDetents([.medium, .large], selection: .constant(.large))
                        .presentationDragIndicator(.visible)
                    case .orders:
                        NavigationView {
                            OrdersView()
                        }
                        .presentationDetents([.medium, .large], selection: .constant(.large))
                        .presentationDragIndicator(.visible)
                    case .inboxMessage(let message):
                        NavigationView {
                            InboxMessageView(message: message)
                        }
                        .presentationDetents([.large])
                        .presentationDragIndicator(.visible)
                    case .scanner:
                        NavigationView {
                            QRScannerView()
                                .environmentObject(router)
                        }
                        .presentationDetents([.large])
                        .presentationDragIndicator(.visible)
                    case .scanHistory:
                        NavigationView {
                            QRScanHistoryView()
                                .environmentObject(router)
                        }
                        .presentationDetents([.large])
                        .presentationDragIndicator(.visible)
                    case .reauthenticationView:
                        NavigationView {
                            ReauthenticationView()
                                .environmentObject(router)
                        }
                        .presentationDetents([.medium])
                        .presentationDragIndicator(.visible)
                    case .contacSupport:
                        NavigationView {
                            ContactSupportView()
                                .environmentObject(router)
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
                .sensoryFeedback(.impact, trigger: router.destination)
                .sensoryFeedback(.impact, trigger: router.sheet)
                .sensoryFeedback(.impact, trigger: router.fullScreen)
        }
    }
}

// MARK: - Utilitites

extension Main.Router.Destination: Identifiable, Equatable {
    var id: String {
        rawValue
    }
}

extension Main.Router.SheetDestination: Identifiable, Equatable {
    var id: String {
        switch self {
        case .createAccount: return "createAccount"
        case .changeAboutMe: return "changeAboutMe"
        case .productDetails(let id): return id
        case .howTo(let howTo): return howTo.id
        case .transactionHistory: return "transactionHistory"
        case .orders: return "orders"
        case .inboxMessage: return "inboxMessage"
        case .scanner: return "scanner"
        case .scanHistory: return "scanHistory"
        case .reauthenticationView: return "reauthenticationView"
        case .contacSupport: return "contacSupport"
        case .console: return "console"
        }
    }
    
    static func == (lhs: Main.Router.SheetDestination, rhs: Main.Router.SheetDestination) -> Bool {
        lhs.id == rhs.id
    }
}

extension Main.Router.FullScreenDestination: Identifiable, Equatable {
    var id: String {
        rawValue
    }
}
