import Foundation
import Combine

@MainActor
class CollectionState<T: Identifiable & Equatable & Hashable>: ObservableObject {
    @Published private(set) var items: [T] = []
    @Published private(set) var isLoading = false
    @Published private(set) var error: Error?
    
    private var loadingTask: Task<Void, Never>?
    
    func loadItems(_ loader: @escaping () async throws -> [T]) {
        loadingTask?.cancel()
        loadingTask = Task {
            isLoading = true
            error = nil
            
            defer { isLoading = false }
            
            do {
                let newItems = try await loader()
                if !Task.isCancelled {
                    items = newItems
                }
            } catch {
                if !Task.isCancelled {
                    self.error = error
                }
            }
        }
    }
    
    func setItems(_ newItems: [T]) {
        items = newItems
        error = nil
    }
    
    func addItem(_ item: T) {
        // Проверяем, что элемент еще не существует
        if !items.contains(where: { $0.id == item.id }) {
            items.append(item)
        }
    }
    
    func addItems(_ newItems: [T]) {
        for item in newItems {
            addItem(item)
        }
    }
    
    func updateItem(_ item: T) {
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            items[index] = item
        } else {
            // Если элемент не найден, добавляем его
            addItem(item)
        }
    }
    
    func removeItem(withId id: T.ID) {
        items.removeAll { $0.id == id }
    }
    
    func removeItems(withIds ids: [T.ID]) {
        items.removeAll { ids.contains($0.id) }
    }
    
    func clearItems() {
        items.removeAll()
        error = nil
    }
    
    func refresh(_ loader: @escaping () async throws -> [T]) {
        loadItems(loader)
    }
    
    // MARK: - Convenient getters
    var isEmpty: Bool {
        return items.isEmpty
    }
    
    var count: Int {
        return items.count
    }
    
    func item(withId id: T.ID) -> T? {
        return items.first { $0.id == id }
    }
    
    func contains(itemWithId id: T.ID) -> Bool {
        return items.contains { $0.id == id }
    }
    
    // MARK: - Filtering and sorting
    func filteredItems(where predicate: (T) -> Bool) -> [T] {
        return items.filter(predicate)
    }
    
    func sortedItems(by areInIncreasingOrder: (T, T) -> Bool) -> [T] {
        return items.sorted(by: areInIncreasingOrder)
    }
    
    // MARK: - Batch operations
    func updateItems(_ updatedItems: [T]) {
        for item in updatedItems {
            updateItem(item)
        }
    }
    
    func replaceItems(_ newItems: [T]) {
        items = newItems
        error = nil
    }
    
    // MARK: - Error handling
    func clearError() {
        error = nil
    }
    
    func setError(_ newError: Error) {
        error = newError
    }
    
    var hasError: Bool {
        return error != nil
    }
    
    // MARK: - Loading state
    var isNotLoading: Bool {
        return !isLoading
    }
    
    func setLoading(_ loading: Bool) {
        isLoading = loading
    }
    
    deinit {
        loadingTask?.cancel()
    }
}

// MARK: - Convenient extensions
extension CollectionState where T: Comparable {
    var sortedItems: [T] {
        return items.sorted()
    }
}

extension CollectionState {
    func asyncMap<U>(_ transform: @escaping (T) async throws -> U) async rethrows -> [U] {
        var result: [U] = []
        for item in items {
            let transformed = try await transform(item)
            result.append(transformed)
        }
        return result
    }
}

// MARK: - Reactive extensions
extension CollectionState {
    var itemsPublisher: Published<[T]>.Publisher {
        return $items
    }
    
    var isLoadingPublisher: Published<Bool>.Publisher {
        return $isLoading
    }
    
    var errorPublisher: Published<Error?>.Publisher {
        return $error
    }
}
