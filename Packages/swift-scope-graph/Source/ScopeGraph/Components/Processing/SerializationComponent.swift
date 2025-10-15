import Foundation

/// Object serialization component
public struct SerializationComponent<T: Codable>: DataComponent {
    public typealias Input = T
    public typealias Output = Data
    
    public let identifier = "serialization"
    private let encoder: JSONEncoder
    
    public init() {
        self.encoder = JSONEncoder()
    }
    
    public func process(_ input: T) async throws -> Data {
        return try encoder.encode(input)
    }
}

/// Object deserialization component
public struct DeserializationComponent<T: Codable>: DataComponent {
    public typealias Input = Data
    public typealias Output = T
    
    public let identifier = "deserialization"
    private let decoder: JSONDecoder
    
    public init() {
        self.decoder = JSONDecoder()
    }
    
    public func process(_ input: Data) async throws -> T {
        return try decoder.decode(T.self, from: input)
    }
}