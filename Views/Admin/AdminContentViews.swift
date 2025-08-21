import SwiftUI

// MARK: - Products Management
struct AdminProductsView: View {
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var showingAddProduct = false
    
    private var isSupplier: Bool {
        authViewModel.currentUser?.role == .supplier
    }
    
    private var products: [Product] {
        if isSupplier {
            return dataManager.productsState.items.filter { $0.supplierId == authViewModel.currentUser?.id }
        } else {
            return dataManager.productsState.items
        }
    }
    
    var body: some View {
        List {
            ForEach(products, id: \.id) { product in
                NavigationLink(destination: AdminProductEditView(product: product)) {
                    ProductAdminRow(product: product)
                }
            }
        }
        .navigationTitle("Товары")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Добавить") {
                    showingAddProduct = true
                }
            }
        }
        .sheet(isPresented: $showingAddProduct) {
            AdminProductEditView(product: nil)
        }
        .task {
            await dataManager.loadDataType(.products)
        }
    }
}

struct ProductAdminRow: View {
    let product: Product
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(product.name)
                    .font(.headline)
                
                Text("\(product.pointsCost) баллов")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text("Остаток: \(product.stockQuantity)")
                    .font(.caption)
                    .foregroundColor(product.stockQuantity > 0 ? .green : .red)
            }
            
            Spacer()
            
            VStack(alignment: .trailing) {
                Text(product.status.displayName)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(product.status.color.opacity(0.2))
                    .foregroundColor(product.status.color)
                    .cornerRadius(8)
                
                if product.isActive {
                    Text("Активен")
                        .font(.caption)
                        .foregroundColor(.green)
                } else {
                    Text("Неактивен")
                        .font(.caption)
                        .foregroundColor(.red)
                }
            }
        }
    }
}

struct AdminProductEditView: View {
    let product: Product?
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var name = ""
    @State private var description = ""
    @State private var pointsCost = 100
    @State private var stockQuantity = 10
    @State private var category = Product.ProductCategory.merchandise
    @State private var isActive = true
    @State private var deliveryOptions: Set<Product.DeliveryOption> = [.pickup]
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Основная информация") {
                    TextField("Название товара", text: $name)
                    TextField("Описание", text: $description, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                Section("Параметры") {
                    Picker("Категория", selection: $category) {
                        ForEach(Product.ProductCategory.allCases, id: \.self) { cat in
                            Text(cat.displayName).tag(cat)
                        }
                    }
                    
                    Stepper("Стоимость: \(pointsCost) баллов", value: $pointsCost, in: 1...10000, step: 10)
                    Stepper("Количество: \(stockQuantity)", value: $stockQuantity, in: 0...1000)
                    
                    Toggle("Активен", isOn: $isActive)
                }
                
                Section("Доставка") {
                    ForEach(Product.DeliveryOption.allCases, id: \.self) { option in
                        Toggle(option.displayName, isOn: Binding(
                            get: { deliveryOptions.contains(option) },
                            set: { isSelected in
                                if isSelected {
                                    deliveryOptions.insert(option)
                                } else {
                                    deliveryOptions.remove(option)
                                }
                            }
                        ))
                    }
                }
            }
            .navigationTitle(product == nil ? "Новый товар" : "Редактировать")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Сохранить") { saveProduct() }
                        .disabled(name.isEmpty)
                }
            }
        }
        .onAppear {
            if let product = product {
                name = product.name
                description = product.description
                pointsCost = product.pointsCost
                stockQuantity = product.stockQuantity
                category = product.category
                isActive = product.isActive
                deliveryOptions = Set(product.deliveryOptions)
            }
        }
    }
    
    private func saveProduct() {
        let newProduct = Product(
            id: product?.id ?? UUID().uuidString,
            name: name,
            category: category,
            pointsCost: pointsCost,
            imageURL: product?.imageURL ?? "",
            description: description,
            stockQuantity: stockQuantity,
            isActive: isActive,
            status: authViewModel.currentUser?.role == .supplier ? .pending : .approved,
            createdAt: product?.createdAt ?? Date(),
            deliveryOptions: Array(deliveryOptions),
            imageData: product?.imageData,
            supplierId: authViewModel.currentUser?.id
        )
        
        if product == nil {
            dataManager.addProduct(newProduct)
        } else {
            dataManager.updateProduct(newProduct)
        }
        
        dismiss()
    }
}

// MARK: - News Management
struct AdminNewsView: View {
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var showingAddNews = false
    
    private var isSupplier: Bool {
        authViewModel.currentUser?.role == .supplier
    }
    
    private var news: [NewsArticle] {
        if isSupplier {
            return dataManager.newsState.items.filter { $0.authorId == authViewModel.currentUser?.id }
        } else {
            return dataManager.newsState.items
        }
    }
    
    var body: some View {
        List {
            ForEach(news.sorted { $0.createdAt > $1.createdAt }, id: \.id) { article in
                NavigationLink(destination: AdminNewsEditView(article: article)) {
                    NewsAdminRow(article: article)
                }
            }
        }
        .navigationTitle("Новости")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Добавить") {
                    showingAddNews = true
                }
            }
        }
        .sheet(isPresented: $showingAddNews) {
            AdminNewsEditView(article: nil)
        }
        .task {
            await dataManager.loadDataType(.news)
        }
    }
}

struct NewsAdminRow: View {
    let article: NewsArticle
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(article.title)
                    .font(.headline)
                    .lineLimit(2)
                
