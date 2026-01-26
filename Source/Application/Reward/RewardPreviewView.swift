import CoreData
import SwiftUI
import NukeUI
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
            makeImagePreview()
            makeItemInfo()
        }
        // TODO: disabled
        // .overlay(alignment: .topTrailing) {
        //     makeFavoriteButton()
        //         .padding(8)
        // }
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 24))
    }
}

extension RewardPreviewView {
    @ViewBuilder func makeImagePreview() -> some View {
        ZStack {
            LazyImage(url: product.images.first?.sourceURL) { state in
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
                guard let context = product.managedObjectContext else {
                    return
                }
                try await context.perform {
                    product.isFavorite.toggle()
                    if context.hasChanges {
                        try context.save()
                    }
                }
                
                await MainActor.run {
                    isFavorite = product.isFavorite
                }
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
