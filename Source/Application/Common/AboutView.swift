import SwiftUI

struct AboutView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: DesignSystem.Spacing.large) {
                // Логотип и название
                VStack(spacing: DesignSystem.Spacing.medium) {
                    Image(systemName: "car.fill")
                        .font(.system(size: 80))
                        .foregroundColor(DesignSystem.Colors.primary)
                    
                    Text("Автолояльность")
                        .font(DesignSystem.Typography.title1)
                        .fontWeight(.bold)
                    
                    Text("Версия 1.0.0")
                        .font(DesignSystem.Typography.callout)
                        .foregroundColor(DesignSystem.Colors.secondaryText)
                }
                
                // Описание
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.medium) {
                    Text("О приложении")
                        .font(DesignSystem.Typography.headline)
                        .fontWeight(.semibold)
                    
                    Text("Многопоставщическая платформа лояльности для автомобильной индустрии с системой создания контента участниками и модерацией.")
                        .font(DesignSystem.Typography.body)
                        .foregroundColor(DesignSystem.Colors.secondaryText)
                        .multilineTextAlignment(.leading)
                }
                
                // Возможности
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.medium) {
                    Text("Основные возможности")
                        .font(DesignSystem.Typography.headline)
                        .fontWeight(.semibold)
                    
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.small) {
                        FeatureRow(icon: "qrcode.viewfinder", text: "QR-сканирование для начисления баллов")
                        FeatureRow(icon: "gift.fill", text: "Обмен баллов на товары")
                        FeatureRow(icon: "car.fill", text: "Автотиндер для поиска автомобилей")
                        FeatureRow(icon: "star.fill", text: "Многоуровневая система лояльности")
                        FeatureRow(icon: "newspaper.fill", text: "Новости и акции")
                    }
                }
                
                // Контакты
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.medium) {
                    Text("Контакты")
                        .font(DesignSystem.Typography.headline)
                        .fontWeight(.semibold)
                    
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.small) {
                        ContactRow(icon: "person.fill", title: "Разработчик", value: "Александр Пестраков")
                        ContactRow(icon: "envelope.fill", title: "Email", value: "nrxnpc@yandex.ru")
                        ContactRow(icon: "message.fill", title: "Telegram", value: "@nrxnpc")
                    }
                }
                
                // Техническая информация
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.medium) {
                    Text("Техническая информация")
                        .font(DesignSystem.Typography.headline)
                        .fontWeight(.semibold)
                    
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.small) {
                        TechInfoRow(title: "Версия iOS", value: "17.0+")
                        TechInfoRow(title: "Swift", value: "5.9+")
                        TechInfoRow(title: "Архитектура", value: "MVVM + Service Layer")
                        TechInfoRow(title: "Лицензия", value: "MIT License")
                    }
                }
                
                Spacer(minLength: DesignSystem.Spacing.large)
                
                Text("© 2024 Автолояльность. Все права защищены.")
                    .font(DesignSystem.Typography.caption)
                    .foregroundColor(DesignSystem.Colors.tertiaryText)
                    .multilineTextAlignment(.center)
            }
            .padding(DesignSystem.Spacing.large)
        }
        .navigationTitle("О приложении")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct FeatureRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: DesignSystem.Spacing.medium) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(DesignSystem.Colors.primary)
                .frame(width: 20)
            
            Text(text)
                .font(DesignSystem.Typography.body)
                .foregroundColor(DesignSystem.Colors.text)
            
            Spacer()
        }
    }
}

struct ContactRow: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack(spacing: DesignSystem.Spacing.medium) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(DesignSystem.Colors.primary)
                .frame(width: 20)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(DesignSystem.Typography.caption)
                    .foregroundColor(DesignSystem.Colors.secondaryText)
                
                Text(value)
                    .font(DesignSystem.Typography.body)
                    .foregroundColor(DesignSystem.Colors.text)
            }
            
            Spacer()
        }
    }
}

struct TechInfoRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(DesignSystem.Typography.body)
                .foregroundColor(DesignSystem.Colors.text)
            
            Spacer()
            
            Text(value)
                .font(DesignSystem.Typography.body)
                .foregroundColor(DesignSystem.Colors.secondaryText)
        }
    }
}

#Preview {
    NavigationStack {
        AboutView()
    }
}