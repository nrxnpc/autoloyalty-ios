import SwiftUI

// MARK: - Admin Products Management

struct AdminProductsView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var showingAddProduct = false
    @State private var selectedProduct: Product? = nil
    @State private var searchText = ""
    @State private var selectedCategory: Product.ProductCategory? = nil
    
    private var filteredProducts: [Product] {
        dataManager.productsState.items.filter { product in
            let matchesSearch = searchText.isEmpty ||
                product.name.localizedCaseInsensitiveContains(searchText)
            let matchesCategory = selectedCategory == nil || product.category == selectedCategory
            return matchesSearch && matchesCategory
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Поиск и фильтры
            VStack(spacing: AppConstants.Spacing.medium) {
                SearchBar(text: $searchText)
                
                CategoryFilter(selectedCategory: $selectedCategory)
            }
            .padding()
            
            Group {
                if dataManager.productsState.isLoading {
                    ProgressView("Загрузка товаров...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if filteredProducts.isEmpty {
                    EmptyProductsView(searchText: searchText, selectedCategory: selectedCategory)
                } else {
                    List {
                        ForEach(filteredProducts, id: \.id) { product in
                            AdminProductRow(product: product) {
                                selectedProduct = product
                            }
                        }
                        .onDelete(perform: deleteProducts)
                    }
                    .listStyle(PlainListStyle())
                }
            }
        }
        .navigationTitle("Товары (\(filteredProducts.count))")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Добавить") {
                    showingAddProduct = true
                }
                .foregroundColor(AppConstants.Colors.primary)
            }
        }
        .sheet(isPresented: $showingAddProduct) {
            AdminProductEditView(product: nil)
        }
        .sheet(item: $selectedProduct) { product in
            AdminProductEditView(product: product)
        }
        .task {
            await dataManager.loadDataType(.products)
        }
    }
    
    private func deleteProducts(at offsets: IndexSet) {
        for index in offsets {
            let product = filteredProducts[index]
            dataManager.deleteProduct(product.id)
        }
    }
}

struct AdminProductRow: View {
    let product: Product
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: AppConstants.Spacing.medium) {
                if let imageData = product.imageData, let image = UIImage(data: imageData) {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 50, height: 50)
                        .clipped()
                        .cornerRadius(8)
                } else {
                    Rectangle()
                        .fill(Color.secondary.opacity(0.3))
                        .frame(width: 50, height: 50)
                        .cornerRadius(8)
                        .overlay(
                            Image(systemName: product.category.iconName)
                                .foregroundColor(.secondary)
                        )
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(product.name)
                        .font(.headline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    
                    Text(product.category.displayName)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    HStack {
                        Text("\(product.pointsCost) баллов")
                            .font(.caption)
                            .foregroundColor(AppConstants.Colors.primary)
                            .fontWeight(.medium)
                        
                        Text("•")
                            .foregroundColor(.secondary)
                        
                        Text("Остаток: \(product.stockQuantity)")
                            .font(.caption)
                            .foregroundColor(product.stockQuantity > 5 ? .secondary : AppConstants.Colors.primary)
                        
                        Text("•")
                            .foregroundColor(.secondary)
                        
                        Text(product.isActive ? "Активен" : "Скрыт")
                            .font(.caption)
                            .foregroundColor(product.isActive ? .green : AppConstants.Colors.primary)
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
                    .font(.caption)
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct AdminProductEditView: View {
    let product: Product?
    @EnvironmentObject var dataManager: DataManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var name = ""
    @State private var category = Product.ProductCategory.merchandise
    @State private var pointsCost = ""
    @State private var description = ""
    @State private var stockQuantity = ""
    @State private var isActive = true
    @State private var selectedDeliveryOptions: Set<Product.DeliveryOption> = [.pickup]
    @State private var selectedImage: UIImage?
    @State private var showingImagePicker = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: AppConstants.Spacing.large) {
                    ImagePickerSection(
                        selectedImage: $selectedImage,
                        showingImagePicker: $showingImagePicker,
                        existingImageData: product?.imageData,
                        placeholder: "gift.fill"
                    )
                    
                    ProductBasicInfoSection(
                        name: $name,
                        category: $category,
                        pointsCost: $pointsCost,
                        stockQuantity: $stockQuantity,
                        description: $description
                    )
                    
                    DeliveryOptionsSection(
                        selectedOptions: $selectedDeliveryOptions
                    )
                    
                    Toggle("Активен", isOn: $isActive)
                        .tint(AppConstants.Colors.primary)
                    
                    Button(product == nil ? "Добавить товар" : "Сохранить изменения") {
                        saveProduct()
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(canSave ? AppConstants.Colors.primary : Color.secondary)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .disabled(!canSave)
                }
                .padding()
            }
            .navigationTitle(product == nil ? "Новый товар" : "Редактировать товар")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(selectedImage: $selectedImage)
            }
            .onAppear {
                if let product = product {
                    loadProductData(product)
                }
            }
        }
    }
    
    private var canSave: Bool {
        !name.isEmpty && !pointsCost.isEmpty && !stockQuantity.isEmpty && !selectedDeliveryOptions.isEmpty
    }
    
    private func loadProductData(_ product: Product) {
        name = product.name
        category = product.category
        pointsCost = String(product.pointsCost)
        description = product.description
        stockQuantity = String(product.stockQuantity)
        isActive = product.isActive
        selectedDeliveryOptions = Set(product.deliveryOptions)
    }
    
    private func saveProduct() {
        guard let points = Int(pointsCost), let stock = Int(stockQuantity) else { return }
        
        let imageData = selectedImage?.jpegData(compressionQuality: 0.8)
        
        if let existingProduct = product {
            let updatedProduct = Product(
                id: existingProduct.id,
                name: name,
                category: category,
                pointsCost: points,
                imageURL: existingProduct.imageURL,
                description: description,
                stockQuantity: stock,
                isActive: isActive,
                createdAt: existingProduct.createdAt,
                deliveryOptions: Array(selectedDeliveryOptions),
                imageData: imageData ?? existingProduct.imageData
            )
            dataManager.updateProduct(updatedProduct)
        } else {
            let newProduct = Product(
                id: UUID().uuidString,
                name: name,
                category: category,
                pointsCost: points,
                imageURL: "",
                description: description,
                stockQuantity: stock,
                isActive: isActive,
                createdAt: Date(),
                deliveryOptions: Array(selectedDeliveryOptions),
                imageData: imageData
            )
            dataManager.addProduct(newProduct)
        }
        
        dismiss()
    }
}

