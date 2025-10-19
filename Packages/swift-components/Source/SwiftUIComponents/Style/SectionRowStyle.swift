import SwiftUI

// MARK: - View Modifiers

/// A `ViewModifier` that applies standard styling for a row within a section.
///
/// This modifier adds consistent horizontal and vertical padding, ensuring that all rows
/// inside a `MakeSection` component have a uniform appearance.
public struct SectionRowStyle: ViewModifier {
    public func body(content: Content) -> some View {
        content
            .frame(minHeight: 48)
            .padding(.horizontal)
    }
}

public extension View {
    /// Applies a standard style for a row contained within a section.
    ///
    /// This is a convenience modifier that wraps the `SectionRowStyle`.
    /// - Returns: A view with standard section row padding applied.
    func sectionRow() -> some View {
        modifier(SectionRowStyle())
    }
}
