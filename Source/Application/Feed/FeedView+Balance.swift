import SwiftUI

// MARK: - View Builder

extension FeedView {
    // MARK: - Balance Section
    
    @ViewBuilder func makeBalanceSection() -> some View {
        BalanceView()
            .padding(.horizontal)
    }
}