                Text(article.content)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                
                Text(article.createdAt.formattedDate())
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(article.status.displayName)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(article.status.color.opacity(0.2))
                    .foregroundColor(article.status.color)
                    .cornerRadius(8)
                
                if article.isImportant {
                    Text("ВАЖНО")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundColor(.red)
                }
            }
        }
    }
}

struct AdminNewsEditView: View {
    let article: NewsArticle?
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var title = ""
    @State private var content = ""
    @State private var isImportant = false
    @State private var tags = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Основная информация") {
                    TextField("Заголовок", text: $title)
                    TextField("Содержание", text: $content, axis: .vertical)
                        .lineLimit(5...10)
                }
                
                Section("Настройки") {
                    Toggle("Важная новость", isOn: $isImportant)
                    TextField("Теги (через запятую)", text: $tags)
                }
            }
            .navigationTitle(article == nil ? "Новая новость" : "Редактировать")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Сохранить") { saveNews() }
                        .disabled(title.isEmpty || content.isEmpty)
                }
            }
        }
        .onAppear {
            if let article = article {
                title = article.title
                content = article.content
                isImportant = article.isImportant
                tags = article.tags.joined(separator: ", ")
            }
        }
    }
    
    private func saveNews() {
        let tagArray = tags.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty }
        
        let newArticle = NewsArticle(
            id: article?.id ?? UUID().uuidString,
            title: title,
            content: content,
            imageURL: article?.imageURL ?? "",
            isImportant: isImportant,
            createdAt: article?.createdAt ?? Date(),
            publishedAt: nil,
            isPublished: false,
            status: authViewModel.currentUser?.role == .supplier ? .pending : .approved,
            authorId: authViewModel.currentUser?.id ?? "",
            tags: tagArray,
            imageData: article?.imageData
        )
        
        if article == nil {
            dataManager.addNews(newArticle)
        } else {
            dataManager.updateNews(newArticle)
        }
        
        dismiss()
    }
}

// MARK: - Lotteries Management
struct AdminLotteriesView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var showingAddLottery = false
    
    var body: some View {
        List {
            ForEach(dataManager.lotteriesState.items.sorted { $0.createdAt > $1.createdAt }, id: \.id) { lottery in
                NavigationLink(destination: AdminLotteryEditView(lottery: lottery)) {
                    LotteryAdminRow(lottery: lottery)
                }
            }
        }
        .navigationTitle("Лотереи")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Добавить") {
                    showingAddLottery = true
                }
            }
        }
        .sheet(isPresented: $showingAddLottery) {
            AdminLotteryEditView(lottery: nil)
        }
        .task {
            await dataManager.loadDataType(.lotteries)
        }
    }
}

struct LotteryAdminRow: View {
    let lottery: Lottery
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(lottery.title)
                    .font(.headline)
                
                Text(lottery.prize)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text("Участников: \(lottery.participants.count)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(lottery.isActive ? "Активна" : "Завершена")
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(lottery.isActive ? Color.green.opacity(0.2) : Color.gray.opacity(0.2))
                    .foregroundColor(lottery.isActive ? .green : .gray)
                    .cornerRadius(8)
                
                Text("До \(lottery.endDate.formattedDate())")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}

struct AdminLotteryEditView: View {
    let lottery: Lottery?
    @EnvironmentObject var dataManager: DataManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var title = ""
    @State private var description = ""
    @State private var prize = ""
    @State private var minPointsRequired = 100
    @State private var endDate = Date().addingTimeInterval(7 * 24 * 60 * 60) // 7 дней
    @State private var isActive = true
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Основная информация") {
                    TextField("Название лотереи", text: $title)
                    TextField("Описание", text: $description, axis: .vertical)
                        .lineLimit(3...6)
                    TextField("Приз", text: $prize)
                }
                
                Section("Параметры") {
                    Stepper("Минимум баллов: \(minPointsRequired)", value: $minPointsRequired, in: 1...10000, step: 10)
                    DatePicker("Дата окончания", selection: $endDate, displayedComponents: [.date, .hourAndMinute])
                    Toggle("Активна", isOn: $isActive)
                }
            }
            .navigationTitle(lottery == nil ? "Новая лотерея" : "Редактировать")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Сохранить") { saveLottery() }
                        .disabled(title.isEmpty || prize.isEmpty)
                }
            }
        }
        .onAppear {
            if let lottery = lottery {
                title = lottery.title
                description = lottery.description
                prize = lottery.prize
                minPointsRequired = lottery.minPointsRequired
                endDate = lottery.endDate
                isActive = lottery.isActive
            }
        }
    }
    
    private func saveLottery() {
        let newLottery = Lottery(
            id: lottery?.id ?? UUID().uuidString,
            title: title,
            description: description,
            prize: prize,
            startDate: lottery?.startDate ?? Date(),
            endDate: endDate,
            isActive: isActive,
            participants: lottery?.participants ?? [],
            winnerId: lottery?.winnerId,
            minPointsRequired: minPointsRequired,
            createdAt: lottery?.createdAt ?? Date(),
            imageData: lottery?.imageData
        )
        
        if lottery == nil {
            dataManager.addLottery(newLottery)
        } else {
            dataManager.updateLottery(newLottery)
        }
        
        dismiss()
    }
}



#Preview {
    NavigationStack {
        AdminProductsView()
            .environmentObject(DataManager())
            .environmentObject(AuthViewModel())
    }
}