import SwiftUI
import SwiftUIComponents

struct CustomerView: View, ComponentBuilder {
    var body: some View {
        TabView {
            NavigationView {
                MakeUnderConstructionBarrier(title: "Coming soon...", reason: "This tab is currently under construction.")
            }
            .tabItem {
                Image(systemName: "house.fill")
                Text("Главная")
            }
            
            NavigationView {
                MakeUnderConstructionBarrier(title: "Coming soon...", reason: "This tab is currently under construction.")
            }
            .tabItem {
                Image(systemName: "qrcode.viewfinder")
                Text("Сканер")
            }
            
            NavigationView {
                MakeUnderConstructionBarrier(title: "Coming soon...", reason: "This tab is currently under construction.")
            }
            .tabItem {
                Image(systemName: "car.fill")
                Text("Авто")
            }
            
            NavigationView {
                MakeUnderConstructionBarrier(title: "Coming soon...", reason: "This tab is currently under construction.")
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
        .accentColor(.blue)
    }
}
