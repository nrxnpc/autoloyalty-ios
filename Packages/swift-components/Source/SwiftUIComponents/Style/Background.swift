import SwiftUI

/// Applies card-like background with glass effect for iOS 18+.
public struct DefaultBackgroundStyle: ViewModifier {
    public init() {}
    public func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            content.glassEffect(.regular.interactive(), in: RoundedRectangle(cornerRadius: 24))
                .clipShape(RoundedRectangle(cornerRadius: 24))
        } else {
            content.background {
                RoundedRectangle(cornerRadius: 24)
                    .fill(.ultraThinMaterial)
            }
            .clipShape(RoundedRectangle(cornerRadius: 24))
        }
    }
}
