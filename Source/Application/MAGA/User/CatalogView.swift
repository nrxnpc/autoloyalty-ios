import SwiftUI

struct CatalogView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var selectedCategory: Product.ProductCategory?
    @State private var searchText = ""
    
    private var filteredProducts: [Product] {
        let products = dataManager.productsState.items
        
        let categoryFiltered = selectedCategory.map { category in
            products.filter { $0.category == category && $0.isActive }
        } ?? products.filter { $0.isActive }
        
        guard !searchText.isEmpty else { return categoryFiltered }
        
        return categoryFiltered.filter { product in
            product.name.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Поиск
                SearchBar(text: $searchText)
                    .padding()
                
                // Фильтр категорий
                CategoryFilter(selectedCategory: $selectedCategory)
                    .padding(.horizontal)
                
                // Сетка товаров с ленивой загрузкой
                ScrollView {
                    if dataManager.productsState.isLoading {
                        ProgressView("Загрузка товаров...")
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .padding()
                    } else if filteredProducts.isEmpty {
                        EmptyProductsView(searchText: searchText, selectedCategory: selectedCategory)
                    } else {
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                            ForEach(filteredProducts, id: \.id) { product in
                                NavigationLink(value: product) {
                                    ProductCard(product: product)
                                        .equatable(by: product.id)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding()
                    }
                }
                .navigationDestination(for: Product.self) { product in
                    ProductDetailView(product: product)
                }
            }
            .navigationTitle("Каталог")
        }
        .refreshable {
            await dataManager.loadDataType(.products)
        }
        .task {
            await dataManager.loadDataType(.products)
        }
    }
}

struct SearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            
            TextField("Поиск товаров", text: $text)
        }
        .padding()
        .background(Color.secondary.opacity(0.1))
        .cornerRadius(10)
    }
}

struct CategoryFilter: View {
    @Binding var selectedCategory: Product.ProductCategory?
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: AppConstants.Spacing.medium) {
                FilterButton(title: "Все", isSelected: selectedCategory == nil) {
                    selectedCategory = nil
                }
                
                ForEach(Product.ProductCategory.allCases, id: \.self) { category in
                    FilterButton(
                        title: category.displayName,
                        isSelected: selectedCategory == category
                    ) {
                        selectedCategory = category
                    }
                }
            }
            .padding(.horizontal)
        }
    }
}

struct FilterButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .padding(.horizontal, AppConstants.Spacing.medium)
                .padding(.vertical, AppConstants.Spacing.small)
                .background(isSelected ? AppConstants.Colors.primary : Color.secondary.opacity(0.2))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(20)
        }
    }
}

struct EmptyProductsView: View {
    let searchText: String
    let selectedCategory: Product.ProductCategory?
    
    var body: some View {
        VStack(spacing: AppConstants.Spacing.medium) {
            Image(systemName: "gift")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            if !searchText.isEmpty {
                Text("Ничего не найдено")
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                Text("Попробуйте изменить запрос или выбрать другую категорию")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            } else if selectedCategory != nil {
                Text("Нет товаров в категории")
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                Text("Попробуйте выбрать другую категорию")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            } else {
                Text("Каталог пуст")
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                Text("Товары появятся в ближайшее время")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
    }
}

struct ProductCard: View {
    let product: Product
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppConstants.Spacing.small) {
            // Изображение продукта
            ZStack {
                if let imageData = product.imageData, let image = UIImage(data: imageData) {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 120)
                        .clipped()
                } else {
                    ProductPlaceholderView(category: product.category)
                        .frame(height: 120)
                }
            }
            .cornerRadius(12)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(product.name)
                    .font(.headline)
                    .fontWeight(.medium)
                    .lineLimit(2)
                
                Text(product.category.displayName)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text("\(product.pointsCost) баллов")
                    .font(.subheadline)
                    .foregroundColor(AppConstants.Colors.primary)
                    .fontWeight(.medium)
                
                Text("Остаток: \(product.stockQuantity)")
                    .font(.caption)
                    .foregroundColor(product.stockQuantity > 5 ? .secondary : AppConstants.Colors.primary)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(radius: 4)
    }
}

struct ProductPlaceholderView: View {
    let category: Product.ProductCategory
    
    var body: some View {
        Rectangle()
            .fill(Color.secondary.opacity(0.3))
            .overlay(
                Image(systemName: category.iconName)
                    .font(.system(size: 40))
                    .foregroundColor(.secondary)
            )
    }
}

struct ProductDetailView: View {
    let product: Product
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var dataManager: DataManager
    @State private var selectedDeliveryOption: Product.DeliveryOption
    @State private var deliveryAddress = ""
    @State private var showingExchangeConfirmation = false
    @State private var showingSuccessAlert = false
    @State private var showingInsufficientPointsAlert = false
    
    init(product: Product) {
        self.product = product
        self._selectedDeliveryOption = State(initialValue: product.deliveryOptions.first ?? .pickup)
    }
    
