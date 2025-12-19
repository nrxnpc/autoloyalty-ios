import SwiftUI

struct QRScanHistoryView: View {
    // MARK: - Dependencies
    
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var router: Main.Router
    
    // @FetchRequest var transactions: FetchedResults<BalanceTransaction>
    
    // MARK: - Initialization
    
    init() {
        // _transactions = FetchRequest(fetchRequest: BalanceTransaction.allTransactions(), animation: .smooth)
    }
    
    
    // MARK: -
    
    var body: some View {
        Group {
            // if transactions.isEmpty {
                makeEmptyState()
            // } else {
            //     makeTransctionsList()
            // }
        }
        .navigationTitle("Scan History")
        .toolbar(content: makeToolbar)
    }
}

extension QRScanHistoryView {
    @ViewBuilder func makeEmptyState() -> some View {
        ScrollView {
            VStack(spacing: 16) {
                HStack(alignment: .center) {
                    Image(systemName: "qrcode")
                        .font(.title)
                        .foregroundStyle(.blue)
                    Text("Your history will appear here once you start scanning QR codes to earn points")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
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
    
    // @ViewBuilder func makeHistoryList() -> some View {
    //     List(transactions, id: \.id) { transaction in
    //         makeRow(with: transaction)
    //             .onTap {
    //             }
    //     }
    // }
    
    @ViewBuilder func makeRow(with transaction: BalanceTransaction) -> some View {
        HStack(alignment: .top, spacing: 12) {
                Image(systemName: transaction.type.iconName)
                    .font(.title2)
                    .foregroundStyle(transaction.type.color)
                    .frame(width: 24)
                
                VStack(alignment: .leading, spacing: 4) {
                    BalanceLabel(points: transaction.amount, operation: transaction.type.operation)
                        .font(.headline)
                    
                    Text(transaction.transactionDescription)
                        .font(.callout)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.leading)
                        .lineLimit(3)
                }
                
                Spacer()
                
                Text(DateFormatters.shared.day.string(from: transaction.createdAt))
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
        }
    }
}


#Preview {
    NavigationView {
        QRScanHistoryView()
    }
}
