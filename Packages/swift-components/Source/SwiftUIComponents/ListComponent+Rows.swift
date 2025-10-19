import SwiftUI

public extension ComponentBuilder {
    /// Creates a visual block that automatically arranges its content into rows separated by dividers.
    ///
    /// This component uses a custom `ResultBuilder` (`SectionContentBuilder`) to collect its child
    /// views into an array. It then iterates over this array to place dividers between each row,
    /// except for the very last one. This removes the need to manually add `Divider()` at the call site.
    ///
    /// ## Usage
    /// Simply list the views you want inside the section. The dividers are handled automatically.
    /// ```swift
    /// MakeSection(title: "Settings") {
    ///     MakeTextFieldRow(placeholder: "Name", text: $name)
    ///     MakeButtonRow("Change Password") { /* ... */ }
    ///     MakeCopyableTextRow(placeholder: "User ID", value: "12345")
    /// }
    /// ```
    ///
    /// - Parameters:
    ///   - title: An optional string to display as a capitalized header above the section.
    ///   - content: A closure using `SectionContentBuilder` that provides the section's rows.
    /// - Returns: A styled view representing the section.
    @ViewBuilder
    func MakeSection<Content: View>(
        title: LocalizedStringKey? = nil,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            if let title = title {
                Text(title)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal)
            }
            
            VStack(spacing: 0) {
                content()
                    .sectionRow()
            }
            .padding(.vertical, 8)
            .background(.regularMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    
    /// Creates a header view for a list, typically used for profile screens.
    ///
    /// This component provides a standardized layout for a prominent icon (like a profile picture)
    /// and an associated action button below it.
    ///
    /// - Parameters:
    ///   - icon: A `ViewBuilder` closure for the main icon or image.
    ///   - action: A `ViewBuilder` closure for the action view, such as a "Change Picture" button.
    /// - Returns: A configured header view.
    @ViewBuilder
    func MakeListHeader<Icon: View, Action: View>(
        @ViewBuilder icon: () -> Icon,
        @ViewBuilder action: () -> Action
    ) -> some View {
        VStack(spacing: 12) {
            icon()
            action()
        }
        .frame(height: 220)
        .frame(maxWidth: .infinity)
    }
    
    /// Creates a header background view with a two-tone design featuring a smooth wave.
    ///
    /// This component recreates the provided image by layering a custom `WaveShape`
    /// over a solid background color. It's designed to be used as a background
    /// for entire screens or header areas.
    ///
    /// - Parameters:
    ///   - fillColor: The main color for the upper part of the background.
    /// - Returns: A view that fills its parent and ignores safe areas.
    @ViewBuilder
    func MakeHeaderBackground(
        fillColor: Color = .backgroundPrimary
    ) -> some View {
        WaveShape()
            .fill(fillColor)
    }
    
    /// Creates a header background view with a defining line along the wave.
    ///
    /// This component layers a stroked `WaveShape` over a filled one to create
    /// a distinct border along the wave's edge. It's useful for adding more
    /// visual separation.
    ///
    /// - Parameters:
    ///   - fillColor: The main color for the upper part of the background.
    /// - Returns: A view that fills its parent and ignores safe areas.
    @ViewBuilder
    func MakeHeaderBackgroundWithLine(
        fillColor: Color = .backgroundPrimary
    ) -> some View {
        ZStack {
            Rectangle()
                .fill(fillColor)
                .padding(.bottom, 104)
        }
    }
    
    /// Creates a header background view with a smooth gradient fill.
    ///
    /// This component fills a custom `WaveShape` with a `LinearGradient`
    /// to create a smooth color transition. Ideal for modern and dynamic UIs.
    ///
    /// - Parameters:
    ///   - colors: An array of colors to create the gradient from.
    ///   - startPoint: The starting point of the gradient.
    ///   - endPoint: The ending point of the gradient.
    /// - Returns: A view that fills its parent and ignores safe areas.
    @ViewBuilder
    func MakeHeaderBackgroundWithGradient(
        colors: [Color] = [.backgroundPrimary, .clear],
        startPoint: UnitPoint = .top,
        endPoint: UnitPoint = .bottom
    ) -> some View {
        Rectangle()
            .fill(
                LinearGradient(
                    gradient: Gradient(colors: colors),
                    startPoint: startPoint,
                    endPoint: endPoint
                )
            )
            .padding(.bottom, 128)
    }
    
    /// Creates a row containing a `TextField`, styled for use within a `MakeSection`.
    ///
    /// - Parameters:
    ///   - placeholder: The `LocalizedStringKey` to display when the text field is empty.
    ///   - text: A `Binding` to the string value to display and edit.
    /// - Returns: A configured `TextField` view.
    @ViewBuilder
    func MakeTextFieldRow(placeholder: String, text: Binding<String>, inputType: InputType = .text) -> some View {
        TextFieldView(placeholder: LocalizedStringKey(placeholder), text: text, inputType: inputType)
    }
    
    /// Creates a tappable row that functions as a button, styled for use within a `MakeSection`.
    ///
    /// The button's label spans the full width of the row, providing a large tap target.
    ///
    /// - Parameters:
    ///   - title: The `LocalizedStringKey` for the button's title.
    ///   - action: The closure to execute when the button is tapped.
    /// - Returns: A configured `Button` view.
    @ViewBuilder
    func MakeButtonRow(_ title: LocalizedStringKey, image: String? = nil, systemImage: String? = nil, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            if let image {
                HStack {
                    Image(image)
                        .cornerRadius(5)
                    Text(title)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .contentShape(Rectangle())
                }
            } else if let systemImage {
                HStack {
                    Image(systemName: systemImage)
                    Text(title)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .contentShape(Rectangle())
                }
            } else {
                Text(title)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .contentShape(Rectangle())
            }
        }
        .padding(.vertical, 4)
    }
    
