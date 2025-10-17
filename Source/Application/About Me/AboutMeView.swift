import SwiftUI
import SwiftUIComponents

struct AboutMeView: View, ComponentBuilder {
    @EnvironmentObject var router: Main.Router
    @StateObject var application = AboutMe()
    
    var body: some View {
        ZStack {
            MakeCompactPage {
                makeProfileHeader()
                makeActivitySection()
                makeSupportSection()
                makeSettingsSection()
            } bottom: {
            }
        }
        .navigationTitle("Profile")
        .id(application.accountID)
    }
}

extension AboutMeView {
    @ViewBuilder
        private func makeProfileHeader() -> some View {
            MakeCard {
                HStack(spacing: 16) {
                    AccountImage(accountID: application.accountID)
                        .frame(width: 60, height: 60)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        MakeTitle(LocalizedStringKey(application.username))
                        MakeSubtitle(LocalizedStringKey(application.email))
                        MakePointsBadge(points: Int(application.points))
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        
        @ViewBuilder
        private func makeActivitySection() -> some View {
            MakeSection(title: "Активность") {
                VStack(spacing: 8) {
                    MakeListRow(title: "История сканирований", subtitle: "Ваши QR-коды", icon: "qrcode") { }
                    MakeListRow(title: "Мои заказы", subtitle: "Обмены баллов", icon: "bag") { }
                    MakeListRow(title: "История баллов", subtitle: "Начисления и списания", icon: "creditcard") { }
                    MakeListRow(title: "Понравившиеся авто", subtitle: "Избранные автомобили", icon: "heart") { }
                    MakeListRow(title: "Запросы цены", subtitle: "Заявки дилерам", icon: "questionmark.circle") { }
                }
            }
        }
        
        @ViewBuilder
        private func makeSupportSection() -> some View {
            MakeSection(title: "Поддержка") {
                VStack(spacing: 8) {
                    MakeListRow(title: "Чат с поддержкой", subtitle: "Онлайн помощь", icon: "message") { }
                    MakeListRow(title: "Мои обращения", subtitle: "История тикетов", icon: "folder") { }
                    MakeListRow(title: "Часто задаваемые вопросы", subtitle: "База знаний", icon: "questionmark.circle") { }
                }
            }
        }
        
        @ViewBuilder
        private func makeSettingsSection() -> some View {
            MakeSection(title: "Настройки") {
                VStack(spacing: 8) {
                    MakeListRow(title: "Настройки приложения", subtitle: "Уведомления, безопасность", icon: "gear") { }
                    MakeListRow(title: "О приложении", subtitle: "Версия и контакты", icon: "info.circle") { }
                }
            }
        }
}

#Preview {
    AboutMeView()
}
