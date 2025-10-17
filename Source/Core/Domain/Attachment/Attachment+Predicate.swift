// File: Attachment+Predicate.swift

import Foundation

// MARK: - Convenience Properties

public extension Attachment {
    /// Attachment is empty when no source URL and no data exists
    var isEmpty: Bool {
        sourceURL == nil && raw == nil && native == nil
    }
    
    var isReadyToUse: Bool {
        raw != nil || native != nil
    }
    
    var isNotLoaded: Bool {
        sourceURL != nil && raw == nil && native == nil
    }
    
    var isNotPublished: Bool {
        sourceURL == nil && (raw != nil || native != nil)
    }
    
    var isNotOptimized: Bool {
        sourceURL != nil && raw != nil && native == nil
    }
    
    var isReadyToClean: Bool {
        // Raw data can be cleaned when native exists and hashes match
        sourceURL != nil && raw != nil && native != nil && sourceHash == calculateNativeHash()
    }
}
