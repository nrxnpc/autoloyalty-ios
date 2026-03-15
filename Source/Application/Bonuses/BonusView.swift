import SwiftUI
import SwiftUIComponents
import NukeUI
import CoreData
import Dependencies

struct BonusView: View {
    // MARK: - Dependencies
    
    @Dependency(\.scope) var scope
    @Environment(\.dismiss) var dismiss
    
    // MARK: -
    
    @ObservedObject var product: Product
    @ObservedObject var account: Account
    
    // MARK: -
    
    @State private var isOrdering = false
    @State private var isLoading = true
    
    var canOrder: Bool {
        return !product.isOutOfStock && account.points >= product.pointsCost
    }
    
    // MARK: - Initialization
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                makeImagePreview(product)
                
                VStack(spacing: 16) {
                    makeTitle(product.name)
                    makeCost(product.pointsCost)
                    makeDescription(product.productDescription)
                    Spacer(minLength: 100)
                }
                .padding()
            }
        }
        .ignoresSafeArea(edges: .top)
        .overlay(alignment: .bottom) {
            makeOrderButton(product)
         }
        .toolbar(content: makeToolbar)
    }
}

extension BonusView {
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
                        Text("Claim Bonus")
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
                        Text("Claim Bonus")
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
            let useCase = ClaimBonusUseCase(scope: scope)
            /// let secret = try await useCase.execute(productId: product.id)
            /// FOR TEST ONLY
            let secret = try await useCase.mockExecuteSuccess(productId: product.id)
        } catch ClaimBonusUseCase.ClaimBonusError.operationCompletedButResultDelayed {
            UINotificationFeedbackGenerator().notificationOccurred(.error)
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
                    if product.isFavorite {
                        Image(systemName: "heart.fill")
                            .foregroundStyle(.red)
                    } else {
                        Image(systemName: "heart")
                            .foregroundStyle(.red)
                    }
                }
                .animation(.snappy, value: product)
            }
        }
    }
}
