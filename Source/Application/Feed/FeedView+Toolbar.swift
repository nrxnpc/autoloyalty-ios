import SwiftUI
import SwiftUIComponents

// MARK: - View Builder

extension FeedView {
    // MARK: - Toolbar
    
    @ToolbarContentBuilder func makeToolbar() -> some ToolbarContent {
        if !isBalanceVisible {
            ToolbarItemGroup(placement: .topBarLeading) {
                Button {
                    router.route(sheet: .scanner(namespace))
                } label: {
                    Image(systemName: "qrcode.viewfinder")
                }
                
                Button {
                    router.route(sheet: .transactionHistory(namespace))
                } label: {
                    HStack(spacing: 0) {
                        Text("\(balance)")
                            .foregroundColor(.primary)
                        Image(systemName: "star.fill")
                            .scaleEffect(x: 0.6, y: 0.6)
                            .foregroundColor(.orange)
                    }
                }
            }
        }
        
        ToolbarItemGroup(placement: .topBarTrailing) {
            Button {
                if let account = account.first {
                    router.route(to: .aboutMe(account))
                }
            } label: {
                if let account = account.first {
                    AccountImage(account: account)
                        .frame(width: 28, height: 28)
                } else {
                    Circle()
                        .fill(.regularMaterial)
                        .frame(width: 28, height: 28)
                }
            }
            .contextMenu {
                Button {
                    router.route(sheet: .scanHistory(namespace))
                } label: {
                    Label("Scan History", systemImage: "qrcode") // blue
                }
                
                Button {
                    router.route(sheet: .transactionHistory(namespace))
                } label: {
                    Label("Transactions", systemImage: "arrow.up.arrow.down") // green
                }
                
                // Button {
                //     router.route(sheet: .orders)
                // } label: {
                //     Label("My Rewards", systemImage: "giftcart") // pink
                // }
            }
            
            Button {
                router.route(to: .inbox)
            } label: {
                if inboxMonitor.unreadCount > 0 {
                    Image(systemName: "bell.badge")
                        .foregroundStyle(.red, .primary)
                        .symbolEffect(.wiggle, options: .repeat(3))
                } else {
                    Image(systemName: "bell")
                        .foregroundStyle(.primary)
                }
            }
            .contextMenu {
                Button {
                    inboxMonitor.markAllAsRead()
                } label: {
                    Label("Mark all as read", systemImage: "checkmark.circle")
                }
                .disabled(inboxMonitor.unreadCount == 0)
            }
        }
    }
}
