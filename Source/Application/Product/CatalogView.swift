import SwiftUI
import SwiftUIComponents

struct CatalogView: View {
    // MARK: - Dependencies
    
    @Environment(Main.Router.self) var router
    
    // MARK: - Request
    
    @FetchRequest var products: FetchedResults<Product>
    
    // MARK: - State
    
    @Namespace internal var namespace
    @State internal var showFavoritesOnly = false
    
    // MARK: - Initialization
    
    init() {
        _products = FetchRequest(fetchRequest: Product.allProductsFetchRequest(), animation: .smooth)
    }
    
    var body: some View {
        ScrollView {
            if showFavoritesOnly && products.isEmpty {
                makeEmptyFavorites()
                    .padding()
            } else {
                CatalogView.makeCatalogGrid(products: products, router: router, namespace: namespace)
                    .padding()
            }
        }
        .navigationTitle("Catalog")
        .navigationBarTitleDisplayMode(.large)
        .animation(.easeInOut, value: showFavoritesOnly)
        .toolbar(content: makeToolbar)
    }
}

// MARK: - View Builder

extension CatalogView {
    @ViewBuilder func makeEmptyFavorites() -> some View {
        VStack(spacing: 16) {
            Text("No Favorites Yet")
                .font(.headline)
            
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text("Tap")
                Image(systemName: "heart")
                    .foregroundStyle(.red)
                Text("on products to add them to favorites")
            }
            .font(.subheadline)
            .foregroundStyle(.secondary)
            
            Button("Browse Products") {
                toggleFavoritesFilter()
            }
            .buttonStyle(StrokeButtonStyle())
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .padding()
        .background {
            RoundedRectangle(cornerRadius: 24)
                .foregroundStyle(.regularMaterial)
        }
    }
    
    @ViewBuilder static func makeCatalogGrid<Products: Collection>(products: Products, router: Main.Router, namespace: Namespace.ID) -> some View where Products.Element == Product {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 2), spacing: 8) {
            ForEach(Array(products), id: \.id) { product in
                ProductPreviewView(product: product)
                    .aspectRatio(1/1.4, contentMode: .fit)
                    .matchedTransitionSource(id: product.id, in: namespace)
                    .contentShape(Rectangle())
                    .onTap {
                        router.route(sheet: .productDetails(product.id, namespace))
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
                Button("Low to High") {
                    sortProductsLowToHigh()
                }
                
                Button("High to Low") {
                    sortProductsHighToLow()
                }
            } label: {
                Image(systemName: "arrow.up.arrow.down")
            }
            .disabled(products.isEmpty)
            .opacity(products.isEmpty ? 0.2 : 1.0)
            
            
            Button {
                toggleFavoritesFilter()
            } label: {
                ZStack {
                    if showFavoritesOnly {
                        Image(systemName: "heart.fill")
                            .foregroundStyle(.red)
                    } else {
                        Image(systemName: "heart")
                    }
                }
                .contentTransition(.symbolEffect(.replace))
            }
            .disabled(products.isEmpty && !showFavoritesOnly)
            .opacity(products.isEmpty && !showFavoritesOnly ? 0.2 : 1.0)
        }
    }
}

// MARK: - FetchRequests Configuration

extension CatalogView {
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