    /// Creates a non-editable text row that looks like a `TextField` and copies its value when tapped.
    ///
    /// This component is visually identical to `MakeTextFieldRow` but is not editable.
    /// Tapping the row copies its value to the clipboard and provides brief visual
    /// (an icon changes to a checkmark) and haptic feedback.
    ///
    /// - Parameters:
    ///   - placeholder: The `LocalizedStringKey` to display if the value is empty.
    ///   - value: The `String` value to display and copy.
    /// - Returns: A configured, interactive text row.
    @ViewBuilder
    func MakeCopyableTextRow(placeholder: LocalizedStringKey, value: String) -> some View {
        // Use a private helper View to encapsulate the state for the copy feedback.
        CopyableValueRowView(placeholder: placeholder, value: value)
    }
    
    /// Creates a row with a checkmark that can be selected/deselected, styled for use within a `MakeSection`.
    ///
    /// - Parameters:
    ///   - title: The `LocalizedStringKey` for the row's title.
    ///   - isSelected: A `Binding` to the boolean selection state.
    ///   - action: An optional closure to execute when the row is tapped.
    /// - Returns: A configured selectable row view.
    @ViewBuilder
    func MakeCheckmarkRow(_ title: LocalizedStringKey, isSelected: Binding<Bool> = .constant(false), action: (() -> Void)? = nil) -> some View {
        Button(action: {
            isSelected.wrappedValue.toggle()
            action?()
        }) {
            HStack {
                Text(title)
                    .foregroundStyle(.primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                if isSelected.wrappedValue {
                    Image(systemName: "checkmark")
                        .foregroundStyle(.blue)
                        .font(.body.weight(.medium))
                }
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .padding(.vertical, 4)
    }
}

// MARK: - Fileprivate Build-In Implementations

// MARK: - Fileprivate Implementation Details

/// A private helper view that provides the look and feel of a TextField but with copy functionality.
private struct CopyableValueRowView: View {
    let placeholder: LocalizedStringKey
    let value: String
    
    @State private var didJustCopy = false

    var body: some View {
        Button(action: copyToClipboard) {
            HStack {
                // Display the placeholder if value is empty, otherwise display the value.
                if value.isEmpty {
                    Text(placeholder)
                        .foregroundStyle(.secondary.opacity(0.7)) // Mimic placeholder text color
                } else {
                    Text(value)
                        .foregroundStyle(.blue)
                }
                
                Spacer()
                
                // Animate the transition between the copy icon and the "Copied!" checkmark.
                if didJustCopy {
                    Image(systemName: "checkmark")
                        .font(.footnote)
                        .foregroundStyle(.green)
                        .transition(.opacity.combined(with: .scale(scale: 0.8)))
                } else {
                    Image(systemName: "doc.on.doc")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .transition(.opacity)
                }
            }
            .contentShape(Rectangle()) // Makes the entire HStack tappable
        }
        .disabled(value.isEmpty) // Disable the button if there is nothing to copy
        .tint(.primary) // Ensures text color is standard black/white
        .padding(.vertical, 4) // Matches the padding of MakeTextFieldRow
        .sensoryFeedback(.success, trigger: didJustCopy) { _, newValue in
            // Trigger haptic feedback only when changing from false to true.
            newValue
        }
        .animation(.snappy(duration: 0.25), value: didJustCopy)
    }

    /// Copies the value to the system pasteboard and triggers the feedback state.
    private func copyToClipboard() {
        guard !value.isEmpty else { return }
        
        #if os(macOS)
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(value, forType: .string)
        #else
        UIPasteboard.general.string = value
        #endif
        
        didJustCopy = true
        
        // Reset the "Copied!" state after 2 seconds.
        Task {
            try? await Task.sleep(for: .seconds(2))
            didJustCopy = false
        }
    }
}

/// A shape that recreates the specific wavy bottom from the image.
fileprivate struct WaveShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()

        let waveStartPoint = CGPoint(x: rect.width * 0.4513, y: rect.height * 0.9842)
        let waveEndPoint = CGPoint(x: rect.width * 0.9974, y: rect.height * 0.9789)
        let waveControlPoint = CGPoint(x: rect.width * 0.5115, y: rect.height * 0.5447)

        path.move(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: waveEndPoint)
        path.addQuadCurve(to: waveStartPoint, control: waveControlPoint)
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()

        return path
    }
}
