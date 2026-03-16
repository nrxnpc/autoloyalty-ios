import SwiftUI
import SwiftUIComponents

struct BonusesView: View {
    // MARK: - Dependencies
    
    @Environment(Main.Router.self) var router
    
    // MARK: - Request
    
    @ObservedObject var account: Account
    @FetchRequest var products: FetchedResults<Product>
    
    // MARK: - State
    
    @Namespace internal var namespace
    @State internal var showFavoritesOnly = false
    
    // MARK: - Initialization
    
    init(account: Account) {
        self.account = account
        _products = FetchRequest(fetchRequest: Product.allProductsFetchRequest(), animation: .smooth)
    }
    
    var body: some View {
        ScrollView {
            if showFavoritesOnly && products.isEmpty {
                BonusesView.makeEmptyFavorites()
                    .padding()
            } else {
                BonusesView.makeCatalogGrid(products: products, account: account, router: router, namespace: namespace)
                    .padding()
            }
        }
        .navigationTitle("Bonuses")
        .navigationBarTitleDisplayMode(.large)
        .animation(.easeInOut, value: showFavoritesOnly)
        .toolbar(content: makeToolbar)
    }
}

// MARK: - View Builder

extension BonusesView {
    @ViewBuilder static func makeEmptyFavorites() -> some View {
        VStack(spacing: 24) {
            Image(systemName: "heart.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 64, height: 64)
                .foregroundStyle(.red)
                .symbolEffect(.bounce, options: .repeat(1))
            VStack(spacing: 8) {
                Text("No Favorites Yet")
                    .font(.headline)
                
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text("Tap")
                    Image(systemName: "heart")
                        .foregroundStyle(.red)
                    Text("on bonus to add them to favorites")
                }
                .font(.subheadline)
                .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .center)
        }
        .padding(32)
        .modifier(DefaultBackgroundStyle())
    }
    
    @ViewBuilder static func makeCatalogGrid<Products: Collection>(products: Products, account: Account, router: Main.Router, namespace: Namespace.ID, showPointsCost: Bool = true) -> some View where Products.Element == Product {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 2), spacing: 8) {
            ForEach(Array(products), id: \.id) { product in
                BonusView.Row(product: product, showPointsCost: showPointsCost)
                    .aspectRatio(1/1.4, contentMode: .fit)
                    .matchedTransitionSource(id: product.id, in: namespace)
                    .contentShape(Rectangle())
                    .onTap {
                        router.route(sheet: .bonus(product, account, namespace))
                    }
            }
        }
    }
    
    @ViewBuilder static func makeLoadingState() -> some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 2), spacing: 8) {
            ForEach(0..<6, id: \.self) { _ in
                RoundedRectangle(cornerRadius: 24)
                    .fill(.ultraThinMaterial)
                    .aspectRatio(1/1.4, contentMode: .fit)
            }
        }
        .mask(
            LinearGradient(
                gradient: Gradient(stops: [
                    Gradient.Stop(color: .black, location: 0.0),
                    Gradient.Stop(color: .black, location: 0.6),
                    Gradient.Stop(color: .clear, location: 1.0)
                ]), startPoint: .top, endPoint: .bottom)
        )
        .loading(active: true)
    }
    
    // MARK: - Toolbar
    
    @ToolbarContentBuilder func makeToolbar() -> some ToolbarContent {
        ToolbarItemGroup(placement: .topBarTrailing) {
            Menu {
                Menu("Sort", systemImage: "arrow.up.arrow.down") {
                    Button("Low to High") {
                        sortProductsLowToHigh()
                    }
                    
                    Button("High to Low") {
                        sortProductsHighToLow()
                    }
                }
                .disabled(products.isEmpty)
                .opacity(products.isEmpty ? 0.2 : 1.0)
                
                Divider()
                Button {
                    toggleFavoritesFilter()
                } label: {
                    if showFavoritesOnly {
                        Label("Favorites", systemImage: "heart.fill")
                            .foregroundStyle(.red)
                    } else {
                        Label("Favorites", systemImage: "heart")
                    }
                }
                .disabled(products.isEmpty && !showFavoritesOnly)
                .opacity(products.isEmpty && !showFavoritesOnly ? 0.2 : 1.0)
            } label: {
                Image(systemName: "line.3.horizontal.decrease")
            }
        }
    }
}

// MARK: - FetchRequests Configuration

extension BonusesView {
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
