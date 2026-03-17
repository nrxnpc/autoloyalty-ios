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
    @State var isRedeemed: Bool
    @State var isRedeemError = false
    
    var canOrder: Bool {
        /// TODO: FOR TEST ONLY
        /// return true
        !product.isOutOfStock && account.points >= product.pointsCost
    }
    
    init(product: Product, account: Account) {
        self.product = product
        self.account = account
        _isRedeemed = .init(initialValue: !product.orders.isEmpty)
    }
    
    // MARK: - Initialization
    
    var body: some View {
        ScrollView {
            ScrollViewReader { proxy in
                VStack(spacing: 0) {
                    makeImagePreview(product)
                    
                    VStack(spacing: 16) {
                        makeTitle(product.name)
                        if !isRedeemed {
                            makeCost(product.pointsCost)
                        }
                        makeDescription(product.productDescription)
                        
                        if isRedeemed {
                            Spacer(minLength: 16)
                            if product.orders.isEmpty {
                                makeRedemptionOrdersWaitRow()
                                    .id("WaitRow")
                            } else {
                                ForEach(Array(product.orders)) { order in
                                    makeRedemptionRow(order)
                                        .id(order.id)
                                }
                            }
                        } else if isRedeemError {
                            Spacer(minLength: 16)
                            makeRedemptionOrderErrorRow()
                                .id("ErrorRow")
                        }
                    }
                    .padding()
                }
                .onChange(of: isRedeemError) { _, newRedeemError in
                    guard newRedeemError else {
                        return
                    }
                    withAnimation(.snappy) {
                        proxy.scrollTo("ErrorRow", anchor: .bottom)
                    }
                }
                .onChange(of: isRedeemed) { _, newRedeemed in
                    guard newRedeemed else {
                        return
                    }
                    
                    guard !product.orders.isEmpty else {
                        withAnimation(.snappy) {
                            proxy.scrollTo("WaitRow", anchor: .bottom)
                        }
                        return
                    }
                    
                    if let lastOrder = product.orders.first {
                        withAnimation(.snappy) {
                            proxy.scrollTo(lastOrder.id, anchor: .bottom)
                        }
                    }
                }
                .animation(.snappy, value: isRedeemed)
            }
        }
        .scrollIndicators(.hidden)
        .ignoresSafeArea(edges: .top)
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
    
    @ViewBuilder func makeClaimButton(_ product: Product) -> some View {
        Button {
            Task {
                await claim(product)
            }
        } label: {
            HStack(spacing: 0) {
                if product.isOutOfStock {
                    Text("Coming Soon")
                } else if account.points < product.pointsCost {
                    Text("Required")
                    BalanceLabel(points: product.pointsCost - account.points, hasBackground: false)
                } else {
                    Image(systemName: "gift")
                        .foregroundStyle(.pink)
                    Text("Claim Bonus")
                }
            }
            .fontWeight(.semibold)
            .frame(maxWidth: .infinity)
            .padding()
            .symbolEffect(.pulse, value: isOrdering)
            .opacity(isOrdering ? 0.6 : 1.0)
        }
        .disabled(isOrdering)
        .animation(.snappy, value: isOrdering)
        .padding(.horizontal, 32)
    }
    
    @MainActor
    private func claim(_ product: Product) async {
        guard canOrder else { return }
        isOrdering = true
        defer { isOrdering = false }
        
        do {
            let useCase = ClaimBonusUseCase(scope: scope)
            try await useCase.execute(productId: product.id)
            
            /// TODO: FOR TEST ONLY
            /// if Bool.random() {
            ///     try await useCase.mockExecuteSuccess(productId: product.id)
            /// } else {
            ///     if isRedeemError {
            ///         try await useCase.mockExecuteDelayed()
            ///     } else {
            ///         try await useCase.mockExecuteFailure()
            ///     }
            /// }
            
            isRedeemed = true
            isRedeemError = false
        } catch ClaimBonusUseCase.ClaimBonusError.operationCompletedButResultDelayed {
            isRedeemed = true
            isRedeemError = false
        } catch {
            isRedeemError = true
            UINotificationFeedbackGenerator().notificationOccurred(.error)
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
        
        if !isRedeemed {
            ToolbarItem(placement: .bottomBar) {
                makeClaimButton(product)
            }
        }
    }
}

// MARK: - Redemption Row Components

extension BonusView {
    @ViewBuilder func makeRedemptionRow(_ order: Order) -> some View {
        VStack(spacing: 12) {
            makeOrderHeader(order)
            if let promocode = order.promocode {
                makePromocodeCard(promocode)
                if let instructions = order.instructions {
                    makeInstructionsCard(instructions)
                }
            } else if let digitalCertificate = order.digitalCertificate {
                makeDigitalCertificateCard(digitalCertificate)
                if let instructions = order.instructions {
                    makeInstructionsCard(instructions)
                }
            } else {
                if order.status != .cancelled {
                    makePreparingCard()
                } else {
                    makeCancelledCard()
                }
            }
        }
        .padding()
        .modifier(DefaultBackgroundStyle())
    }
    
    @ViewBuilder func makeRedemptionOrdersWaitRow() -> some View {
        VStack(spacing: 12) {
            HStack {
                Text(.now, style: .date)
                    .font(.caption)
                    .foregroundStyle(.tertiary)
                Spacer()
                makeOrderStatusBadge(.pending)
            }
            makePreparingCard()
        }
        .padding()
        .modifier(DefaultBackgroundStyle())
    }
    
    @ViewBuilder func makeRedemptionOrderErrorRow() -> some View {
        VStack(spacing: 12) {
            HStack {
                Text(.now, style: .date)
                    .font(.caption)
                    .foregroundStyle(.tertiary)
                Spacer()
                Text("Error")
                    .font(.caption)
                    .fontWeight(.medium)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(statusColor(for: .cancelled).opacity(0.2))
                    .foregroundStyle(statusColor(for: .cancelled))
                    .clipShape(Capsule())
            }
            VStack(spacing: 8) {
                Image(systemName: "wifi.exclamationmark")
                    .font(.largeTitle)
                    .foregroundStyle(.red, .secondary)
                    .symbolEffect(.bounce, options: .repeat(1))
                Text("We couldn't process your request. Please check your connection and try again in a moment.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            .frame(minHeight: 100)
            .frame(maxWidth: .infinity)
            .padding()
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .padding()
        .modifier(DefaultBackgroundStyle())
    }
    
    @ViewBuilder private func makeOrderHeader(_ order: Order) -> some View {
        HStack {
            Text(order.createdAt, style: .date)
                .font(.caption)
                .foregroundStyle(.tertiary)
            Spacer()
            makeOrderStatusBadge(order.status)
        }
    }
    
    @ViewBuilder private func makeOrderStatusBadge(_ status: Order.OrderStatus) -> some View {
        Text(statusTitle(for: status))
            .font(.caption)
            .fontWeight(.medium)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(statusColor(for: status).opacity(0.2))
            .foregroundStyle(statusColor(for: status))
            .clipShape(Capsule())
    }
    
    private func statusColor(for status: Order.OrderStatus) -> Color {
        switch status {
        case .pending, .processing: return .orange
        case .shipped, .delivered: return .green
        case .cancelled: return .red
        }
    }
    
    private func statusTitle(for status: Order.OrderStatus) -> String {
        switch status {
        case .pending, .processing: return "In Progress"
        case .shipped, .delivered: return "Available"
        case .cancelled: return "Cancelled"
        }
    }
    
    @ViewBuilder private func makePromocodeCard(_ promocode: String) -> some View {
        HStack(spacing: 0) {
            Text(promocode)
                .font(.title2)
                .fontWeight(.bold)
                .padding()
            Spacer()
            Button {
                UIPasteboard.general.string = promocode
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
            } label: {
                Image(systemName: "doc.on.doc")
                    .font(.title3)
            }
            .foregroundStyle(.secondary)
            .padding(.trailing)
        }
        .frame(minHeight: 80)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    @ViewBuilder private func makeDigitalCertificateCard(_ certificateURL: URL) -> some View {
        Link(destination: certificateURL) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Digital Certificate")
                        .font(.headline)
                    Text("Tap to view")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding()
                Spacer()
                Image(systemName: "arrow.up.right.square")
                    .font(.title2)
                    .padding(.trailing)
            }
            .frame(minHeight: 80)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(.plain)
    }
    
    @ViewBuilder private func makePreparingCard() -> some View {
        VStack(spacing: 8) {
            Image(systemName: "clock.fill")
                .font(.title)
                .foregroundStyle(.orange)
                .symbolEffect(.bounce, options: .repeat(1))
            Text("Preparing Your Bonus")
                .font(.headline)
            Text("Your reward is being prepared and will be available soon")
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(minHeight: 100)
        .frame(maxWidth: .infinity)
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    @ViewBuilder private func makeInstructionsCard(_ instructions: String) -> some View {
        HStack(alignment: .firstTextBaseline) {
            Image(systemName: "info.circle")
                .font(.caption)
            Text(instructions)
                .font(.caption)
        }
        .foregroundStyle(.tertiary)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    @ViewBuilder private func makeCancelledCard() -> some View {
        VStack(spacing: 8) {
            Image(systemName: "xmark.circle")
                .font(.title)
                .foregroundStyle(.red)
            
            Text("Order Cancelled")
                .font(.headline)
            
            Text("This order has been cancelled and is no longer available")
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(minHeight: 100)
        .frame(maxWidth: .infinity)
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}
