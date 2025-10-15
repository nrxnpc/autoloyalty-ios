import Foundation

/// Base protocol for all data components
/// 
/// Data components are the building blocks of the ScopeGraph pipeline.
/// Each component processes input data and produces output in a type-safe manner.
@available(iOS 18.0, macOS 15.0, watchOS 11.0, tvOS 18.0, visionOS 2.0, *)
public protocol DataComponent: Sendable {
    associatedtype Input: Sendable
    associatedtype Output: Sendable
    
    /// Process input data and return output
    /// - Parameter input: Input data to process
    /// - Returns: Processed output data
    /// - Throws: Processing errors
    func process(_ input: Input) async throws -> Output
    
    /// Unique identifier for this component
    var identifier: String { get }
}

/// Storage operations for storage components
/// 
/// Defines the types of operations that can be performed on storage components.
@available(iOS 18.0, macOS 15.0, watchOS 11.0, tvOS 18.0, visionOS 2.0, *)
public enum StorageOperation<Value: Sendable>: Sendable {
    case store(key: String, value: Value)
    case retrieve(key: String)
    case remove(key: String)
}

/// Storage operation results
/// 
/// Represents the result of a storage operation.
@available(iOS 18.0, macOS 15.0, watchOS 11.0, tvOS 18.0, visionOS 2.0, *)
public enum StorageResult<Value: Sendable>: Sendable {
    case success
    case value(Value?)
    case removed
}

/// Secure storage operations for keychain and encrypted storage
/// 
/// Defines operations for secure data storage using keychain or encryption.
@available(iOS 18.0, macOS 15.0, watchOS 11.0, tvOS 18.0, visionOS 2.0, *)
public enum SecureOperation: Sendable {
    case store(key: String, value: Data)
    case retrieve(key: String)
    case remove(key: String)
}

/// Secure operation results
/// 
/// Represents the result of a secure storage operation.
@available(iOS 18.0, macOS 15.0, watchOS 11.0, tvOS 18.0, visionOS 2.0, *)
public enum SecureResult: Sendable {
    case success
    case data(Data?)
    case removed
}