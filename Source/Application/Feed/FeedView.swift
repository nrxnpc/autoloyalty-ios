import SwiftUI

struct FeedView: View {
    // MARK: - Dependencies
    
    @Environment(Main.Router.self) var router
    @Environment(Recommendations.self) var recommendations
    
    @StateObject var applicaiton: FeedApplication = .init()
    @StateObject var inboxMonitor = InboxMonitor()
    @State var balanceMonitor = BalanceMonitor()
    
    // MARK: - FetchRequests
    
    @FetchRequest var products: FetchedResults<Product>
    @FetchRequest var recommendationSet: FetchedResults<CarRecommendation>
    @FetchRequest var account: FetchedResults<Account>
    
    var balance: Int {
        account.first?.points ?? 0
    }
    
    // MARK: - State
    
    @Namespace internal var namespace
    
    /// To show balance on navigation title
    @State internal var isBalanceVisible: Bool = true
    
    struct RecommendationPrompts {
        private static let prompts: [LocalizedStringKey] = [
            "Do you like it?",
            "What do you think?",
            "Is this your style?",
            "Does this catch your eye?",
            "How about this one?",
            "Your thoughts on this car?",
            "Rate this recommendation",
            "Swipe to choose",
            "Find your match",
            "Love it or leave it?",
            "Your next ride?",
            "Perfect for you?",
            "This one's a keeper?",
            "Your dream car?",
            "Worth a test drive?",
            "Your type of car?"
        ]
        
        static var random: LocalizedStringKey {
            prompts.randomElement() ?? "Do you like it?"
        }
    }
    internal let recommendationPrompts = RecommendationPrompts.random
    
    struct AutoMindPrompts {
        private static let prompts: [LocalizedStringKey] = [
            "Think of any car",
            "I can read your mind",
            "Challenge my skills",
            "Test my knowledge",
            "Pick your dream car",
            "I'll guess in 10 questions",
            "Ready to be amazed?",
            "Try to stump me",
            "Mind reading mode",
            "Car guessing game",
            "Think I can't guess?",
            "Your car awaits",
            "Let's play AutoMind",
            "Guess what I'm thinking",
            "Car telepathy active",
            "Mind over motor"
        ]
        
        static var random: LocalizedStringKey {
            prompts.randomElement() ?? "Think of any car"
        }
    }
    internal let autoMindPrompts = RecommendationPrompts.random
    
    // MARK: - Initialization
    
    init() {
        _products = FetchRequest(fetchRequest: Product.allProductsFetchRequest(), animation: .smooth)
        _recommendationSet = FetchRequest(fetchRequest: CarRecommendation.allNeutralSentiment(), animation: .smooth)
        _account = FetchRequest(fetchRequest: Account.current(), animation: .smooth)
    }
    
    var body: some View {
        ScrollView {
            makeBalanceSection()
            
            if !recommendationSet.isEmpty {
                makeRecommendationsSection()
            }
            
            makeCatalogSection()
            
            // TODO: Disabled
            // makeAutoMindSection()
        }
        .toolbar(content: makeToolbar)
        .animation(.smooth, value: isBalanceVisible)
        .environment(balanceMonitor)
    }
}

// MARK: - View Builder

extension FeedView {
    // MARK: - Toolbar
    
    @ToolbarContentBuilder func makeToolbar() -> some ToolbarContent {
        if !isBalanceVisible {
            ToolbarItemGroup(placement: .topBarLeading) {
                Button {
                    router.route(sheet: .scanner)
                } label: {
                    Image(systemName: "qrcode.viewfinder")
                }
                
                Button {
                    router.route(sheet: .transactionHistory)
                } label: {
                    HStack(spacing: 0) {
                        Text("\(balance)")
                            .foregroundColor(.primary)
                        Image(systemName: "star.fill")
                            .scaleEffect(x: 0.6, y: 0.6)
                            .foregroundColor(.orange)
                    }
                }
            }
        }
        
        ToolbarItemGroup(placement: .topBarTrailing) {
            Button {
                router.route(to: .aboutMe)
            } label: {
                if let accountID = applicaiton.accountID {
                    AccountImage(accountID: accountID)
                        .frame(width: 28, height: 28)
                } else {
                    Image(systemName: "person")
                }
            }
            .contextMenu {
                Button {
                    router.route(sheet: .scanHistory)
                } label: {
                    Label("Scan History", systemImage: "qrcode") // blue
                }
                
                Button {
                    router.route(sheet: .transactionHistory)
                } label: {
                    Label("Transactions", systemImage: "arrow.up.arrow.down") // green
                }
                
                Button {
                    router.route(sheet: .orders)
                } label: {
                    Label("Orders", systemImage: "cart") // pink
                }
            }
            
            Button {
                router.route(to: .inbox)
            } label: {
                if inboxMonitor.unreadCount > 0 {
                    Image(systemName: "envelope.badge")
                        .foregroundStyle(.red, .primary)
                } else {
                    Image(systemName: "envelope")
                        .foregroundStyle(.primary)
                }
            }
            .contextMenu {
                Button {
                    inboxMonitor.markAllAsRead()
                } label: {
                    Label("Mark all as read", systemImage: "checkmark.circle")
                }
                .disabled(inboxMonitor.unreadCount == 0)
            }
        }
    }
}

#Preview {
    FeedView()
}