struct ProductBasicInfoSection: View {
    @Binding var name: String
    @Binding var category: Product.ProductCategory
    @Binding var pointsCost: String
    @Binding var stockQuantity: String
    @Binding var description: String
    
    var body: some View {
        VStack(spacing: AppConstants.Spacing.medium) {
            TextField("Название товара", text: $name)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            VStack(alignment: .leading, spacing: AppConstants.Spacing.small) {
                Text("Категория")
                    .font(.headline)
                
                Picker("Категория", selection: $category) {
                    ForEach(Product.ProductCategory.allCases, id: \.self) { cat in
                        Text(cat.displayName).tag(cat)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
            }
            
            TextField("Стоимость в баллах", text: $pointsCost)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.numberPad)
            
            TextField("Количество на складе", text: $stockQuantity)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.numberPad)
            
            VStack(alignment: .leading, spacing: AppConstants.Spacing.small) {
                Text("Описание")
                    .font(.headline)
                
                TextEditor(text: $description)
                    .frame(height: 100)
                    .padding(8)
                    .background(Color.secondary.opacity(0.1))
                    .cornerRadius(8)
            }
        }
    }
}

struct DeliveryOptionsSection: View {
    @Binding var selectedOptions: Set<Product.DeliveryOption>
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppConstants.Spacing.medium) {
            Text("Способы получения")
                .font(.headline)
            
            ForEach(Product.DeliveryOption.allCases, id: \.self) { option in
                HStack {
                    Button(action: {
                        if selectedOptions.contains(option) {
                            selectedOptions.remove(option)
                        } else {
                            selectedOptions.insert(option)
                        }
                    }) {
                        Image(systemName: selectedOptions.contains(option) ? "checkmark.square.fill" : "square")
                            .foregroundColor(AppConstants.Colors.primary)
                    }
                    
                    Text(option.displayName)
                        .font(.subheadline)
                    
                    Spacer()
                }
            }
        }
    }
}

// MARK: - Admin News Management

