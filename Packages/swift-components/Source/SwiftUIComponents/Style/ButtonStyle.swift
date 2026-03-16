import SwiftUI

/// Primary button style with accent color background and white text.
public struct PrimaryButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) var isEnabled
    public init() {}
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline.weight(.semibold))
            .padding()
            .frame(maxWidth: .infinity, alignment: .center)
            .frame(height: 56)
            .foregroundColor(.white)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(isEnabled ? Color.accentColor : Color.gray)
            )
            .opacity(isEnabled ? 1.0 : 0.6)
            .scaleEffect(configuration.isPressed && isEnabled ? 0.97 : 1.0)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
            .sensoryFeedback(.impact, trigger: configuration.isPressed && isEnabled)
    }
}

/// Secondary button style with transparent background.
public struct SecondaryButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) var isEnabled
    public init() {}
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline.weight(.semibold))
            .padding()
            .frame(maxWidth: .infinity, alignment: .center)
            .frame(height: 50)
            .background(Color.clear)
            .opacity(isEnabled ? 1.0 : 0.6)
            .scaleEffect(configuration.isPressed && isEnabled ? 0.97 : 1.0)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
            .sensoryFeedback(.impact, trigger: configuration.isPressed && isEnabled)
    }
}

/// Button style with stroke border and thin material background.
public struct StrokeButtonStyle: ButtonStyle {
    public init() {}
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline.weight(.semibold))
            .padding()
            .frame(maxWidth: .infinity, alignment: .center)
            .frame(height: 56)
            .foregroundColor(.primary)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Color.primary, lineWidth: 2)
                    .foregroundStyle(.thinMaterial)
            )
            .contentShape(Rectangle())
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
            .sensoryFeedback(.impact, trigger: configuration.isPressed)
    }
}

/// Compact button style with stroke border without full width.
public struct CompactStrokeButtonStyle: ButtonStyle {
    public init() {}
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline.weight(.semibold))
            .padding()
            .foregroundColor(.primary)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Color.primary, lineWidth: 2)
                    .foregroundStyle(.thinMaterial)
            )
            .contentShape(Rectangle())
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
            .sensoryFeedback(.impact, trigger: configuration.isPressed)
    }
}

/// Button style with glass effect for iOS 26+ and ultraThin material for earlier versions.
public struct GlassButtonStyle: ButtonStyle {
    public init() {}
    public func makeBody(configuration: Configuration) -> some View {
        if #available(iOS 26.0, *) {
            configuration.label
                .font(.headline.weight(.semibold))
                .padding()
                .frame(maxWidth: .infinity, alignment: .center)
                .frame(height: 56)
                .foregroundColor(.primary)
                .glassEffect(.regular.interactive(), in: RoundedRectangle(cornerRadius: 8))
                .contentShape(RoundedRectangle(cornerRadius: 8))
                .animation(.snappy(duration: 0.2), value: configuration.isPressed)
                .sensoryFeedback(.impact, trigger: configuration.isPressed)
        } else {
            configuration.label
                .font(.headline.weight(.semibold))
                .padding()
                .frame(maxWidth: .infinity, alignment: .center)
                .frame(height: 56)
                .foregroundColor(.primary)
                .background {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(.ultraThinMaterial)
                }
                .contentShape(Rectangle())
                .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
                .animation(.snappy, value: configuration.isPressed)
                .sensoryFeedback(.impact, trigger: configuration.isPressed)
        }
    }
}
