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
