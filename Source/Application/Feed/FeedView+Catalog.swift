import SwiftUI
import SwiftUIComponents

// MARK: - View Builder

extension FeedView {
    // MARK: - Catalog Section
    
    @ViewBuilder func makeCatalogSection() -> some View {
        VStack(alignment: .leading, spacing: 16) {
            makeCatalogHeader()
            
            if products.isEmpty {
                if showFavoritesOnly {
                    makeEmptyFavorites()
                } else {
                    makeLoadingState()
                }
            } else {
                makeCatalogGrid()
            }
        }
        .padding()
    }
    
    @ViewBuilder func makeCatalogHeader() -> some View {
        HStack {
            Text("Catalog")
                .font(.title2.weight(.semibold))
            
            Spacer()
            
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
        .foregroundStyle(.primary)
    }
    
    @ViewBuilder func makeLoadingState() -> some View {
        LazyVGrid(columns: makeGridColumns(), spacing: 8) {
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
    
    @ViewBuilder func makeEmptyFavorites() -> some View {
        VStack(spacing: 16) {
            Text("No Favorites Yet")
                .font(.headline)
            
            HStack(spacing: 4) {
                Text("Tap")
                Image(systemName: "heart")
                    .foregroundStyle(.red)
                Text("on products to add them to favorites")
            }
            .font(.subheadline)
            .foregroundStyle(.secondary)
            
            Spacer()
                .frame(height: 8)
            
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
    
    @ViewBuilder func makeCatalogGrid() -> some View {
        LazyVGrid(columns: makeGridColumns(), spacing: 8) {
            ForEach(products, id: \.id) { product in
                RewardPreviewView(product: product)
                    .aspectRatio(1/1.4, contentMode: .fit)
            }
        }
    }
    
    private func makeGridColumns() -> [GridItem] {
        Array(repeating: GridItem(.flexible(), spacing: 8), count: 2)
    }
    
}