struct AdminNewsView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var showingAddNews = false
    @State private var selectedNews: NewsArticle? = nil
    @State private var searchText = ""
    
    private var filteredNews: [NewsArticle] {
        if searchText.isEmpty {
            return dataManager.newsState.items.sorted(by: { $0.createdAt > $1.createdAt })
        }
        return dataManager.newsState.items.filter { article in
            article.title.localizedCaseInsensitiveContains(searchText) ||
            article.content.localizedCaseInsensitiveContains(searchText)
        }.sorted(by: { $0.createdAt > $1.createdAt })
    }
    
    var body: some View {
        VStack(spacing: 0) {
            SearchBar(text: $searchText)
                .padding()
            
            Group {
                if dataManager.newsState.isLoading {
                    ProgressView("Загрузка новостей...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if filteredNews.isEmpty {
                    EmptyNewsView()
                } else {
                    List {
                        ForEach(filteredNews, id: \.id) { article in
                            AdminNewsRow(article: article) {
                                selectedNews = article
                            }
                        }
                        .onDelete(perform: deleteNews)
                    }
                    .listStyle(PlainListStyle())
                }
            }
        }
        .navigationTitle("Новости (\(filteredNews.count))")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Добавить") {
                    showingAddNews = true
                }
                .foregroundColor(AppConstants.Colors.primary)
            }
        }
        .sheet(isPresented: $showingAddNews) {
            AdminNewsEditView(article: nil)
        }
        .sheet(item: $selectedNews) { article in
            AdminNewsEditView(article: article)
        }
        .task {
            await dataManager.loadDataType(.news)
        }
    }
    
    private func deleteNews(at offsets: IndexSet) {
        for index in offsets {
            let article = filteredNews[index]
            dataManager.deleteNews(article.id)
        }
    }
}

struct AdminNewsRow: View {
    let article: NewsArticle
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: AppConstants.Spacing.medium) {
                if let imageData = article.imageData, let image = UIImage(data: imageData) {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 60, height: 60)
                        .clipped()
                        .cornerRadius(8)
                } else {
                    Rectangle()
                        .fill(Color.secondary.opacity(0.3))
                        .frame(width: 60, height: 60)
                        .cornerRadius(8)
                        .overlay(
                            Image(systemName: "newspaper")
                                .foregroundColor(.secondary)
                        )
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(article.title)
                            .font(.headline)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                            .lineLimit(1)
                        
                        if article.isImportant {
                            Text("ВАЖНО")
                                .font(.caption2)
                                .fontWeight(.bold)
                                .padding(.horizontal, 4)
                                .padding(.vertical, 2)
                                .background(AppConstants.Colors.primary)
                                .foregroundColor(.white)
                                .cornerRadius(4)
                        }
                    }
                    
                    Text(article.content)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                    
                    HStack {
                        Text(article.isPublished ? "Опубликована" : "Черновик")
                            .font(.caption)
                            .foregroundColor(article.isPublished ? .green : .orange)
                        
                        Text("•")
                            .foregroundColor(.secondary)
                        
                        Text(article.createdAt.formattedDate())
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
                    .font(.caption)
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct AdminNewsEditView: View {
    let article: NewsArticle?
    @EnvironmentObject var dataManager: DataManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var title = ""
    @State private var content = ""
    @State private var isImportant = false
    @State private var isPublished = false
    @State private var tags = ""
    @State private var selectedImage: UIImage?
    @State private var showingImagePicker = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: AppConstants.Spacing.large) {
                    ImagePickerSection(
                        selectedImage: $selectedImage,
                        showingImagePicker: $showingImagePicker,
                        existingImageData: article?.imageData,
                        placeholder: "newspaper"
                    )
                    
                    VStack(spacing: AppConstants.Spacing.medium) {
                        TextField("Заголовок новости", text: $title)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        TextField("Теги (через запятую)", text: $tags)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    
                    VStack(alignment: .leading, spacing: AppConstants.Spacing.small) {
                        Text("Содержание")
                            .font(.headline)
                        
                        TextEditor(text: $content)
                            .frame(height: 200)
                            .padding(8)
                            .background(Color.secondary.opacity(0.1))
                            .cornerRadius(8)
                    }
                    
                    VStack(spacing: AppConstants.Spacing.medium) {
                        Toggle("Важная новость", isOn: $isImportant)
                            .tint(AppConstants.Colors.primary)
                        
                        Toggle("Опубликовать сразу", isOn: $isPublished)
                            .tint(AppConstants.Colors.primary)
                    }
                    
                    Button(article == nil ? "Добавить новость" : "Сохранить изменения") {
                        saveNews()
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(canSave ? AppConstants.Colors.primary : Color.secondary)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .disabled(!canSave)
                }
                .padding()
            }
            .navigationTitle(article == nil ? "Новая новость" : "Редактировать")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(selectedImage: $selectedImage)
            }
            .onAppear {
                if let article = article {
                    loadNewsData(article)
                }
            }
        }
    }
    
    private var canSave: Bool {
        !title.isEmpty && !content.isEmpty
    }
    
    private func loadNewsData(_ article: NewsArticle) {
        title = article.title
        content = article.content
        isImportant = article.isImportant
        isPublished = article.isPublished
        tags = article.tags.joined(separator: ", ")
    }
    
    private func saveNews() {
        let imageData = selectedImage?.jpegData(compressionQuality: 0.8)
        let tagArray = tags.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
        
        if let existingArticle = article {
            let updatedArticle = NewsArticle(
                id: existingArticle.id,
                title: title,
                content: content,
                imageURL: existingArticle.imageURL,
                isImportant: isImportant,
                createdAt: existingArticle.createdAt,
                publishedAt: isPublished ? (existingArticle.publishedAt ?? Date()) : nil,
                isPublished: isPublished,
                authorId: existingArticle.authorId,
                tags: tagArray,
                imageData: imageData ?? existingArticle.imageData
            )
            dataManager.updateNews(updatedArticle)
        } else {
            let newArticle = NewsArticle(
                id: UUID().uuidString,
                title: title,
                content: content,
                imageURL: "",
                isImportant: isImportant,
                createdAt: Date(),
                publishedAt: isPublished ? Date() : nil,
                isPublished: isPublished,
                authorId: "admin-1",
                tags: tagArray,
                imageData: imageData
            )
            dataManager.addNews(newArticle)
        }
        
        dismiss()
    }
}

