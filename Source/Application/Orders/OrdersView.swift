import SwiftUI

struct OrdersView: View {
    // MARK: - Dependencies
    
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var router: Main.Router
    
    // MARK: - State
     
    @State var showRedeemInfo = false
    
    // MARK: -
    
    var body: some View {
        ScrollView {
            makeEmptyState()
        }
        .navigationTitle("No Orders Yet")
        .toolbar(content: makeToolbar)
        .sheet(isPresented: $showRedeemInfo) {
            NavigationView {
                HowToRedeemGiftCardsView()
            }
            .presentationDetents([.medium])
            .presentationDragIndicator(.visible)
        }
    }
}

extension OrdersView {
    @ViewBuilder func makeEmptyState() -> some View {
        VStack(spacing: 16) {
            HStack(alignment: .center) {
                Image(systemName: "giftcard")
                    .font(.title)
                    .foregroundStyle(.pink)
                Text("Your reward orders will appear here once you start redeeming points from the catalog")
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
    
    @ToolbarContentBuilder func makeToolbar() -> some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button(action: dismiss.callAsFunction) {
                Image(systemName: "xmark")
            }
        }
        
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                showRedeemInfo = true
            } label: {
                Image(systemName: "questionmark.circle")
            }
        }
    }
}
#Preview {
    NavigationView {
        OrdersView()
    }
}
