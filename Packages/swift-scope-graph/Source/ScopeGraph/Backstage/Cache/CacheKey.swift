import Foundation
import CryptoKit

/// Secure cache key generator for file system safe storage identifiers
/// 
/// CacheKey provides stable, file system safe storage keys by generating
/// consistent UUID-formatted MD5 hashes from input strings or URLs.
/// This ensures compatibility across different file systems and prevents
/// naming conflicts.
/// 
/// Features:
/// - URL sanitization (removes www, trailing slashes, schemes)
/// - MD5 hashing for consistent key generation
/// - UUID formatting for readability
/// - File system safe output
@available(iOS 18.0, macOS 15.0, watchOS 11.0, tvOS 18.0, visionOS 2.0, *)
public struct CacheKey: Codable, Equatable, Hashable, Sendable {

    /// File system safe string representation of the cache key
    public let value: String

    /// Original input string before hashing (for internal use)
    internal let rawValue: String

    /// Initialize cache key from URL with automatic sanitization
    /// 
    /// URLs are sanitized to remove common variations (www, trailing slashes, schemes)
    /// before hashing to ensure consistent keys for equivalent URLs.
    /// 
    /// - Parameter url: URL to generate cache key from
    /// 
    /// Example:
    /// ```swift
    /// let key1 = CacheKey(url: URL(string: "https://example.com/")!)
    /// let key2 = CacheKey(url: URL(string: "http://www.example.com")!)
    /// // key1.value == key2.value (true)
    /// ```
    public init(url: URL) {
        self.rawValue = url.absoluteString

        let md5HashedURLString = Self.sanitizedURLString(url).md5
        self.value = md5HashedURLString.uuidFormatted ?? md5HashedURLString
    }

    /// Initialize cache key from string with MD5 hashing
    /// 
    /// Creates a file system safe cache key by hashing the input string
    /// and formatting as UUID when possible.
    /// 
    /// - Parameter value: String to generate cache key from
    /// 
    /// Example:
    /// ```swift
    /// let key = CacheKey("user_12345")
    /// // key.value = "A1B2C3D4-E5F6-7890-ABCD-EF1234567890"
    /// ```
    public init(_ value: String) {
        self.rawValue = value
        self.value = value.md5.uuidFormatted ?? value.md5
    }

    /// Initialize cache key with exact string value (no hashing)
    /// 
    /// Uses the input string directly as the cache key value.
    /// Only use when you're certain the string is file system safe.
    /// 
    /// - Parameter value: Exact string to use as cache key
    public init(verbatim value: String) {
        self.rawValue = value
        self.value = value
    }

}

private extension CacheKey {

    /// A function to remove common discrepancies that do not represent differences
    /// a user truly intended such as URLs with trailing slashes, www, etc.
    /// - Parameter url: The URL to normalize
    /// - Returns: A normalized string
    static func sanitizedURLString(_ url: URL) -> String {
        var urlComponents = URLComponents(string: url.absoluteString)

        // Remove the scheme because we don't want a user saving https://www.xyz.com to clash with www.xyz.com
        urlComponents?.scheme = nil

        guard let url = urlComponents?.url else { return url.absoluteString }

        var normalizedURLString = url.absoluteString

        if normalizedURLString.hasPrefix("//") {
            normalizedURLString = String(normalizedURLString.dropFirst("//".count))
        }

        if normalizedURLString.hasSuffix("/") {
            normalizedURLString = String(normalizedURLString.dropLast("/".count))
        }

        normalizedURLString = normalizedURLString
            .replacingOccurrences(of: "www.", with: "") // Remove www so a version with/without it don't collide

        return normalizedURLString
    }
}

// MARK: - String Formatting Extensions

@available(iOS 18.0, macOS 15.0, watchOS 11.0, tvOS 18.0, visionOS 2.0, *)
extension String {
    /// Generate MD5 hash of string
    var md5: String {
        Data(self.utf8).md5.hexString
    }

    /// Format 32-character hex string as UUID (8-4-4-4-12)
    /// - Returns: UUID formatted string or nil if input is not 32 characters
    var uuidFormatted: String? {
        guard self.count == 32 else { return nil }

        var string = self.uppercased()
        var index = string.index(string.startIndex, offsetBy: 8)
        for _ in 0..<4 {
            string.insert("-", at: index)
            index = string.index(index, offsetBy: 5)
        }

        return string
    }
}

@available(iOS 18.0, macOS 15.0, watchOS 11.0, tvOS 18.0, visionOS 2.0, *)
extension Data {
    /// Generate MD5 hash of data
    var md5: Data {
        Data(Insecure.MD5.hash(data: self))
    }
    
    /// Convert data to lowercase hex string
    var hexString: String {
        map {
            String(format: "%02x", $0)
        }.joined()
    }
}
