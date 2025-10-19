import SwiftUI

// MARK: - Feature Gates

public extension ComponentBuilder {
    /// Creates a standard view for a feature gate barrier.
    ///
    /// This view can be used to inform the user that a feature is unavailable
    /// and provide instructions on how to enable it. It's intended for use as a standalone screen.
    ///
    /// - Parameters:
    ///   - title: The title for the barrier screen.
    ///   - subtitle: The subtitle with instructions.
    /// - Returns: A view that represents the feature gate barrier.
    @ViewBuilder
    func MakeFeatureGateBarrier(title: LocalizedStringKey, subtitle: LocalizedStringKey) -> some View {
        FeatureGateBarrierView(title: title, subtitle: subtitle)
            .background(Color.backgroundPrimary)
    }
    
    /// Creates a page indicating that a feature is currently under development.
    ///
    /// This is a useful placeholder for UI that is not yet fully implemented.
    /// It clearly communicates the status to anyone testing the app.
    ///
    /// ## Usage
    ///
    /// ```swift
    /// struct MyNewFeatureScreen: View, ComponentBuilder {
    ///     var body: some View {
    ///         MakeUnderConstructionBarrier(
    ///             reason: "The database connection for this feature is not yet configured."
    ///         )
    ///     }
    /// }
    /// ```
    ///
    /// - Parameters:
    ///   - title: An optional title for the screen. Defaults to "Feature in Development".
    ///   - reason: A `LocalizedStringKey` explaining why the feature is unavailable (e.g., implementation details).
    /// - Returns: A view that represents the "under construction" barrier.
    @ViewBuilder
    func MakeUnderConstructionBarrier(title: LocalizedStringKey = "Feature in Development", reason: LocalizedStringKey) -> some View {
        UnderConstructionBarrierView(title: title, reason: reason)
            .background(Color.backgroundPrimary)
    }
}

// MARK: - Build-In Implementation

/// A view modifier that overlays a barrier on its content if a specific condition is not met.
///
/// This is useful for building feature gates directly into the UI. If the feature is disabled,
/// this modifier presents a user-friendly view explaining what is needed to enable it.
/// The underlying content is dimmed but visible.
///
/// ## Usage
///
/// ```swift
/// var body: some View {
///     MyFeatureView()
///         .modifier(MakeBlock(
///             isFeatureDependencyEnabled,
///             title: "Feature Requires Another Setting",
///             subtitle: "Please enable the 'Dependency' setting to use this feature."
///         ))
/// }
/// ```
public struct MakeBlock: ViewModifier {
    /// A boolean value that determines whether the content is accessible.
    /// If `false`, the barrier is shown.
    let isEnabled: Bool
    
    /// The title to display on the barrier.
    let title: LocalizedStringKey
    
    /// The instructional subtitle to display on the barrier.
    let subtitle: LocalizedStringKey
    
    /// Initializes the feature gate modifier.
    /// - Parameters:
    ///   - isEnabled: A boolean expression. If it evaluates to `false`, the content will be blocked.
    ///   - title: The title for the barrier screen.
    ///   - subtitle: The subtitle with instructions for the user.
    public init(_ isEnabled: Bool, title: LocalizedStringKey, subtitle: LocalizedStringKey) {
        self.isEnabled = isEnabled
        self.title = title
        self.subtitle = subtitle
    }

    public func body(content: Content) -> some View {
        if isEnabled {
            content
        } else {
            ZStack {
                FeatureGateBarrierView(title: title, subtitle: subtitle)
            }
            .transition(.opacity.animation(.easeInOut))
        }
    }
}

public extension View {
    /// Applies a feature gate barrier over a view.
    ///
    /// If `isEnabled` is `false`, this modifier overlays a view with a title and subtitle,
    /// instructing the user on how to enable the feature. This is a convenience wrapper around `MakeBlock`.
    ///
    /// - Parameters:
    ///   - isEnabled: A boolean indicating whether the feature is available.
    ///   - title: The title for the barrier screen.
    ///   - subtitle: The subtitle with instructions.
    /// - Returns: A view that is conditionally overlaid with a feature gate barrier.
    func featureGate(isEnabled: Bool, title: LocalizedStringKey, subtitle: LocalizedStringKey) -> some View {
        self.modifier(MakeBlock(isEnabled, title: title, subtitle: subtitle))
    }
}

// MARK: - Private Section

/// A private view that renders the standard UI for a feature gate barrier.
/// It conforms to `ComponentBuilder` to reuse existing text components.
private struct FeatureGateBarrierView: View, ComponentBuilder {
    let title: LocalizedStringKey
    let subtitle: LocalizedStringKey
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "lock.shield.fill")
                .font(.system(size: 50, weight: .light))
                .foregroundStyle(.secondary)
                .padding(.bottom, 8)
            
            BuildLargeTitle(title)
                .font(.system(size: 24, weight: .bold)) // Slightly smaller than standard LargeTitle for this context
            
            BuildSubtitle(subtitle)
                .padding(.horizontal)
        }
        .padding(32)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

/// A private view that renders the UI for an "under construction" barrier.
private struct UnderConstructionBarrierView: View, ComponentBuilder {
    let title: LocalizedStringKey
    let reason: LocalizedStringKey
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "wrench.and.screwdriver.fill")
                .font(.system(size: 50, weight: .light))
                .foregroundStyle(Color.orange)
                .padding(.bottom, 8)
            
            BuildLargeTitle(title)
                .font(.system(size: 24, weight: .bold))
            
            BuildSubtitle(reason)
                .padding(.horizontal)
        }
        .padding(32)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
