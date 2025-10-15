import Foundation
import Compression

/// Data compression component using LZFSE algorithm
public struct CompressionComponent: DataComponent {
    public typealias Input = Data
    public typealias Output = Data
    
    public let identifier = "compression"
    
    public init() {}
    
    public func process(_ input: Data) async throws -> Data {
        return try compress(input)
    }
    
    private func compress(_ data: Data) throws -> Data {
        return try data.withUnsafeBytes { bytes in
            let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: data.count)
            defer { buffer.deallocate() }
            
            let compressedSize = compression_encode_buffer(
                buffer, data.count,
                bytes.bindMemory(to: UInt8.self).baseAddress!, data.count,
                nil, COMPRESSION_LZFSE
            )
            
            guard compressedSize > 0 else {
                throw CompressionError.compressionFailed
            }
            
            return Data(bytes: buffer, count: compressedSize)
        }
    }
}

public enum CompressionError: Error {
    case compressionFailed
    case decompressionFailed
}