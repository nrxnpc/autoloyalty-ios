// File: Attachment+UseCase.swift

import CoreData
import Foundation
import ScopeGraph

// MARK: - Create Attachment

public extension Attachment {
    /// Create attachment from raw data (sourceURL empty, unique Entity ID)
    static func fromData(raw: Data, in context: NSManagedObjectContext) -> Attachment {
        let attachment = Attachment(context: context)
        attachment.raw = raw
        return attachment
    }
    
    /// Create attachment from raw data (sourceURL empty, unique Entity ID)
    static func fromData(native: Data, in context: NSManagedObjectContext) -> Attachment {
        let attachment = Attachment(context: context)
        attachment.native = native
        return attachment
    }
    
    static func fromData(raw: Data, native: Data, in context: NSManagedObjectContext) -> Attachment {
        let attachment = Attachment(context: context)
        attachment.raw = raw
        attachment.native = native
        return attachment
    }
    
    /// Create attachment from source URL (data is nil, ID from CacheKey)
    static func fromURL(_ url: URL, in context: NSManagedObjectContext) -> Attachment {
        let attachment = Attachment(context: context)
        attachment.id = CacheKey(url: url).value
        attachment.sourceURL = url
        return attachment
    }
    
    static func createEmpty(in context: NSManagedObjectContext) -> Attachment {
        let attachment = Attachment(context: context)
        return attachment
    }
}

// MARK: - Update Attachment

public extension Attachment {
    /// Update with downloaded raw data
    func setRawData(_ data: Data) {
        raw = data
        sourceHash = calculateRawHash()
    }
    
    /// Update with optimized native data
    func setNativeData(_ data: Data) {
        native = data
    }
}

// MARK: - Optimize Attachment

public extension Attachment {
    /// Clean raw data when native is ready
    func cleanRawData() {
        guard isReadyToClean else { return }
        raw = nil
    }
}

// MARK: - Delete Attachment

public extension Attachment {
    /// Delete attachment from context
    func delete() {
        managedObjectContext?.delete(self)
    }
}
