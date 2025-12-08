import SwiftUI
import SwiftUIComponents

struct HomeView: View, ComponentBuilder {
    @EnvironmentObject var router: Main.Router
    @StateObject var inboxMonitor = InboxMonitor()
    
    @MainActor
    struct MAGA {
        let dataManager = DataManager()
        let viewModel = AuthViewModel()
    }
    let dependencies = MAGA()
    
    var body: some View {
        makeMockView()
            .toolbar(content: makeToolbar)
    }
}

extension HomeView {
    @ViewBuilder func makeHomeView() -> some View {
        ZStack {
            
        }
    }
    
    // Builds the toolbar items, including the dynamic "Save" button.
    @ToolbarContentBuilder func makeToolbar() -> some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Button {
                router.route(fullScreen: .scanner)
            } label: {
                Image(systemName: "qrcode.viewfinder")
            }
        }
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                router.route(to: .inbox)
            } label: {
                if inboxMonitor.unreadCount > 0 {
                    Image(systemName: "envelope.badge")
                        .foregroundStyle(.red, .primary)
                } else {
                    Image(systemName: "envelope")
                        .foregroundStyle(.primary)
                }
            }
        }
    }
    
    // MARK: - Mock Views
    
    @ViewBuilder func makeMockView() -> some View {
        TabView {
            NavigationView {
                MAGAHomeView()
            }
            .tabItem {
                Image(systemName: "house.fill")
                Text("Главная")
            }
            
            NavigationView {
                QRScannerMainView()
                
            }
            .tabItem {
                Image(systemName: "qrcode.viewfinder")
                Text("Сканер")
            }
            
            NavigationView {
                CarTinderView()
            }
            .tabItem {
                Image(systemName: "car.fill")
                Text("Авто")
            }
            
            NavigationView {
                AboutMeView()
            }
            .tabItem {
                Image(systemName: "person.fill")
                Text("Профиль")
            }
        }
        .environmentObject(dependencies.dataManager)
        .environmentObject(dependencies.viewModel)
        .accentColor(.blue)
    }
}
