import SwiftUI

// MARK: - Text Field Styles

public struct StandardTextFieldStyle: TextFieldStyle {
    public func _body(configuration: TextField<Self._Label>) -> some View {
        HStack {
            configuration
            Button(action: { /* Clear action handled by parent */ }) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundStyle(.tertiary) // Type 'Color' has no member 'textTertiary'
            }
            .opacity(0) // Hidden by default, shown by parent when needed
        }
        .padding(.horizontal, 12)
        .frame(height: 44)
        .background(.regularMaterial) // Type 'ShapeStyle' has no member 'backgroundSecondary'
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

public struct DefaultTextFieldStyle: TextFieldStyle {
    @Binding var text: String
    public init(text: Binding<String>) {
        self._text = text
    }
    
    public var backgroundColor: Color {
        if text.isEmpty {
            return .clear
        } else {
            return Color(UIColor.secondarySystemFill)
        }
    }
    public func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .frame(maxWidth: .infinity, minHeight: 44)
            .font(.body)
            .padding(.horizontal, 16)
            .background {
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .fill(backgroundColor)
                    .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
            }
            .animation(.smooth, value: text)
    }
}

public struct TextFieldClearButton: ViewModifier {
    @Binding var text: String
    public init(text: Binding<String>) {
        self._text = text
    }
    
    public func body(content: Content) -> some View {
        content
            .overlay {
                HStack {
                    Spacer()
                    Button {
                        text = ""
                    } label: {
                        Image(systemName: "multiply.circle.fill")
                    }
                    .foregroundColor(.secondary.opacity(0.4))
                    .opacity(text.isEmpty ? 0.0 : 1.0)
                    .padding(.trailing, 8)
                }
                .animation(.smooth, value: text)
            }
    }
}

public extension View {
    func clearButton(_ text: Binding<String>) -> some View {
        self.modifier(TextFieldClearButton(text: text))
    }
}
