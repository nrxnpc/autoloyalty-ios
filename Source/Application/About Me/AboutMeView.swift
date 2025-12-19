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
        }
        .overlay(alignment: .bottom) {
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
            VStack(spacing: 8) {
                MakeListRow(title: "QR Scan History", subtitle: "QR codes you've recently scanned", icon: "qrcode", iconColor: .blue) {
                    router.route(sheet: .scanHistory)
                }
                MakeListRow(title: "Transactions", subtitle: "Full history of your point activity", icon: "arrow.up.arrow.down", iconColor: .green) {
                    router.route(sheet: .transactionHistory)
                }
                MakeListRow(title: "Orders", subtitle: "History of your point exchanges", icon: "giftcard", iconColor: .pink) {
                    router.route(sheet: .orders)
                }
            }
        }
    }
    
    @ViewBuilder private func makeSupportSection() -> some View {
        MakeSection {
            VStack(spacing: 8) {
                MakeListRow(title: "Contact Support", subtitle: "Get help and send feedback", icon: "message", iconColor: .secondary) { }
                MakeListRow(title: "FAQ", subtitle: "Knowledge base", icon: "questionmark.circle", iconColor: .secondary) { }
                
                // TODO:
                // MakeListRow(title: "About App", subtitle: "Version and contacts", icon: "info.circle", iconColor: .init(hex: 0x48484A)) { }
            }
        }
    }
    
    @ViewBuilder private func makePolicySection() -> some View {
        VStack(spacing: 16) {
            HStack(spacing: 32) {
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
