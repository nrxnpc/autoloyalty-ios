import CoreData
import SwiftUI
import SwiftUIComponents

struct RewardPreviewView: View {
    let product: Product
    
    @State var isFavorite: Bool
    
    init(product: Product) {
        self.product = product
        _isFavorite = .init(initialValue: product.isFavorite)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            makeItemPreview()
            makeItemInfo()
        }
        .overlay(alignment: .topTrailing) {
            makeFavoriteButton()
                .padding(8)
        }
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 24))
    }
}

extension RewardPreviewView {
    @ViewBuilder func makeItemPreview() -> some View {
        AsyncImage(url: product.images.first?.sourceURL) { image in
            image
                .resizable()
                .aspectRatio(contentMode: .fill)
        } placeholder: {
            Rectangle()
                .foregroundStyle(.regularMaterial)
        }
        .clipped()
    }
    
    @ViewBuilder func makeItemInfo() -> some View {
        VStack(alignment: .leading) {
            BalanceLabel(points: product.pointsCost)
                .font(.caption)
            
            Text(product.name)
                .font(.caption)
                .lineLimit(2)
        }
        .padding(.all, 8)
    }
    
    @ViewBuilder func makeFavoriteButton() -> some View {
        Button {
            Task {
                guard let context = product.managedObjectContext else {
                    return
                }
                try await context.perform {
                    product.isFavorite.toggle()
                    try context.save()
                }
                isFavorite = product.isFavorite
            }
        } label: {
            ZStack {
                if isFavorite {
                    Image(systemName: "heart.fill")
                        .foregroundStyle(.red)
                } else {
                    Image(systemName: "heart")
                        .foregroundStyle(.red)
                }
            }
            .animation(.easeInOut, value: isFavorite)
        }
    }
}

#Preview {
    RewardPreviewView(product: Product())
        .frame(width: 200, height: 250)
}
