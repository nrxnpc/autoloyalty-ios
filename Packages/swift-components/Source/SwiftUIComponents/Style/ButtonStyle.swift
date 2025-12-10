import SwiftUI

// MARK: - Primary Button Example
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

// MARK: Secondary Button Example
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
