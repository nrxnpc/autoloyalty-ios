import SwiftUI

struct BalanceTransactionsView: View {
    // MARK: - Dependencies
    
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var router: Main.Router
    
    // MARK: - State
    
    @State var showHowTo = false
    
    // MARK: -
    
    var body: some View {
        ScrollView {
            makeEmptyState()
        }
        .navigationTitle("No Transactions Yet")
        .toolbar(content: makeToolbar)
        .sheet(isPresented: $showHowTo) {
            NavigationView {
                HowToTopUpYourBalanceView()
            }
            .presentationDetents([.medium])
            .presentationDragIndicator(.visible)
        }
    }
}

extension BalanceTransactionsView {
    @ViewBuilder func makeEmptyState() -> some View {
        VStack(spacing: 16) {
            HStack(alignment: .center) {
                Image(systemName: "qrcode")
                    .font(.title)
                    .foregroundStyle(.blue)
                Text("All your point transactions will appear here once you start earning or spending points")
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
    
    @ToolbarContentBuilder func makeToolbar() -> some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button(action: dismiss.callAsFunction) {
                Image(systemName: "xmark")
            }
        }
        
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                showHowTo = true
            } label: {
                Image(systemName: "questionmark.circle")
            }
        }
    }
}
#Preview {
    NavigationView {
        BalanceTransactionsView()
    }
}
