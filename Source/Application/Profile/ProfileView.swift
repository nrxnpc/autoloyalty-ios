import SwiftUI
import SwiftUIComponents

struct ProfileView: View, ComponentBuilder {
    // MARK: - Depndencies
    
    @Environment(\.dismiss) var dismiss
    @Environment(Main.Router.self) var router
    @ObservedObject var account: Account
    
    // MARK: - State
    
    @StateObject var application = AboutMe()
    @State var deleteAccountConfirmation: Bool = false
    
    // MARK: -
    
    var body: some View {
        MakeList {
            makeAboutSection()
            makeMyRewardsSection()
        }
        .toolbar(content: makeToolbar)
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.large)
    }
}

extension ProfileView {
    @ViewBuilder private func makeAboutSection() -> some View {
        MakeSection {
            HStack(spacing: 16) {
                AccountImage(account: account)
                    .frame(width: 60, height: 60)
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 16) {
                        MakeTitle(LocalizedStringKey(application.username))
                        Spacer()
                    }
                    BalanceLabel(points: application.points)
                        .font(.callout)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                Button("", systemImage: "pencil.line") {
                    router.route(sheet: .changeAboutMe(application, account))
                }
                .buttonStyle(.plain)
                /// .symbolEffect(.wiggle, options: .repeat(1))
            }
            .padding(.vertical, 8)
        }
        .padding(.vertical)
        .onTapGesture {
            router.route(sheet: .changeAboutMe(application, account))
        }
    }
    
    @ViewBuilder private func makeMyRewardsSection() -> some View {
        MakeSection(title: "My Rewards") {
            VStack(alignment: .leading, spacing: 16) {
                MyRewardsView.makeEmptyState()
                    .padding()
                
                // if products.isEmpty {
                //     BonusesView.makeLoadingState()
                // } else {
                //     BonusesView.makeCatalogGrid(products: products.prefix(6), router: router, namespace: namespace)
                //     makeCatalogFooter()
                // }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
    }
    
    @ToolbarContentBuilder func makeToolbar() -> some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Menu {
                Menu("Have Questions?", systemImage: "questionmark.circle") {
                    Button("Contact Support", systemImage: "headphones") {
                        router.route(sheet: .contactSupport)
                    }
                    
                    Button("Email Us", systemImage: "envelope") {
                        if let url = URL(string: "mailto:support@nsp-app.ru?subject=App Support Request") {
                            UIApplication.shared.open(url)
                        }
                    }
                    
                    Menu("FAQ", systemImage: "book") {
                        Button("How to Top Up Balance?") {
                            router.route(sheet: .howTo(.topUpYourBalance))
                        }
                        
                        // Button("How Does Delivery Work?") {
                        //     router.route(sheet: .howTo(.howToRedeemGiftCards))
                        // }
                    }
                }
                
                Menu("Account", systemImage: "person") {
                    Button("Logout") {
                        Task { @MainActor in
                            await application.logout()
                            router.reset()
                        }
                    }
                    Menu("Delete Account") {
                        Text("This will permanently delete all your data")
                        Button("Delete Account", role: .destructive) {
                            deleteAccountConfirmation = true
                        }
                    }
                }
                
                Menu("About", systemImage: "info.circle") {
                    Link(destination: URL(string: "http://nsp-app.ru/#privacy")!) {
                        Label("Privacy Policy", systemImage: "shield")
                    }
                    Link(destination: URL(string: "http://nsp-app.ru/#terms")!) {
                        Label("Terms of Use", systemImage: "doc.text")
                    }
                    
                    Divider()
                    
                    let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
                    Button {
                        UIPasteboard.general.string = "App Version: \(version)"
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    } label: {
                        Label("Version: \(version)", systemImage: "tag")
                    }
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

// MARK: - Deprecated

extension ProfileView {
    @ViewBuilder private func makeRecommendationsSection() -> some View {
        MakeSection {
            MakeListRow(title: "Recommendations & Offers", subtitle: "Personalized offers for liked cars", icon: "heart.text.square", iconColor: .orange) {
                router.route(sheet: .offers)
            }
        }
    }
}

#Preview {
    // ProfileView(account: )
}
