import SwiftUI
import SwiftUIComponents

// MARK: - View Builder

extension FeedView {
    // MARK: - Balance Section
    
    @ViewBuilder func makeBalanceSection() -> some View {
        BalanceView()
            .trigger(visible: $isBalanceVisible)
            .padding(.horizontal)
            .animation(.bouncy, value: balanceMonitor.balance)
    }
}
