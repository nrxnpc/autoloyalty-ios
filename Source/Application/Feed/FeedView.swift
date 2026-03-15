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
    @FetchRequest var rewards: FetchedResults<Product>
    @FetchRequest var recommendationSet: FetchedResults<CarRecommendation>
    @FetchRequest var account: FetchedResults<Account>
    @FetchRequest var sweepstakes: FetchedResults<Sweepstakes>
    
    var balance: Int {
        account.first?.points ?? 0
    }
    
    // MARK: - State
    
    @Namespace internal var namespace
    
    /// To show balance on navigation title
    @State internal var isBalanceVisible: Bool = true
    
    internal let recommendationPrompts = RecommendationPrompts.random
    internal let autoMindPrompts = RecommendationPrompts.random
    
    // MARK: - Initialization
    
    init() {
        _products = FetchRequest(fetchRequest: Product.allProductsFetchRequest(), animation: .snappy)
        _rewards = FetchRequest(fetchRequest: Product.myRewards(), animation: .snappy)
        _recommendationSet = FetchRequest(fetchRequest: CarRecommendation.allNeutralSentiment(), animation: .snappy)
        _account = FetchRequest(fetchRequest: Account.current(), animation: .snappy)
        _sweepstakes = FetchRequest(fetchRequest: Sweepstakes.activeSweepstakesFetchRequest(), animation: .snappy)
    }
    
    var body: some View {
        ScrollView {
            makeBalanceSection()
            
            if !sweepstakes.isEmpty {
                makeSweepstakesSection(Array(sweepstakes))
            }
            
            makeCatalogSection()
            
            if !recommendationSet.isEmpty {
                makeRecommendationsSection()
            }
            
            // TODO: Disabled
            // makeAutoMindSection()
        }
        .scrollIndicators(.hidden)
        .toolbar(content: makeToolbar)
        .animation(.snappy, value: isBalanceVisible)
        .environment(balanceMonitor)
    }
}

extension FeedView {
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
}

#Preview {
    FeedView()
}
