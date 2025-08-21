import SwiftUI

struct NewsDetailView: View {
    let article: NewsArticle
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.large) {
                    // Изображение новости
                    if let imageData = article.imageData, let image = UIImage(data: imageData) {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 200)
                            .clipped()
                            .cornerRadius(DesignSystem.CornerRadius.medium)
                    }
                    
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.medium) {
                        // Заголовок
                        Text(article.title)
                            .font(DesignSystem.Typography.title2)
                            .fontWeight(.bold)
                            .foregroundColor(DesignSystem.Colors.text)
                        
                        // Дата и важность
                        HStack {
                            if article.isImportant {
                                HStack {
                                    Image(systemName: "exclamationmark.triangle.fill")
                                        .font(.system(size: 12))
                                        .foregroundColor(DesignSystem.Colors.error)
                                    
                                    Text("ВАЖНО")
                                        .font(DesignSystem.Typography.caption2)
                                        .fontWeight(.bold)
                                        .foregroundColor(DesignSystem.Colors.error)
                                }
                                .padding(.horizontal, DesignSystem.Spacing.small)
                                .padding(.vertical, DesignSystem.Spacing.xs)
                                .background(
                                    Capsule()
                                        .fill(DesignSystem.Colors.error.opacity(0.1))
                                )
                            }
                            
                            Spacer()
                            
                            Text(article.createdAt.formattedDate())
                                .font(DesignSystem.Typography.caption)
                                .foregroundColor(DesignSystem.Colors.secondaryText)
                        }
                        
                        // Контент
                        Text(article.content)
                            .font(DesignSystem.Typography.body)
                            .foregroundColor(DesignSystem.Colors.text)
                            .lineSpacing(4)
                        
                        // Хэштеги под контентом
                        if !article.tags.isEmpty {
                            LazyVGrid(columns: [
                                GridItem(.adaptive(minimum: 80), spacing: DesignSystem.Spacing.small)
                            ], spacing: DesignSystem.Spacing.small) {
                                ForEach(article.tags, id: \.self) { tag in
                                    Text("#\(tag)")
                                        .font(DesignSystem.Typography.caption)
                                        .foregroundColor(DesignSystem.Colors.primary)
                                        .padding(.horizontal, DesignSystem.Spacing.small)
                                        .padding(.vertical, DesignSystem.Spacing.xs)
                                        .background(
                                            Capsule()
                                                .fill(DesignSystem.Colors.primary.opacity(0.1))
                                        )
                                }
                            }
                        }
                    }
                    .padding(DesignSystem.Spacing.medium)
                }
            }
            .navigationTitle("Новость")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Готово") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    NewsDetailView(
        article: NewsArticle(
            id: "1",
            title: "Тестовая новость",
            content: "Это тестовая новость с длинным текстом для демонстрации",
            imageURL: "",
            isImportant: true,
            createdAt: Date(),
            publishedAt: Date(),
            isPublished: true,
            status: .approved,
            authorId: "1",
            tags: ["тест", "новости", "автозапчасти"],
            imageData: nil
        )
    )
}