// MARK: - Admin Lotteries Management

struct AdminLotteriesView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var showingAddLottery = false
    @State private var selectedLottery: Lottery? = nil
    @State private var searchText = ""
    
    private var filteredLotteries: [Lottery] {
        if searchText.isEmpty {
            return dataManager.lotteriesState.items.sorted(by: { $0.createdAt > $1.createdAt })
        }
        return dataManager.lotteriesState.items.filter { lottery in
            lottery.title.localizedCaseInsensitiveContains(searchText) ||
            lottery.description.localizedCaseInsensitiveContains(searchText)
        }.sorted(by: { $0.createdAt > $1.createdAt })
    }
    
    var body: some View {
        VStack(spacing: 0) {
            SearchBar(text: $searchText)
                .padding()
            
            Group {
                if dataManager.lotteriesState.isLoading {
                    ProgressView("Загрузка лотерей...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if filteredLotteries.isEmpty {
                    EmptyLotteriesView()
                } else {
                    List {
                        ForEach(filteredLotteries, id: \.id) { lottery in
                            AdminLotteryRow(lottery: lottery) {
                                selectedLottery = lottery
                            }
                        }
                        .onDelete(perform: deleteLotteries)
                    }
                    .listStyle(PlainListStyle())
                }
            }
        }
        .navigationTitle("Лотереи (\(filteredLotteries.count))")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Добавить") {
                    showingAddLottery = true
                }
                .foregroundColor(AppConstants.Colors.primary)
            }
        }
        .sheet(isPresented: $showingAddLottery) {
            AdminLotteryEditView(lottery: nil)
        }
        .sheet(item: $selectedLottery) { lottery in
            AdminLotteryEditView(lottery: lottery)
        }
        .task {
            await dataManager.loadDataType(.lotteries)
        }
    }
    
    private func deleteLotteries(at offsets: IndexSet) {
        for index in offsets {
            let lottery = filteredLotteries[index]
            dataManager.deleteLottery(lottery.id)
        }
    }
}

