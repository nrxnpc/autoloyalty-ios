import Foundation

/// Central coordinator for all ScopeGraph modules
public struct ScopeGraph {
    private let registry: ComponentRegistry
    
    public init() {
        self.registry = ComponentRegistry()
    }
    
    private init(registry: ComponentRegistry) {
        self.registry = registry
    }
    
    public func register<T: DataComponent>(_ component: T) -> ScopeGraph {
        let newRegistry = registry.adding(component)
        return ScopeGraph(registry: newRegistry)
    }
    
    public func build() -> DataPipeline {
        return DataPipeline(components: registry.components)
    }
}

/// Component registry for managing data components
final class ComponentRegistry {
    let components: [any DataComponent]
    
    init() {
        self.components = []
    }
    
    private init(components: [any DataComponent]) {
        self.components = components
    }
    
    func adding<T: DataComponent>(_ component: T) -> ComponentRegistry {
        var newComponents = components
        newComponents.append(component)
        return ComponentRegistry(components: newComponents)
    }
}