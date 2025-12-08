import SwiftUI
import SwiftUIComponents
import CoreData

struct RewardDetailsView: View {
    @Environment(\.dismiss) var dismiss
    @FetchRequest var products: FetchedResults<Product>
    
    var product: Product? {
        products.first
    }
    
    init(id: String) {
        _products = FetchRequest(fetchRequest: Product.by(id: id))
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                if let product = product {
                    makeTitle(product.name)
                    makeDescription(product.productDescription)
                    makeCost(product.pointsCost)
                } else {
                    Text("Product not found")
                }
            }
            .padding()
            .toolbar(content: makeToolbar)
        }
    }
}

extension RewardDetailsView {
    @ViewBuilder func makePreview() -> some View {
        EmptyView()
    }
    
    @ViewBuilder func makeTitle(_ title: String) -> some View {
        Text(title)
            .font(.largeTitle)
            .fontWeight(.bold)
    }
    
    @ViewBuilder func makeDescription(_ description: String) -> some View {
        Text(description)
            .font(.body)
            .multilineTextAlignment(.leading)
    }
    
    @ViewBuilder func makeCost(_ cost: Int) -> some View {
        Text("\(cost) points")
            .font(.title2)
            .foregroundStyle(.secondary)
    }
    
    @ToolbarContentBuilder func makeToolbar() -> some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button(action: dismiss.callAsFunction) {
                Image(systemName: "xmark")
            }
        }
        
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                
            } label: {
                Image(systemName: "heart.fill")
                    .foregroundStyle(.red)
            }
        }
    }
}
