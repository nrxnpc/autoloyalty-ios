import Foundation

/// Central coordinator for all ScopeGraph modules
/// 
/// ScopeGraph provides a modular data processing pipeline with support for:
/// - Caching and persistent storage
/// - Secure keychain operations
/// - CoreData integration
/// - Background processing
/// 
/// Minimum deployment targets:
/// - iOS 18.0+
/// - macOS 15.0+
/// - watchOS 11.0+
/// - tvOS 18.0+
/// - visionOS 2.0+
@available(iOS 18.0, macOS 15.0, watchOS 11.0, tvOS 18.0, visionOS 2.0, *)
public struct ScopeGraph: Sendable {
    private let registry: ComponentRegistry
    
    /// Initialize empty ScopeGraph
    public init() {
        self.registry = ComponentRegistry()
    }
    
    private init(registry: ComponentRegistry) {
        self.registry = registry
    }
    
    /// Register a data component in the pipeline
    /// - Parameter component: Component to register
    /// - Returns: New ScopeGraph instance with the component registered
    public func register<T: DataComponent>(_ component: T) -> ScopeGraph {
        let newRegistry = registry.adding(component)
        return ScopeGraph(registry: newRegistry)
    }
    
    /// Build the data processing pipeline
    /// - Returns: Configured DataPipeline ready for use
    public func build() -> DataPipeline {
        return DataPipeline(components: registry.components)
    }
}

/// Component registry for managing data components
@available(iOS 18.0, macOS 15.0, watchOS 11.0, tvOS 18.0, visionOS 2.0, *)
final class ComponentRegistry: Sendable {
    let components: [any DataComponent & Sendable]
    
    init() {
        self.components = []
    }
    
    private init(components: [any DataComponent & Sendable]) {
        self.components = components
    }
    
    func adding<T: DataComponent & Sendable>(_ component: T) -> ComponentRegistry {
        var newComponents = components
        newComponents.append(component)
        return ComponentRegistry(components: newComponents)
    }
}