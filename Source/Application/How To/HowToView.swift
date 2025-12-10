import SwiftUI

enum HowTo: String {
    case topUpYourBalance
    case howToRedeemGiftCards
}

extension HowTo: Identifiable {
    var id: String { self.rawValue }
}

// MARK: - HowToTopUpYourBalanceView

struct HowToTopUpYourBalanceView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                makeHeader()
                makeInstructions()
            }
            .padding()
        }
        .toolbar(content: makeToolbar)
    }
}

extension HowToTopUpYourBalanceView {
    @ViewBuilder func makeHeader() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("How to Top Up Your Balance")
                .font(.title.weight(.bold))
            
            Text("Earn points by purchasing NSP parts and scanning special codes")
                .font(.callout)
                .foregroundStyle(.secondary)
        }
    }
    
    @ViewBuilder func makeInstructions() -> some View {
        VStack(alignment: .leading, spacing: 16) {
            makeStep(
                number: "1",
                title: "Purchase NSP Parts",
                description: "Buy genuine NSP automotive parts from authorized dealers or visit https://ns.parts"
            )
            
            makeStep(
                number: "2",
                title: "Find the Special Code",
                description: "Look for a unique QR code or special code printed on the product packaging"
            )
            
            makeStep(
                number: "3",
                title: "Scan the Code",
                description: "Use the scanner in this app to scan the code from your purchased parts"
            )
            
            makeStep(
                number: "4",
                title: "Earn Points",
                description: "Receive loyalty points that you can use to redeem rewards from our catalog"
            )
        }
    }
    
    @ViewBuilder func makeStep(number: String, title: LocalizedStringKey, description: LocalizedStringKey) -> some View {
        HStack(alignment: .center, spacing: 16) {
            Text(number)
                .font(.subheadline.weight(.bold))
                .foregroundStyle(.white)
                .frame(width: 32, height: 32)
                .background(Circle().fill(.blue))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                
                Text(description)
                    .font(.callout)
                    .foregroundStyle(.secondary)
            }
        }
    }
    
    @ToolbarContentBuilder func makeToolbar() -> some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button(action: dismiss.callAsFunction) {
                Image(systemName: "xmark")
            }
        }
    }
}

// MARK: - HowToRedeemGiftCardsView

struct HowToRedeemGiftCardsView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                makeInfo()
            }
            .padding()
        }
        .toolbar(content: makeToolbar)
    }
}

extension HowToRedeemGiftCardsView {
    @ViewBuilder func makeInfo() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("How to Redeem and Get Delivery")
                .font(.title.weight(.bold))
            
            Text("Select items from our catalog and exchange your points. Our support team will contact you to arrange the best delivery options for your order.")
                .font(.callout)
                .foregroundStyle(.secondary)
        }
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
        HowToRedeemGiftCardsView()
    }
}

#Preview {
    NavigationView {
        HowToTopUpYourBalanceView()
    }
}
