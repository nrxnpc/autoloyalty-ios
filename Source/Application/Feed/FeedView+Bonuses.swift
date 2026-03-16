import SwiftUI
import SwiftUIComponents

// MARK: - View Builder

extension FeedView {
    // MARK: - Catalog Section
    
    @ViewBuilder func makeCatalogSection() -> some View {
        VStack(alignment: .leading, spacing: 16) {
            makeCatalogHeader()
                .padding(.horizontal)
            
            if products.isEmpty {
                BonusesView.makeLoadingState()
            } else if let account = account.first {
                BonusesView.makeCatalogGrid(products: products.prefix(4), account: account, router: router, namespace: namespace)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
    
    @ViewBuilder func makeCatalogHeader() -> some View {
        HStack {
            Text("Bonuses")
                .font(.title2.weight(.semibold))
            
            Spacer()
            
            HStack(spacing: 4) {
                Text("View all")
                Image(systemName: "chevron.forward")
            }
            .font(.subheadline)
            .foregroundStyle(.secondary)
        }
        .foregroundStyle(.primary)
        .onTap {
            if let account = account.first {
                router.route(to: .catalog(account))
            }
        }
    }

}
