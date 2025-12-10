import SwiftUI
import SwiftUIComponents

struct BalanceView: View, ComponentBuilder {
    @EnvironmentObject var router: Main.Router
    @EnvironmentObject var balanceMonitor: BalanceMonitor
    
    var body: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 24) {
                makeTitle()
                makeBalance()
                makeScanButton()
            }
            .padding()
        }
        .contentShape(Rectangle())
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
            Text("Balance")
                .font(.callout)
            
            Image(systemName: "star.fill")
                .font(.callout)
                .foregroundColor(.orange)
                .scaleEffect(0.8)
            
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
        Text("\(balanceMonitor.balance)")
            .font(.largeTitle)
            .fontWeight(.semibold)
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

#Preview {
    BalanceView()
}
