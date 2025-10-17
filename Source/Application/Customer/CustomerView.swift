import SwiftUI
import SwiftUIComponents

struct CustomerView: View, ComponentBuilder {
    var body: some View {
        TabView {
            NavigationStack {
                ComingSoonView(title: "Главная", progress: 0.95)
            }
            .tabItem {
                Image(systemName: "house.fill")
                Text("Главная")
            }
            
            NavigationStack {
                ComingSoonView(title: "Сканер", progress: 0.82)
            }
            .tabItem {
                Image(systemName: "qrcode.viewfinder")
                Text("Сканер")
            }
            
            NavigationStack {
                ComingSoonView(title: "Авто", progress: 0.75)
            }
            .tabItem {
                Image(systemName: "car.fill")
                Text("Авто")
            }
            
            NavigationStack {
                ComingSoonView(title: "Каталог", progress: 0.85)
            }
            .tabItem {
                Image(systemName: "gift.fill")
                Text("Каталог")
            }
            
            NavigationStack {
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

struct ComingSoonView: View, ComponentBuilder {
    let title: String
    let progress: Double
    
    var body: some View {
        VStack(spacing: 32) {
            MakeEmptyState(
                icon: "clock",
                title: "Скоро будет готово",
                subtitle: "Мы работаем над этим разделом"
            )
            
            MakeCard {
                VStack(spacing: 16) {
                    MakeInfoRow(label: "Статус", value: "В разработке")
                    MakeInfoRow(label: "Прогресс", value: "\(progress * 100)%")
                    MakeProgressBar(progress: progress)
                }
            }
        }
        .padding()
        .navigationTitle(title)
    }
}
