import Dependencies
import SwiftUI
import SwiftUIComponents

/// Balance card view mimicking a physical loyalty card with points display and QR scan action.
struct BalanceView: View, ComponentBuilder {
    @Dependency(\.scope) var scope
    @Environment(Main.Router.self) var router
    @ObservedObject var account: Account
    
    var body: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 24) {
                makeLogo()
                VStack(alignment: .leading, spacing: 0) {
                    makeTitle()
                    makeBalance()
                }
                
                HStack {
                    makeScanButton()
                    makeSecondaryButton()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 16)
            .clipShape(Rectangle())
        }
        .aspectRatio(1.586, contentMode: .fit)
        .modifier(CardBackground())
        .contextMenu {
            makeContextMenu()
        }
    }
}

extension BalanceView {
    @ViewBuilder func makeLogo() -> some View {
        HStack(alignment: .center, spacing: 8) {
            Image(systemName: "giftcard")
                .foregroundStyle(.pink.opacity(0.6))
                .font(.title)
            Spacer()
        }
    }
    
    @ViewBuilder func makeTitle() -> some View {
        HStack(alignment: .center, spacing: 8) {
            Text("Your Points")
                .font(.headline)
            Spacer()
        }
        .foregroundStyle(.secondary)
    }
    
    @ViewBuilder func makeBalance() -> some View {
        HStack(spacing: 0) {
            Text("\(account.points)")
                .contentTransition(.numericText())
                //.fontWeight(.semibold)
            
            Image(systemName: "star.fill")
                .foregroundColor(.orange)
                .scaleEffect(0.6)
        }
        .font(.largeTitle)
    }
    
    @ViewBuilder func makeScanButton() -> some View {
        Button {
            router.route(sheet: .scanner)
        } label: {
            HStack {
                Image(systemName: "qrcode.viewfinder")
                    .font(.title)
                Text("Scan QR code")
                    .font(.callout)
            }
        }
        .buttonStyle(GlassButtonStyle())
    }
    
    @ViewBuilder func makeSecondaryButton() -> some View {
        Menu {
            makeContextMenu()
        } label: {
            Image(systemName: "ellipsis")
                .font(.callout)
                .fontWeight(.bold)
        }
        .frame(width: 56, height: 56)
        .buttonStyle(GlassButtonStyle())
    }
    
    @ViewBuilder func makeContextMenu() -> some View {
        Button {
            router.route(sheet: .scanHistory)
        } label: {
            Label("Scan History", systemImage: "qrcode")
        }
        
        Button {
            router.route(sheet: .transactionHistory)
        } label: {
            Label("Transactions", systemImage: "arrow.up.arrow.down")
        }
        
        Button {
            router.route(sheet: .howTo(.topUpYourBalance))
        } label: {
            Label("How to Earn Points", systemImage: "info.circle")
        }
    }
}

/// Applies card-like background with glass effect for iOS 18+.
fileprivate struct CardBackground: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            content.glassEffect(.regular.interactive(), in: RoundedRectangle(cornerRadius: 24))
                .clipShape(RoundedRectangle(cornerRadius: 24))
        } else {
            content.background {
                RoundedRectangle(cornerRadius: 24)
                    .fill(.ultraThinMaterial)
            }
            .clipShape(RoundedRectangle(cornerRadius: 24))
        }
    }
}
