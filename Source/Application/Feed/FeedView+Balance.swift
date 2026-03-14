import SwiftUI
import SwiftUIComponents

// MARK: - View Builder

extension FeedView {
    // MARK: - Balance Section
    
    @ViewBuilder func makeBalanceSection() -> some View {
        if let account = account.first {
            BalanceView(account: account)
                .trigger(visible: $isBalanceVisible)
                .padding(.horizontal)
                .padding(.vertical, 8)
                .padding(.bottom, 8)
                .animation(.bouncy, value: balanceMonitor.balance)
        } else {
            // TOOD: loading state
        }
    }
}
