import SwiftUI

struct OrdersView: View {
    // MARK: - Dependencies
    
    @Environment(\.dismiss) private var dismiss
    @Environment(Main.Router.self) var router
    
    @FetchRequest var orders: FetchedResults<Order>
    
    // MARK: - State
     
    @State var showRedeemInfo = false
    
    // MARK: - Initialization
    
    init() {
        _orders = FetchRequest(fetchRequest: Order.allOrders(), animation: .smooth)
    }
    
    // MARK: -
    
    var body: some View {
        Group {
            if orders.isEmpty {
                makeEmptyState()
            } else {
                makeOrdersList()
            }
        }
        .navigationTitle("Orders")
        .toolbar(content: makeToolbar)
        .sheet(isPresented: $showRedeemInfo) {
            NavigationView {
                HowToRedeemGiftCardsView()
            }
            .presentationDetents([.medium])
            .presentationDragIndicator(.visible)
        }
    }
}

extension OrdersView {
    @ViewBuilder func makeEmptyState() -> some View {
        ScrollView {
            VStack(spacing: 16) {
                HStack(alignment: .center) {
                    Image(systemName: "cart")
                        .font(.title)
                        .foregroundStyle(.pink)
                    Text("Your reward orders will appear here once you start redeeming points from the catalog")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.leading)
                }
            }
            .padding()
            .background {
                RoundedRectangle(cornerRadius: 24)
                    .foregroundStyle(.regularMaterial)
            }
            .padding()
        }
    }
    
    @ViewBuilder func makeOrdersList() -> some View {
        List(orders, id: \.id) { order in
            makeRow(with: order)
                .onTap {
                }
        }
    }
    
    @ViewBuilder func makeRow(with order: Order) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: order.status.iconName)
                .font(.title2)
                .foregroundStyle(order.status.color)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 8) {
                Text(order.productName)
                    .font(.headline)
                
                BalanceLabel(points: order.totalPoints, operation: .outcome)
                    .font(.callout)
                
                // HStack {
                //     BalanceLabel(points: order.totalPoints, operation: .outcome)
                //         .font(.callout)
                //
                //     Text(order.status.displayName)
                //         .font(.caption)
                //         .foregroundStyle(order.status.color)
                //         .padding(.horizontal, 8)
                //         .padding(.vertical, 2)
                //         .background(order.status.color.opacity(0.1))
                //         .clipShape(Capsule())
                // }
            }
            
            Spacer()
            
            Text(DateFormatters.shared.day.string(from: order.createdAt))
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding(.vertical, 4)
    }
    
    @ToolbarContentBuilder func makeToolbar() -> some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button(action: dismiss.callAsFunction) {
                Image(systemName: "xmark")
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        
        ToolbarItem(placement: .topBarTrailing) {
            Menu {
                Text("Need Help?")
                
                Button("Contact Support", systemImage: "headphones") {
                    router.route(sheet: .contactSupport)
                }
                
                Menu("FAQ", systemImage: "book") {
                    Button("How Does Delivery Work?") {
                        showRedeemInfo = true
                    }
                }
            } label: {
                Image(systemName: "questionmark.circle")
            }
        }
    }
}

extension Order.OrderStatus {
    var iconName: String {
        switch self {
        case .pending: return "clock"
        case .processing: return "gearshape"
        case .shipped: return "shippingbox"
        case .delivered: return "checkmark.circle"
        case .cancelled: return "xmark.circle"
        }
    }
    
    var color: Color {
        switch self {
        case .pending: return .orange
        case .processing: return .blue
        case .shipped: return .purple
        case .delivered: return .green
        case .cancelled: return .red
        }
    }
    
    var displayName: String {
        switch self {
        case .pending: return "Pending"
        case .processing: return "Processing"
        case .shipped: return "Shipped"
        case .delivered: return "Delivered"
        case .cancelled: return "Cancelled"
        }
    }
}

#Preview {
    NavigationView {
        OrdersView()
    }
}
