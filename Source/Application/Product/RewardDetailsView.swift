import SwiftUI
import SwiftUIComponents
import CoreData
import Dependencies

struct RewardDetailsView: View {
    @Dependency(\.scope) var scope
    
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var balanceMonitor: BalanceMonitor
    
    @FetchRequest var products: FetchedResults<Product>
    @State private var isOrdering = false
    @State private var isLoading = true
    
    var product: Product? {
        products.first
    }
    
    var canOrder: Bool {
        guard let product else { return false }
        return !product.isOutOfStock && balanceMonitor.balance >= product.pointsCost
    }
    
    init(id: String) {
        _products = FetchRequest(fetchRequest: Product.by(id: id))
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                if let product = product {
                    makeImages(product)
                    
                    VStack(spacing: 16) {
                        makeTitle(product.name)
                        makeCost(product.pointsCost)
                        makeDescription(product.productDescription)
                        Spacer(minLength: 100)
                    }
                    .padding()
                } else {
                    makeLoadingState()
                }
            }
        }
        .ignoresSafeArea(edges: .top)
        .overlay(alignment: .bottom) {
            if let product = product {
                makeOrderButton(product)
            }
        }
        .toolbar(content: makeToolbar)
    }
}

extension RewardDetailsView {
    @ViewBuilder func makeImages(_ product: Product) -> some View {
        AsyncImage(url: product.images.first?.sourceURL) { image in
            image
                .resizable()
                .aspectRatio(contentMode: .fill)
        } placeholder: {
            Rectangle()
                .foregroundStyle(.regularMaterial)
        }
        .frame(height: 300)
        .clipped()
    }
    
    @ViewBuilder func makeTitle(_ title: String) -> some View {
        HStack {
            Text(title)
                .font(.largeTitle)
                .fontWeight(.bold)
                .multilineTextAlignment(.leading)
            Spacer()
        }
    }
    
    @ViewBuilder func makeDescription(_ description: String) -> some View {
        HStack {
            Text(LocalizedStringKey(description))
                .font(.body)
                .multilineTextAlignment(.leading)
            Spacer()
        }
    }
    
    @ViewBuilder func makeCost(_ cost: Int) -> some View {
        HStack {
            BalanceLabel(points: cost)
            Spacer()
        }
    }
    
    @ViewBuilder func makeOrderButton(_ product: Product) -> some View {
        Button {
            Task {
                await createOrder(product)
            }
        } label: {
            HStack {
                if isOrdering {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.8)
                } else {
                    Text("Order")
                        .fontWeight(.semibold)
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(canOrder ? Color.accentColor : Color.gray)
            .foregroundColor(.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .disabled(!canOrder || isOrdering)
        .padding()
        .background(.regularMaterial)
    }
    
    @ViewBuilder func makeLoadingState() -> some View {
        VStack(spacing: 16) {
            Rectangle()
                .frame(height: 300)
                .loading(active: true)
            
            VStack(spacing: 16) {
                HStack {
                    Rectangle()
                        .frame(height: 32)
                        .loading(active: true)
                    Spacer()
                }
                
                HStack {
                    Rectangle()
                        .frame(width: 80, height: 24)
                        .loading(active: true)
                    Spacer()
                }
                
                VStack(spacing: 8) {
                    Rectangle()
                        .frame(height: 16)
                        .loading(active: true)
                    Rectangle()
                        .frame(height: 16)
                        .loading(active: true)
                    HStack {
                        Rectangle()
                            .frame(width: 120, height: 16)
                            .loading(active: true)
                        Spacer()
                    }
                }
            }
            .padding()
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                isLoading = false
            }
        }
    }
    
    private func toggleFavorite() {
        guard let product else { return }
        let context = scope.coreDataContext
        context.perform {
            product.isFavorite.toggle()
            try? context.save()
        }
    }
    
    private func createOrder(_ product: Product) async {
        isOrdering = true
        defer { isOrdering = false }
        
        do {
            let useCase = CreateOrderUseCase(scope: scope)
            _ = try await useCase.execute(productId: product.sync.externalID ?? "")
            dismiss()
        } catch {
            // Handle error
        }
    }
    
    @ToolbarContentBuilder func makeToolbar() -> some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Button(action: dismiss.callAsFunction) {
                Image(systemName: "xmark")
            }
        }
        
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                toggleFavorite()
            } label: {
                ZStack {
                    if let product, product.isFavorite {
                        Image(systemName: "heart.fill")
                            .foregroundStyle(.red)
                    } else {
                        Image(systemName: "heart")
                            .foregroundStyle(.red)
                    }
                }
                .background(Circle().fill(.ultraThinMaterial))
                .animation(.easeInOut, value: product)
            }
        }
    }
}
