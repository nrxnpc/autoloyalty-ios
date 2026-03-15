import CoreData
import Dependencies
import SwiftUI
import SwiftUIComponents
import NukeUI

extension BonusView {
    struct Row: View {
        @Dependency(\.scope) var scope
        @ObservedObject var product: Product
        @State var isFavorite: Bool
        
        init(product: Product) {
            self.product = product
            _isFavorite = .init(initialValue: product.isFavorite)
        }
        
        var body: some View {
            VStack(alignment: .leading, spacing: 0) {
                makeImagePreview()
                makeItemInfo()
            }
            .overlay(alignment: .topTrailing) {
                makeFavoriteButton()
                    .padding(8)
            }
            .modifier(DefaultBackgroundStyle())
        }
    }
}

extension BonusView.Row {
    @ViewBuilder func makeImagePreview() -> some View {
        ZStack {
            GeometryReader { geometry in
                LazyImage(url: product.image) { state in
                    if let image = state.image {
                        GeometryReader { geometry in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: geometry.size.width, height: geometry.size.height)
                                .clipped()
                        }
                    } else {
                        Rectangle()
                            .fill(.gray.opacity(0.3))
                            .overlay {
                                Image(systemName: "giftcard")
                                    .font(.system(size: 32))
                                    .foregroundColor(.gray)
                            }
                    }
                }
                .processors([
                    .resize(size: geometry.size, contentMode: .aspectFill)
                ])
            }
        }
    }
    
    @ViewBuilder func makeItemInfo() -> some View {
        VStack(alignment: .leading, spacing: 4) {
            BalanceLabel(points: product.pointsCost)
                .font(.headline)
                .padding(.top, 6)
            
            Text(product.name)
                .font(.subheadline)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
                .padding(.leading, 6)
            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: 96)
        .padding(.horizontal, 8)
    }
    
    @ViewBuilder func makeFavoriteButton() -> some View {
        Button {
            Task {
                let toggledFavorite = !product.isFavorite
                await MainActor.run {
                    isFavorite = toggledFavorite
                }
                
                do {
                    try await MarkFaforiteUseCase(scope: scope).setFavotite(toggledFavorite, objectID: product.objectID)
                } catch {
                    await MainActor.run {
                        isFavorite = !toggledFavorite
                    }
                }
            }
        } label: {
            ZStack {
                if product.isFavorite {
                    Image(systemName: "heart.fill")
                        .symbolEffect(.bounce, value: product.isFavorite)
                        .foregroundStyle(.red)
                } else {
                    Image(systemName: "heart")
                        .symbolEffect(.bounce, value: product.isFavorite)
                        .foregroundStyle(.red)
                }
            }
            .animation(.easeInOut, value: product.isFavorite)
        }
    }
}

#Preview {
    BonusView.Row(product: Product())
        .frame(width: 200, height: 250)
}
