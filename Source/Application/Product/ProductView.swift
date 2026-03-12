import SwiftUI
import SwiftUIComponents
import NukeUI
import CoreData
import Dependencies

struct ProductView: View {
    // MARK: - Dependencies
    
    @Dependency(\.scope) var scope
    @Environment(\.dismiss) var dismiss
    
    // MARK: -
    
    @FetchRequest var products: FetchedResults<Product>
    
    // MARK: -
    
    @State private var isOrdering = false
    @State private var isLoading = true
    @State var balanceMonitor = BalanceMonitor()
    
    var product: Product? {
        products.first
    }
    
    var canOrder: Bool {
        guard let product else { return false }
        return !product.isOutOfStock && balanceMonitor.balance >= product.pointsCost
    }
    
    // MARK: - Initialization
    
    init(id: String) {
        _products = FetchRequest(fetchRequest: Product.by(id: id))
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                if let product = product {
                    makeImagePreview(product)
                    
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

extension ProductView {
    @ViewBuilder func makeImagePreview(_ product: Product) -> some View {
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
        if #available(iOS 26.0, *) {
            Button {
                Task {
                    await createOrder(product)
                }
            } label: {
                HStack {
                    if product.isOutOfStock {
                        Text("Ouf of stock")
                    } else {
                        Image(systemName: "cart")
                        Text("Order")
                    }
                }
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity)
                .padding()
                .foregroundColor(.primary)
                .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .buttonStyle(.glass)
            .disabled(!canOrder || isOrdering)
            .padding(.horizontal, 32)
        } else {
            Button {
                Task {
                    await createOrder(product)
                }
            } label: {
                HStack {
                    if product.isOutOfStock {
                        Text("Ouf of stock")
                    } else {
                        Image(systemName: "cart")
                        Text("Order")
                    }
                }
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity)
                .padding()
                .background(canOrder ? Color.accentColor : Color.gray)
                .foregroundColor(.primary)
                .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .disabled(!canOrder || isOrdering)
            .padding(.horizontal, 32)
        }
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
            if context.hasChanges {
                try? context.save()
            }
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
            UINotificationFeedbackGenerator().notificationOccurred(.error)
        }
    }
    
    @ToolbarContentBuilder func makeToolbar() -> some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Button(action: dismiss.callAsFunction) {
                Image(systemName: "xmark")
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
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
                .animation(.easeInOut, value: product)
            }
        }
    }
}