    var canExchange: Bool {
        (authViewModel.currentUser?.points ?? 0) >= product.pointsCost && product.stockQuantity > 0
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppConstants.Spacing.large) {
                // Изображение продукта
                ProductImageView(product: product)
                
                ProductInfoSection(product: product)
                
                ProductDeliveryOptionsSection(
                    product: product,
                    selectedOption: $selectedDeliveryOption,
                    deliveryAddress: $deliveryAddress
                )
                
                Spacer(minLength: AppConstants.Spacing.large)
                
                // Кнопка обмена
                ExchangeButton(
                    product: product,
                    canExchange: canExchange,
                    action: {
                        if canExchange {
                            showingExchangeConfirmation = true
                        } else {
                            showingInsufficientPointsAlert = true
                        }
                    }
                )
            }
            .padding()
        }
        .navigationTitle(product.name)
        .navigationBarTitleDisplayMode(.inline)
        .alert("Подтверждение обмена", isPresented: $showingExchangeConfirmation) {
            Button("Отмена", role: .cancel) { }
            Button("Обменять") {
                exchangeProduct()
            }
        } message: {
            Text("Обменять \(product.pointsCost) баллов на \(product.name)?")
        }
        .alert("Недостаточно баллов", isPresented: $showingInsufficientPointsAlert) {
            Button("OK") { }
        } message: {
            let needed = product.pointsCost - (authViewModel.currentUser?.points ?? 0)
            Text("Вам не хватает \(needed) баллов для обмена на этот товар.")
        }
        .alert("Обмен успешен!", isPresented: $showingSuccessAlert) {
            Button("OK") { }
        } message: {
            Text("Вы успешно обменяли баллы на \(product.name). Заказ оформлен!")
        }
    }
    
    private func exchangeProduct() {
        guard let userId = authViewModel.currentUser?.id else { return }
        
        let order = dataManager.addOrder(
            userId: userId,
            product: product,
            deliveryOption: selectedDeliveryOption,
            deliveryAddress: selectedDeliveryOption == .delivery ? deliveryAddress : nil
        )
        
        if authViewModel.spendPoints(product.pointsCost) {
            dataManager.addPointTransaction(
                userId: userId,
                type: .spent,
                amount: product.pointsCost,
                description: "Обмен на \(product.name)",
                relatedId: order.id
            )
            
            // Уменьшаем количество товара
            var updatedProduct = product
            updatedProduct.stockQuantity -= 1
            dataManager.updateProduct(updatedProduct)
            
            showingSuccessAlert = true
        }
    }
}

struct ProductImageView: View {
    let product: Product
    
    var body: some View {
        if let imageData = product.imageData, let image = UIImage(data: imageData) {
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(height: 250)
                .clipped()
                .cornerRadius(16)
        } else {
            Rectangle()
                .fill(Color.secondary.opacity(0.3))
                .frame(height: 250)
                .cornerRadius(16)
                .overlay(
                    Image(systemName: product.category.iconName)
                        .font(.system(size: 80))
                        .foregroundColor(.secondary)
                )
        }
    }
}

struct ProductInfoSection: View {
    let product: Product
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppConstants.Spacing.medium) {
            // Название и категория
            Text(product.name)
                .font(.title2)
                .fontWeight(.bold)
            
            Text(product.category.displayName)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            // Стоимость
            HStack {
                Text("\(product.pointsCost)")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(AppConstants.Colors.primary)
                Text("баллов")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text("Остаток: \(product.stockQuantity)")
                    .font(.subheadline)
                    .foregroundColor(product.stockQuantity > 5 ? .secondary : AppConstants.Colors.primary)
            }
            
            // Описание
            Text("Описание")
                .font(.headline)
            
            Text(product.description)
                .font(.body)
                .lineSpacing(4)
        }
    }
}

struct ProductDeliveryOptionsSection: View {
    let product: Product
    @Binding var selectedOption: Product.DeliveryOption
    @Binding var deliveryAddress: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppConstants.Spacing.medium) {
            Text("Способы получения")
                .font(.headline)
            
            VStack(spacing: AppConstants.Spacing.medium) {
                ForEach(product.deliveryOptions, id: \.self) { option in
                    DeliveryOptionRow(
                        option: option,
                        isSelected: selectedOption == option
                    ) {
                        selectedOption = option
                    }
                }
            }
            
            // Адрес доставки (если выбрана доставка)
            if selectedOption == .delivery {
                VStack(alignment: .leading, spacing: AppConstants.Spacing.small) {
                    Text("Адрес доставки")
                        .font(.headline)
                    
                    TextField("Введите адрес доставки", text: $deliveryAddress)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
            }
        }
    }
}

struct DeliveryOptionRow: View {
    let option: Product.DeliveryOption
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(AppConstants.Colors.primary)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(option.displayName)
                        .font(.subheadline)
                        .foregroundColor(.primary)
                    
                    Text(deliveryOptionDescription(option))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            .padding()
            .background(isSelected ? AppConstants.Colors.primary.opacity(0.1) : Color.secondary.opacity(0.1))
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func deliveryOptionDescription(_ option: Product.DeliveryOption) -> String {
        switch option {
        case .pickup: return "Забрать в офисе или пункте выдачи"
        case .delivery: return "Доставка курьером по указанному адресу"
        case .digital: return "Мгновенная доставка на email"
        }
    }
}

struct ExchangeButton: View {
    let product: Product
    let canExchange: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(buttonText)
                .frame(maxWidth: .infinity)
                .padding()
                .background(buttonColor)
                .foregroundColor(.white)
                .cornerRadius(12)
        }
        .disabled(!canExchange && product.stockQuantity > 0)
    }
    
    private var buttonText: String {
        if product.stockQuantity == 0 {
            return "Нет в наличии"
        } else if canExchange {
            return "Обменять на \(product.pointsCost) баллов"
        } else {
            return "Недостаточно баллов"
        }
    }
    
    private var buttonColor: Color {
        if product.stockQuantity == 0 || !canExchange {
            return Color.secondary
        } else {
            return AppConstants.Colors.primary
        }
    }
}

#Preview {
    NavigationStack {
        CatalogView()
            .environmentObject(AuthViewModel())
            .environmentObject(DataManager())
    }
}
