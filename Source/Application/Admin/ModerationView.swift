import SwiftUI

struct ModerationView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var selectedTab = 0
    
    var body: some View {
        VStack {
            Picker("Тип контента", selection: $selectedTab) {
                Text("Товары").tag(0)
                Text("Новости").tag(1)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            
            TabView(selection: $selectedTab) {
                ProductModerationView()
                    .tag(0)
                
                NewsModerationView()
                    .tag(1)
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
        }
        .navigationTitle("Модерация")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct ProductModerationView: View {
    @EnvironmentObject var dataManager: DataManager
    
    private var pendingProducts: [Product] {
        dataManager.productsState.items.filter { $0.status == .pending }
    }
    
    var body: some View {
        List {
            ForEach(pendingProducts) { product in
                ProductModerationRow(product: product)
            }
        }
        .refreshable {
            await dataManager.loadDataType(.products)
        }
    }
}

struct ProductModerationRow: View {
    let product: Product
    @EnvironmentObject var dataManager: DataManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                AsyncImageView(url: URL(string: product.imageURL))
                    .frame(width: 60, height: 60)
                    .cornerRadius(8)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(product.name)
                        .font(.headline)
                    
                    Text("\(product.pointsCost) баллов")
                        .font(.subheadline)
                        .foregroundColor(.blue)
                    
                    Text(product.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                Spacer()
            }
            
            HStack {
                Button("Отклонить") {
                    // Удаляем товар
                    dataManager.deleteProduct(product.id)
                }
                .foregroundColor(.red)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.red.opacity(0.1))
                .cornerRadius(8)
                
                Spacer()
                
                Button("Одобрить") {
                    var approvedProduct = product
                    approvedProduct.status = .approved
                    approvedProduct.isActive = true
                    dataManager.updateProduct(approvedProduct)
                }
                .foregroundColor(.green)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.green.opacity(0.1))
                .cornerRadius(8)
            }
        }
        .padding(.vertical, 8)
    }
}

struct NewsModerationView: View {
    @EnvironmentObject var dataManager: DataManager
    
    private var pendingNews: [NewsArticle] {
        dataManager.newsState.items.filter { $0.status == .pending }
    }
    
    var body: some View {
        List {
            ForEach(pendingNews) { article in
                NewsModerationRow(article: article)
            }
        }
        .refreshable {
            await dataManager.loadDataType(.news)
        }
    }
}

struct NewsModerationRow: View {
    let article: NewsArticle
    @EnvironmentObject var dataManager: DataManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                AsyncImageView(url: URL(string: article.imageURL))
                    .frame(width: 60, height: 60)
                    .cornerRadius(8)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(article.title)
                        .font(.headline)
                    
                    Text(article.content)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(3)
                }
                
                Spacer()
            }
            
            HStack {
                Button("Отклонить") {
                    // Удаляем новость
                    dataManager.deleteNews(article.id)
                }
                .foregroundColor(.red)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.red.opacity(0.1))
                .cornerRadius(8)
                
                Spacer()
                
                Button("Опубликовать") {
                    var publishedArticle = article
                    publishedArticle.status = .approved
                    publishedArticle.isPublished = true
                    publishedArticle.publishedAt = Date()
                    dataManager.updateNews(publishedArticle)
                }
                .foregroundColor(.green)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.green.opacity(0.1))
                .cornerRadius(8)
            }
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    NavigationStack {
        ModerationView()
            .environmentObject(DataManager())
    }
}