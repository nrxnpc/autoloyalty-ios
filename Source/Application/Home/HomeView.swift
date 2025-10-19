import SwiftUI
import SwiftUIComponents

struct HomeView: View, ComponentBuilder {
    @MainActor
    struct MAGA {
        let dataManager = DataManager()
        let viewModel = AuthViewModel()
    }
    let dependencies = MAGA()
    
    var body: some View {
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
                CatalogView()
            }
            .tabItem {
                Image(systemName: "gift.fill")
                Text("Каталог")
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