struct AdminLotteryRow: View {
    let lottery: Lottery
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: AppConstants.Spacing.medium) {
                if let imageData = lottery.imageData, let image = UIImage(data: imageData) {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 60, height: 60)
                        .clipped()
                        .cornerRadius(8)
                } else {
                    Rectangle()
                        .fill(Color.secondary.opacity(0.3))
                        .frame(width: 60, height: 60)
                        .cornerRadius(8)
                        .overlay(
                            Image(systemName: "trophy.fill")
                                .foregroundColor(.secondary)
                        )
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(lottery.title)
                        .font(.headline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    
                    Text(lottery.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                    
                    HStack {
                        Text(lottery.isActive ? "Активна" : "Неактивна")
                            .font(.caption)
                            .foregroundColor(lottery.isActive ? .green : AppConstants.Colors.primary)
                        
                        Text("•")
                            .foregroundColor(.secondary)
                        
                        Text("Участников: \(lottery.participants.count)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text("•")
                            .foregroundColor(.secondary)
                        
                        Text(lottery.endDate > Date() ? "Активна" : "Завершена")
                            .font(.caption)
                            .foregroundColor(lottery.endDate > Date() ? .green : .secondary)
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
                    .font(.caption)
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct AdminLotteryEditView: View {
    let lottery: Lottery?
    @EnvironmentObject var dataManager: DataManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var title = ""
    @State private var description = ""
    @State private var prize = ""
    @State private var startDate = Date()
    @State private var endDate = Date().addingTimeInterval(86400 * 30) // 30 дней
    @State private var isActive = true
    @State private var minPointsRequired = ""
    @State private var selectedImage: UIImage?
    @State private var showingImagePicker = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: AppConstants.Spacing.large) {
                    ImagePickerSection(
                        selectedImage: $selectedImage,
                        showingImagePicker: $showingImagePicker,
                        existingImageData: lottery?.imageData,
                        placeholder: "trophy.fill"
                    )
                    
                    VStack(spacing: AppConstants.Spacing.medium) {
                        TextField("Название лотереи", text: $title)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        TextField("Описание приза", text: $prize)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        TextField("Минимум баллов для участия", text: $minPointsRequired)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.numberPad)
                    }
                    
                    VStack(alignment: .leading, spacing: AppConstants.Spacing.small) {
                        Text("Описание")
                            .font(.headline)
                        
                        TextEditor(text: $description)
                            .frame(height: 100)
                            .padding(8)
                            .background(Color.secondary.opacity(0.1))
                            .cornerRadius(8)
                    }
                    
                    VStack(alignment: .leading, spacing: AppConstants.Spacing.medium) {
                        Text("Даты проведения")
                            .font(.headline)
                        
                        VStack(spacing: AppConstants.Spacing.medium) {
                            DatePicker("Дата начала", selection: $startDate, displayedComponents: [.date, .hourAndMinute])
                            
                            DatePicker("Дата окончания", selection: $endDate, displayedComponents: [.date, .hourAndMinute])
                        }
                    }
                    
                    Toggle("Активная лотерея", isOn: $isActive)
                        .tint(AppConstants.Colors.primary)
                    
                    Button(lottery == nil ? "Создать лотерею" : "Сохранить изменения") {
                        saveLottery()
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(canSave ? AppConstants.Colors.primary : Color.secondary)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .disabled(!canSave)
                }
                .padding()
            }
            .navigationTitle(lottery == nil ? "Новая лотерея" : "Редактировать")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(selectedImage: $selectedImage)
            }
            .onAppear {
                if let lottery = lottery {
                    loadLotteryData(lottery)
                }
            }
        }
    }
    
    private var canSave: Bool {
        !title.isEmpty && !description.isEmpty && !prize.isEmpty && !minPointsRequired.isEmpty && endDate > startDate
    }
    
    private func loadLotteryData(_ lottery: Lottery) {
        title = lottery.title
        description = lottery.description
        prize = lottery.prize
        startDate = lottery.startDate
        endDate = lottery.endDate
        isActive = lottery.isActive
        minPointsRequired = String(lottery.minPointsRequired)
    }
    
    private func saveLottery() {
        guard let minPoints = Int(minPointsRequired) else { return }
        
        let imageData = selectedImage?.jpegData(compressionQuality: 0.8)
        
        if let existingLottery = lottery {
            let updatedLottery = Lottery(
                id: existingLottery.id,
                title: title,
                description: description,
                prize: prize,
                startDate: startDate,
                endDate: endDate,
                isActive: isActive,
                participants: existingLottery.participants,
                winnerId: existingLottery.winnerId,
                minPointsRequired: minPoints,
                createdAt: existingLottery.createdAt,
                imageData: imageData ?? existingLottery.imageData
            )
            dataManager.updateLottery(updatedLottery)
        } else {
            let newLottery = Lottery(
                id: UUID().uuidString,
                title: title,
                description: description,
                prize: prize,
                startDate: startDate,
                endDate: endDate,
                isActive: isActive,
                participants: [],
                winnerId: nil,
                minPointsRequired: minPoints,
                createdAt: Date(),
                imageData: imageData
            )
            dataManager.addLottery(newLottery)
        }
        
        dismiss()
    }
}

#Preview {
    NavigationStack {
        AdminProductsView()
            .environmentObject(DataManager())
    }
}
