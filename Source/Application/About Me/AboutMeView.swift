import SwiftUI
import SwiftUIComponents

struct AboutMeView: View, ComponentBuilder {
    @EnvironmentObject var router: Main.Router
    @StateObject var application = AboutMe()
    
    /// To show accout image on navigation title
    @State private var isProfileHeaderVisible: Bool = true
    
    var body: some View {
        MakeList {
            makeAboutSection()
            makeActivitySection()
            makeSupportSection()
            makeSettingsSection()
        }
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.large)
        // TODO: fix it
        // .toolbar(content: makeToolbar)
        .id(application.accountID)
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
                    MakePointsBadge(points: Int(application.points))
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .onTapGesture {
            router.route(sheet: .changeAboutMe(application))
        }
        .trigger(visible: $isProfileHeaderVisible)
    }
    
    @ViewBuilder private func makeActivitySection() -> some View {
        MakeSection(title: "Активность") {
            VStack(spacing: 8) {
                MakeListRow(title: "История сканирований", subtitle: "Ваши QR-коды", icon: "qrcode", iconColor: .init(hex: 0x007AFF)) {
                    
                }
                MakeListRow(title: "Мои заказы", subtitle: "Обмены баллов", icon: "bag", iconColor: .init(hex: 0x34C759)) { }
                MakeListRow(title: "История баллов", subtitle: "Начисления и списания", icon: "creditcard", iconColor: .init(hex: 0xFF9500)) { }
                MakeListRow(title: "Понравившиеся авто", subtitle: "Избранные автомобили", icon: "heart", iconColor: .init(hex: 0xFF3B30)) { }
                MakeListRow(title: "Запросы цены", subtitle: "Заявки дилерам", icon: "questionmark.circle", iconColor: .init(hex: 0x5856D6)) { }
            }
        }
    }
    
    @ViewBuilder private func makeSupportSection() -> some View {
        MakeSection(title: "Поддержка") {
            VStack(spacing: 8) {
                MakeListRow(title: "Чат с поддержкой", subtitle: "Онлайн помощь", icon: "message", iconColor: .init(hex: 0x00C7BE)) { }
                MakeListRow(title: "Мои обращения", subtitle: "История тикетов", icon: "folder", iconColor: .init(hex: 0x8E8E93)) { }
                MakeListRow(title: "Часто задаваемые вопросы", subtitle: "База знаний", icon: "questionmark.circle", iconColor: .init(hex: 0x5AC8FA)) { }
            }
        }
    }
    
    @ViewBuilder private func makeSettingsSection() -> some View {
        MakeSection(title: "Настройки") {
            VStack(spacing: 8) {
                MakeListRow(title: "Настройки приложения", subtitle: "Уведомления, безопасность", icon: "gear", iconColor: .init(hex: 0x636366)) { }
                MakeListRow(title: "О приложении", subtitle: "Версия и контакты", icon: "info.circle", iconColor: .init(hex: 0x48484A)) { }
            }
        }
    }
    
    /// Builds the toolbar items, including the dynamic "Save" button.
    @ToolbarContentBuilder func makeToolbar() -> some ToolbarContent {
        ToolbarItem(placement: .principal) {
            HStack(alignment: .center, spacing: 8) {
                AccountImage(accountID: application.accountID)
                    .frame(width: 24, height: 24)
                    .opacity(isProfileHeaderVisible ? 0.0 : 1.0)
                
                Text("Profile")
                    .font(.headline)
                
                Spacer()
                    .frame(width: isProfileHeaderVisible ? 32 : 0.0)
            }
            .animation(.smooth, value: isProfileHeaderVisible)
        }
    }
}

#Preview {
    AboutMeView()
}
