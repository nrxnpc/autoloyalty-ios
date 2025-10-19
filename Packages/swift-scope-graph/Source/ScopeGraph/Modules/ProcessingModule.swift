import Foundation

/// Data processing components factory
public struct ProcessingModule {
    
    /// Creates data compression component
    public static func compression() -> CompressionComponent {
        return CompressionComponent()
    }
    
    /// Creates object serialization component
    public static func serialization<T: Codable>() -> SerializationComponent<T> {
        return SerializationComponent<T>()
    }
    
    /// Creates object deserialization component
    public static func deserialization<T: Codable>() -> DeserializationComponent<T> {
        return DeserializationComponent<T>()
    }
    
    /// Creates data encryption component
    public static func encryption(key: Data) -> EncryptionComponent {
        return EncryptionComponent(key: key)
    }
}

/// Data encryption component using XOR cipher
public struct EncryptionComponent: DataComponent {
    public typealias Input = Data
    public typealias Output = Data
    
    public let identifier = "encryption"
    private let key: Data
    
    public init(key: Data) {
        self.key = key
    }
    
    public func process(_ input: Data) async throws -> Data {
        return xorEncrypt(input, key: key)
    }
    
    private func xorEncrypt(_ data: Data, key: Data) -> Data {
        var result = Data()
        for (index, byte) in data.enumerated() {
            let keyByte = key[index % key.count]
            result.append(byte ^ keyByte)
        }
        return result
    }
}