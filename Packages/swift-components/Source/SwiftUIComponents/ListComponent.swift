import SwiftUI

// MARK: - List Component

public extension ComponentBuilder {
    
    /// Creates a scrollable list container.
    ///
    /// The list enables advanced effects like stretchable backgrounds and allows
    /// its subviews to report their visibility status using the `.trigger(visible:)` modifier.
    ///
    /// ## Usage
    ///
    /// ```swift
    /// struct ProfileView: View, ComponentBuilder {
    ///     @State private var isHeaderVisible: Bool = true
    ///
    ///     var body: some View {
    ///         MakeList {
    ///             MyHeaderView()
    ///                 .trigger(visible: $isHeaderVisible)
    ///             // ... other content
    ///         }
    ///     }
    /// }
    /// ```
    ///
    /// - Parameter content: A view builder that returns the content of the list.
    /// - Returns: A configured `ScrollView`.
    @ViewBuilder
    func MakeList<Content: View>(
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        ScrollView {
            VStack(spacing: 16) {
                content()
            }
            .padding(.horizontal)
        }
        .scrollDismissesKeyboard(.interactively)
        .background(Color.backgroundPrimary)
    }
}

// MARK: - Visibility Tracking Modifier

public extension View {
    
    /// Attaches a trigger that updates the given binding based on the view's
    /// visibility on the screen.
    ///
    /// This modifier uses the canonical SwiftUI approach of combining `GeometryReader`
    /// with `PreferenceKey` to safely and efficiently communicate the view's
    /// visibility state up the view hierarchy.
    ///
    /// - Parameter isVisible: A `Binding<Bool>` that will be set to `true` when
    ///   the view is at least partially on-screen and `false` when it is completely off-screen.
    /// - Returns: A view modified to track its own visibility.
    func trigger(visible isVisible: Binding<Bool>) -> some View {
        self.modifier(ScrollVisibilityTriggerModifier(isVisible: isVisible))
    }
}

// MARK: - Private Helper Implementations

/// A preference key to communicate the visibility status of a view.
private struct ScrollVisibilityPreferenceKey: PreferenceKey {
    static let defaultValue: Bool = false
    
    static func reduce(value: inout Bool, nextValue: () -> Bool) {
        // If any view reports being visible, the collective value is true.
        value = value || nextValue()
    }
}

/// A private view modifier that uses GeometryReader and PreferenceKey to report visibility.
private struct ScrollVisibilityTriggerModifier: ViewModifier {
    @Binding var isVisible: Bool
    
    func body(content: Content) -> some View {
        content
            // Use a background view with a GeometryReader to avoid affecting the layout.
            .background(
                GeometryReader { geometry in
                    Color.clear
                        // Set the preference value based on the view's frame.
                        .preference(
                            key: ScrollVisibilityPreferenceKey.self,
                            value: self.isViewVisible(in: geometry)
                        )
                }
            )
            // React to changes in the preference key.
            .onPreferenceChange(ScrollVisibilityPreferenceKey.self) { visibility in
                // This is the safe and correct place to update the state.
                self.isVisible = visibility
            }
    }
    
    /// Determines if the view's frame is currently visible on the screen.
    private func isViewVisible(in geometry: GeometryProxy) -> Bool {
        // Get the view's frame in the global coordinate space.
        let frame = geometry.frame(in: .global)
        
        // A view with a zero frame is not considered visible.
        guard frame.size.width > 0 && frame.size.height > 0 else { return false }
        
        // Check if the view's frame intersects with the screen's bounds.
        return UIScreen.main.bounds.intersects(frame)
    }
}
