import Foundation
import Combine
import SwiftUI

class SearchManager: ObservableObject {
    @Published var searchText = ""
    @Published var isSearching = false
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // Debounce поиска для лучшей производительности
        $searchText
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .sink { [weak self] _ in
                self?.isSearching = false
            }
            .store(in: &cancellables)
        
        $searchText
            .sink { [weak self] text in
                self?.isSearching = !text.isEmpty
            }
            .store(in: &cancellables)
    }
    
    func filterProducts(_ products: [Product]) -> [Product] {
        guard !searchText.isEmpty else { return products }
        
        return products.filter { product in
            product.name.localizedCaseInsensitiveContains(searchText) ||
            product.description.localizedCaseInsensitiveContains(searchText) ||
            product.category.displayName.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    func filterNews(_ articles: [NewsArticle]) -> [NewsArticle] {
        guard !searchText.isEmpty else { return articles }
        
        return articles.filter { article in
            article.title.localizedCaseInsensitiveContains(searchText) ||
            article.content.localizedCaseInsensitiveContains(searchText) ||
            article.tags.contains { $0.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    func filterCars(_ cars: [Car]) -> [Car] {
        guard !searchText.isEmpty else { return cars }
        
        return cars.filter { car in
            car.brand.localizedCaseInsensitiveContains(searchText) ||
            car.model.localizedCaseInsensitiveContains(searchText) ||
            car.description.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    func clearSearch() {
        searchText = ""
    }
}

// MARK: - Enhanced Search Bar
struct EnhancedSearchBar: View {
    @Binding var text: String
    let placeholder: String
    let onSearchButtonClicked: (() -> Void)?
    
    init(text: Binding<String>, placeholder: String = "Поиск...", onSearchButtonClicked: (() -> Void)? = nil) {
        self._text = text
        self.placeholder = placeholder
        self.onSearchButtonClicked = onSearchButtonClicked
    }
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            
            TextField(placeholder, text: $text)
                .textFieldStyle(PlainTextFieldStyle())
                .onSubmit {
                    onSearchButtonClicked?()
                }
            
            if !text.isEmpty {
                Button("Очистить") {
                    text = ""
                }
                .foregroundColor(.secondary)
                .font(.caption)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}

// MARK: - Filter Chips
struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? Color.blue : Color(.systemGray5))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(16)
        }
    }
}

struct FilterSection<T: CaseIterable & RawRepresentable>: View where T.RawValue == String, T: Hashable {
    let title: String
    let options: [T]
    @Binding var selectedOption: T?
    let displayName: (T) -> String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    FilterChip(title: "Все", isSelected: selectedOption == nil) {
                        selectedOption = nil
                    }
                    
                    ForEach(Array(options), id: \.self) { option in
                        FilterChip(
                            title: displayName(option),
                            isSelected: selectedOption == option
                        ) {
                            selectedOption = option
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}