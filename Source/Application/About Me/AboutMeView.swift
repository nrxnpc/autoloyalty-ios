import SwiftUI
import SwiftUIComponents

struct AboutMeView: View, ComponentBuilder {
    // MARK: - Depndencies
    
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var router: Main.Router
    
    // MARK: - State
    
    @StateObject var application = AboutMe()
    @State var deleteAccountConfirmation: Bool = false
    
    // MARK: -
    
    var body: some View {
        MakeList {
            makeAboutSection()
            makeActivitySection()
            makeSupportSection()
            
            makePolicySection()
                .padding()
        }
        .toolbar(content: makeToolbar)
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.large)
    }
}

extension AboutMeView {
    @ViewBuilder private func makeAboutSection() -> some View {
        MakeSection() {
            HStack(spacing: 16) {
                AccountImage(accountID: application.accountID)
                    .frame(width: 60, height: 60)
                
                VStack(alignment: .leading, spacing: 4) {
                    MakeTitle(LocalizedStringKey(application.username))
                    BalanceLabel(points: application.points)
                        .font(.callout)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .onTapGesture {
            router.route(sheet: .changeAboutMe(application))
        }
    }
    
    @ViewBuilder private func makeActivitySection() -> some View {
        MakeSection {
            MakeListRow(title: "QR Scan History", subtitle: "QR codes you've recently scanned", icon: "qrcode", iconColor: .blue) {
                router.route(sheet: .scanHistory)
            }
            
            MakeListRow(title: "Transactions", subtitle: "Full history of your point activity", icon: "arrow.up.arrow.down", iconColor: .green) {
                router.route(sheet: .transactionHistory)
            }
            
            MakeListRow(title: "Orders", subtitle: "History of your point exchanges", icon: "giftcard", iconColor: .pink) {
                router.route(sheet: .orders)
            }
            .frame(maxHeight: .infinity)
        }
    }
    
    @ViewBuilder private func makeSupportSection() -> some View {
        MakeSection {
            MakeOptionsListRow(title: "Have Questions?", subtitle: "We're here to help", icon: "questionmark.circle", iconColor: .secondary) {
                MakeListRow(title: "Contact Support", subtitle: "Chat with support team", icon: "headphones", iconColor: .secondary) {
                    router.route(sheet: .contactSupport)
                }
                MakeListRow(title: "Send Email", subtitle: "support@nsp-app.ru", icon: "envelope", iconColor: .secondary) {
                    if let url = URL(string: "mailto:support@nsp-app.ru?subject=App Support Request") {
                        UIApplication.shared.open(url)
                    }
                }
            }
            
            MakeOptionsListRow(title: "FAQ", subtitle: "Frequently asked questions", icon: "book", iconColor: .secondary) {
                MakeListRow(title: "How to Top Up Balance", subtitle: "Learn about earning points", icon: "plus.circle", iconColor: .secondary) {
                    router.route(sheet: .howTo(.topUpYourBalance))
                }
                MakeListRow(title: "How Does Delivery Work?", subtitle: "Order fulfillment process", icon: "shippingbox", iconColor: .secondary) {
                    router.route(sheet: .howTo(.howToRedeemGiftCards))
                }
            }
        }
    }
    
    @ViewBuilder private func makePolicySection() -> some View {
        VStack(spacing: 16) {
            HStack(spacing: 16) {
                Link("Privacy Policy", destination: URL(string: "http://nsp-app.ru/#privacy")!)
                    .font(.callout)
                    .foregroundStyle(.primary)
                
                Link("Terms Of Use", destination: URL(string: "http://nsp-app.ru/#terms")!)
                    .font(.callout)
                    .foregroundStyle(.primary)
            }
            
            HStack(alignment: .center, spacing: 4) {
                Image(systemName: "tag")
                Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown")
            }
            .font(.caption)
            .foregroundStyle(.secondary)
            .padding(.vertical, 4)
            .padding(.horizontal, 6)
            .background {
                RoundedRectangle(cornerRadius: 6)
                    .foregroundStyle(.ultraThinMaterial)
            }
            .onTap {
                let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
                UIPasteboard.general.string = "App Version: \(version)"
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
            }
        }
    }
    
    @ToolbarContentBuilder func makeToolbar() -> some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Menu {
                Button("Logout", systemImage: "person.fill.xmark", role: .cancel) {
                    Task { @MainActor in
                        await application.logout()
                        router.reset()
                    }
                }
                Button("Delete Account", systemImage: "person.slash", role: .destructive) {
                    deleteAccountConfirmation = true
                }
            } label: {
                Image(systemName: "ellipsis")
            }
            .confirmationDialog("Delete Account?", isPresented: $deleteAccountConfirmation, titleVisibility: .visible) {
                Button("Delete Account", role: .destructive) {
                    Task { @MainActor in
                        await application.deleteAccount()
                        router.reset()
                    }
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("This will permanently delete all your data, including bonus points. This action cannot be undone.")
            }
        }
    }
}

#Preview {
    AboutMeView()
}
