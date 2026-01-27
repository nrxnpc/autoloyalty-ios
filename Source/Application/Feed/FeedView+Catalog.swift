import SwiftUI
import SwiftUIComponents

// MARK: - View Builder

extension FeedView {
    // MARK: - Catalog Section
    
    @ViewBuilder func makeCatalogSection() -> some View {
        VStack(alignment: .leading, spacing: 16) {
            makeCatalogHeader()
            
            if products.isEmpty {
                CatalogView.makeLoadingState()
            } else {
                CatalogView.makeCatalogGrid(products: products.prefix(6), router: router, namespace: namespace)
                makeCatalogFooter()
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
    
    @ViewBuilder func makeCatalogHeader() -> some View {
        HStack {
            Text("Catalog")
                .font(.title2.weight(.semibold))
            
            Spacer()
        }
        .foregroundStyle(.primary)
        .onTap {
            router.route(to: .catalog)
        }
    }
    
    @ViewBuilder func makeCatalogFooter() -> some View {
        HStack {
            Text("See more")
            Spacer()
            Image(systemName: "chevron.forward")
        }
        .foregroundStyle(.primary)
        .font(.headline)
        .padding()
        .background {
            RoundedRectangle(cornerRadius: 14)
                .foregroundStyle(.ultraThinMaterial)
        }
        .onTap {
            router.route(to: .catalog)
        }
    }
}
