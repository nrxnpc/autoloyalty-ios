import Foundation

/// Base protocol for all data components
public protocol DataComponent {
    associatedtype Input
    associatedtype Output
    
    func process(_ input: Input) async throws -> Output
    var identifier: String { get }
}

/// Storage operations for storage components
public enum StorageOperation<Value> {
    case store(key: String, value: Value)
    case retrieve(key: String)
    case remove(key: String)
}

/// Storage operation results
public enum StorageResult<Value> {
    case success
    case value(Value?)
    case removed
}

/// Secure storage operations
public enum SecureOperation {
    case store(key: String, value: Data)
    case retrieve(key: String)
    case remove(key: String)
}

/// Secure operation results
public enum SecureResult {
    case success
    case data(Data?)
    case removed
}