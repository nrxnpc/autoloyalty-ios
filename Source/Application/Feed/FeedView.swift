import SwiftUI

struct FeedView: View {
    // MARK: - Dependencies
    
    @EnvironmentObject var router: Main.Router
    @StateObject var applicaiton: FeedApplication = .init()
    
    @StateObject var inboxMonitor = InboxMonitor()
    @StateObject var balanceMonitor = BalanceMonitor()
    
    // MARK: - FetchRequests
    
    @FetchRequest var products: FetchedResults<Product>
    
    // MARK: - State
    
    @State internal var showFavoritesOnly = false
    
    // MARK: - Initialization
    
    init() {
        _products = FetchRequest(fetchRequest: Product.availableProductsFetchRequest(), animation: .smooth)
    }
    
    var body: some View {
        ScrollView {
            makeBalanceSection()
            makeCatalogSection()
        }
        .animation(.easeInOut, value: showFavoritesOnly)
        .toolbar(content: makeToolbar)
        .environmentObject(balanceMonitor)
    }
}

// MARK: - View Builder

extension FeedView {
    // MARK: - Toolbar
    
    @ToolbarContentBuilder func makeToolbar() -> some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Button {
                router.route(fullScreen: .scanner)
            } label: {
                Image(systemName: "qrcode.viewfinder")
            }
        }
        
        ToolbarItemGroup(placement: .topBarTrailing) {
            Button {
                router.route(to: .aboutMe)
            } label: {
                Image(systemName: "person")
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
            products.nsPredicate = NSPredicate(format: "isOutOfStock == NO")
        }
    }
}

#Preview {
    FeedView()
}
