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
    
    @State internal var showFavoritesOnly = false
    /// To show balance on navigation title
    @State internal var isBalanceVisible: Bool = true
    
    struct ProductDetails: Identifiable {
        let id: String
    }
    @State internal var productDetails: ProductDetails? = nil
    
    
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
        }
        .animation(.easeInOut, value: showFavoritesOnly)
        .toolbar(content: makeToolbar)
        .animation(.smooth, value: isBalanceVisible)
        .sheet(item: $productDetails) { details in
            NavigationView {
                RewardDetailsView(id: details.id)
                    .environment(balanceMonitor)
            }
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
            .navigationTransition(.zoom(sourceID: details.id, in: namespace))
        }
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
        }
    }
}

// MARK: - FetchRequests Configuration

extension FeedView {
    internal func sortProductsLowToHigh() {
        products.nsSortDescriptors = [NSSortDescriptor(keyPath: \Product.pointsCost, ascending: true)]
    }
    
    internal func sortProductsHighToLow() {
        products.nsSortDescriptors = [NSSortDescriptor(keyPath: \Product.pointsCost, ascending: false)]
    }
    
    internal func toggleFavoritesFilter() {
        showFavoritesOnly.toggle()
        
        if showFavoritesOnly {
            products.nsPredicate = NSPredicate(format: "isFavorite == YES")
        } else {
            products.nsPredicate = nil
        }
    }
}

#Preview {
    FeedView()
}
