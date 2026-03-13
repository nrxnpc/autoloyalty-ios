import Dependencies
import SwiftUI
import SwiftUIComponents

struct BalanceView: View, ComponentBuilder {
    @Dependency(\.scope) var scope
    @Environment(Main.Router.self) var router
    var account: FetchedResults<Account>
    
    var balance: Int {
        account.first?.points ?? 0
    }
    
    var body: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 12) {
                makeTitle()
                makeBalance()
                makeScanButton()
            }
            .padding()
        }
        .frame(maxWidth: .infinity)
        .background {
            RoundedRectangle(cornerRadius: 24)
                .foregroundStyle(.regularMaterial)
        }
        .onTap {
            router.route(sheet: .transactionHistory)
        }
    }
}

extension BalanceView {
    @ViewBuilder func makeTitle() -> some View {
        HStack(alignment: .center, spacing: 2) {
            Text("Your Points")
                .font(.callout)
            
            Spacer()
            
            Button {
                router.route(sheet: .howTo(.topUpYourBalance))
            } label: {
                Image(systemName: "info.circle")
            }
        }
        .foregroundStyle(.secondary)
    }
    
    @ViewBuilder func makeBalance() -> some View {
        HStack(spacing: 0) {
            Text("\(balance)")
                .contentTransition(.numericText())
                .fontWeight(.semibold)
            
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
        .buttonStyle(StrokeButtonStyle())
    }
}
