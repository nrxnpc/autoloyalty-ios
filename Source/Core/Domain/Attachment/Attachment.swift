// File: Attachment.swift

import CoreData
import Foundation

/// Attachment domain entity with CoreData support
@objc(Attachment)
public class Attachment: Entity {
    @NSManaged public var sourceURL: URL?
    @NSManaged public var raw: Data?
    @NSManaged public var native: Data?
    @NSManaged public var sourceHash: Int
}

// MARK: - Hash Values

extension Attachment {
    public func calculateNativeHash() -> Int {
        var hasher = Hasher()
        hasher.combine(sourceURL)
        hasher.combine(native)
        return hasher.finalize()
    }
    
    public func calculateRawHash() -> Int {
        var hasher = Hasher()
        hasher.combine(sourceURL)
        hasher.combine(raw)
        return hasher.finalize()
    }
}
