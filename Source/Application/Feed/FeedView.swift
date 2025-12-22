import SwiftUI

struct FeedView: View {
    // MARK: - Dependencies
    
    @Environment(Main.Router.self) var router
    
    @StateObject var applicaiton: FeedApplication = .init()
    @StateObject var inboxMonitor = InboxMonitor()
    @StateObject var balanceMonitor = BalanceMonitor()
    
    // MARK: - FetchRequests
    
    @FetchRequest var products: FetchedResults<Product>
    @FetchRequest var recommendations: FetchedResults<CarRecommendation>
    
    // MARK: - State
    
    @Namespace internal var profileNamespace
    
    @State internal var showFavoritesOnly = false
    /// To show balance on navigation title
    @State internal var isBalanceVisible: Bool = true
    
    // MARK: - Initialization
    
    init() {
        _products = FetchRequest(fetchRequest: Product.allProductsFetchRequest(), animation: .smooth)
        _recommendations = FetchRequest(fetchRequest: CarRecommendation.all(), animation: .smooth)
    }
    
    var body: some View {
        ScrollView {
            makeBalanceSection()
            
            if !recommendations.isEmpty {
                makeRecommendationsSection()
            }
            
            makeCatalogSection()
        }
        .animation(.easeInOut, value: showFavoritesOnly)
        .toolbar(content: makeToolbar)
        .animation(.smooth, value: isBalanceVisible)
        .environmentObject(balanceMonitor)
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
                        Text("\(balanceMonitor.balance)")
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
