import SwiftUI

struct BalanceTransactionsView: View {
    // MARK: - Dependencies
    
    @Environment(\.dismiss) private var dismiss
    @Environment(Main.Router.self) var router
    
    @FetchRequest var transactions: FetchedResults<BalanceTransaction>
    
    // MARK: - State
    
    @State var showHowTo = false
    
    // MARK: - Initialization
    
    init() {
        _transactions = FetchRequest(fetchRequest: BalanceTransaction.allTransactions(), animation: .smooth)
    }
    
    
    // MARK: -
    
    var body: some View {
        Group {
            if transactions.isEmpty {
                makeEmptyState()
            } else {
                makeTransctionsList()
            }
        }
        .navigationTitle("Transactions")
        .toolbar(content: makeToolbar)
        .sheet(isPresented: $showHowTo) {
            NavigationView {
                HowToTopUpYourBalanceView()
            }
            .presentationDetents([.medium])
            .presentationDragIndicator(.visible)
        }
    }
}

extension BalanceTransactionsView {
    @ViewBuilder func makeEmptyState() -> some View {
        ScrollView {
            VStack(spacing: 16) {
                HStack(alignment: .center) {
                    Image(systemName: "arrow.up.arrow.down")
                        .font(.title)
                        .foregroundStyle(.green)
                    Text("All your point transactions will appear here once you start earning or spending points")
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
    
    @ViewBuilder func makeTransctionsList() -> some View {
        List(transactions, id: \.id) { transaction in
            makeRow(with: transaction)
                .onTap {
                }
        }
    }
    
    @ViewBuilder func makeRow(with transaction: BalanceTransaction) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 12) {
            Image(systemName: transaction.type.iconName)
                .font(.title2)
                .foregroundStyle(transaction.type.color, transaction.type.secondaryColor)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 4) {
                BalanceLabel(points: transaction.amount, operation: transaction.type.operation)
                    .font(.headline)
                
                Text(transaction.transactionDescription)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.leading)
                    .lineLimit(3)
            }
            
            Spacer()
            VStack {
                Text(DateFormatters.shared.day.string(from: transaction.createdAt))
                    .font(.caption)
                    .foregroundStyle(.tertiary)
                Spacer()
            }
        }
        .padding(.vertical, 4)
    }
    
    @ToolbarContentBuilder func makeToolbar() -> some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button(action: dismiss.callAsFunction) {
                Image(systemName: "xmark")
            }
        }
        
        ToolbarItem(placement: .topBarTrailing) {
            Menu {
                Text("Need Help?")
                
                Button("Contact Support", systemImage: "headphones") {
                    router.route(sheet: .contactSupport)
                }
                
                Menu("FAQ", systemImage: "book") {
                    Button("How to Top Up Balance") {
                        showHowTo = true
                    }
                }
            } label: {
                Image(systemName: "questionmark.circle")
            }
        }
    }
}

extension BalanceTransaction.TransactionType {
    var iconName: String {
        switch self {
        case .earned: return "qrcode.viewfinder"
        case .bonus: return "gift"
        case .spent: return "qrcode.viewfinder"
        case .penalty: return "exclamationmark.triangle"
        }
    }
    
    var color: Color {
        switch self {
        case .earned: return .green
        case .bonus: return .green
        case .spent: return .pink
        case .penalty: return .red
        }
    }
    
    var secondaryColor: Color {
        switch self {
        case .earned: return .secondary
        case .bonus: return .green
        case .spent: return .secondary
        case .penalty: return .secondary
        }
    }
    
    var operation: BalanceLabel.Operation {
        switch self {
        case .earned, .bonus: return .income
        case .spent, .penalty: return .outcome
        }
    }
}

#Preview {
    NavigationView {
        BalanceTransactionsView()
    }
}
