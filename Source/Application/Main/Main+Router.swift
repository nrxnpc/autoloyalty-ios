import Foundation
import SwiftUI
import SwiftUIComponents
import EndpointUI
 
extension Main {
    @MainActor
    @Observable
    final class Router {
        enum Destination {
            case aboutMe
            case inbox
            case catalog
            case commingSoon
        }
        
        enum SheetDestination {
            case createAccount(Authentication)
            case changeAboutMe(AboutMe)
            case productDetails(String, Namespace.ID)
            case sweepstakesDetails(Sweepstakes, Namespace.ID)
            case howTo(HowTo)
            case transactionHistory
            case orders
            case inboxMessage(InboxMessage)
            case scanner
            case scanHistory
            case offers
            case reauthenticationView
            case contactSupport
            case akinator(Namespace.ID)
            case console
        }
        
        enum FullScreenDestination {
            case scanner
            case recommendations(Namespace.ID, FetchedResults<CarRecommendation>)
        }
        
        // MARK: - Output
        
        var destination: Destination?
        var sheet: SheetDestination?
        var fullScreen: FullScreenDestination?
        
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
    
    func routeReauthentication() {
        guard sheet == nil && fullScreen == nil else {
            return
        }
        sheet = .reauthenticationView
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
    
    var isContactSupportOpen: Bool {
        if case .contactSupport = sheet {
            return true
        }
        return false
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
        
        @Bindable var router: Main.Router

        // MARK: -
        
        public func body(content: Content) -> some View {
            content
                .navigationDestination(item: $router.destination) { destination in
                    switch destination {
                    case .aboutMe:
                        AboutMeView()
                    case .inbox:
                        InboxView()
                    case .catalog:
                        BonusesView()
                    case .commingSoon:
                        CommingSoon()
                    }
                }
                .fullScreenCover(item: $router.fullScreen) { destination in
                    switch destination {
                    case .scanner:
                        NavigationView {
                            QRScannerView()
                        }
                    case .recommendations(let namespace, let recommendationSet):
                        NavigationView {
                            RecommendationsView(recommendationSet: recommendationSet)
                        }
                        .navigationTransition(.zoom(sourceID: "recommendations", in: namespace))
                    }
                }
                .sheet(item: $router.sheet) { destination in
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
                        .presentationDetents([.medium])
                        .presentationDragIndicator(.visible)
                    case .productDetails(let id, let namespace):
                        NavigationView {
                            BonusView(id: id)
                        }
                        .presentationDetents([.large])
                        .presentationDragIndicator(.visible)
                        .navigationTransition(.zoom(sourceID: id, in: namespace))
                    case .sweepstakesDetails(let sweepstake, let namespace):
                        NavigationView {
                            SweepstakesView(sweepstake: sweepstake)
                        }
                        .presentationDetents([.large])
                        .presentationDragIndicator(.visible)
                        .navigationTransition(.zoom(sourceID: sweepstake.id, in: namespace))
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
                        }
                        .presentationDetents([.large])
                        .presentationDragIndicator(.visible)
                    case .scanHistory:
                        NavigationView {
                            QRScanHistoryView()
                        }
                        .presentationDetents([.large])
                        .presentationDragIndicator(.visible)
                    case .offers:
                        NavigationView {
                            OffersView()
                        }
                        .presentationDetents([.large])
                        .presentationDragIndicator(.visible)
                    case .reauthenticationView:
                        NavigationView {
                            ReauthenticationView()
                        }
                        .presentationDetents([.medium])
                        .presentationDragIndicator(.visible)
                    case .contactSupport:
                        NavigationView {
                            ContactSupportView()
                        }
                        .presentationDetents([.large])
                        .presentationDragIndicator(.visible)
                    case .akinator(let namespace):
                        NavigationView {
                            AkinatorView()
                        }
                        .presentationDetents([.large])
                        .presentationDragIndicator(.visible)
                        .navigationTransition(.zoom(sourceID: "akinator", in: namespace))
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

extension Main.Router.Destination: Identifiable, Equatable, Hashable {
    var id: String {
        switch self {
        case .aboutMe: return "aboutMe"
        case .inbox: return "inbox"
        case .catalog: return "catalog"
        case .commingSoon: return "commingSoon"
        }
    }
    
    static func == (lhs: Main.Router.Destination, rhs: Main.Router.Destination) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension Main.Router.SheetDestination: Identifiable, Equatable {
    var id: String {
        switch self {
        case .createAccount: return "createAccount"
        case .changeAboutMe: return "changeAboutMe"
        case .productDetails(let id, _): return id
        case .sweepstakesDetails(let sweepstake, _): return sweepstake.id
        case .howTo(let howTo): return howTo.id
        case .transactionHistory: return "transactionHistory"
        case .orders: return "orders"
        case .inboxMessage: return "inboxMessage"
        case .scanner: return "scanner"
        case .scanHistory: return "scanHistory"
        case .offers: return "offers"
        case .reauthenticationView: return "reauthenticationView"
        case .contactSupport: return "contactSupport"
        case .akinator: return "akinator"
        case .console: return "console"
        }
    }
    
    static func == (lhs: Main.Router.SheetDestination, rhs: Main.Router.SheetDestination) -> Bool {
        lhs.id == rhs.id
    }
}

extension Main.Router.FullScreenDestination: Identifiable, Equatable {
    var id: String {
        switch self {
        case .scanner: return "scanner"
        case .recommendations: return "recommendations"
        }
    }
    
    static func == (lhs: Main.Router.FullScreenDestination, rhs: Main.Router.FullScreenDestination) -> Bool {
        lhs.id == rhs.id
    }
}
