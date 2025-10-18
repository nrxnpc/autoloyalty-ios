import SwiftUI

// MARK: - Base UI Components

public extension ComponentBuilder {
    
    /// Creates an icon with specified system image and size.
    /// - Parameters:
    ///   - systemImage: SF Symbol name
    ///   - size: Icon size (.small, .medium, .large)
    /// - Returns: Configured icon view
    @ViewBuilder 
    func MakeIcon(systemImage: String, size: IconSize = .medium) -> some View {
        Image(systemName: systemImage)
            .resizable()
            .scaledToFit()
            .frame(width: size.size.width, height: size.size.height)
            .foregroundStyle(.primary)
    }
    
    /// Creates a title text view.
    /// - Parameter title: Title text
    /// - Returns: Configured title view
    @ViewBuilder 
    func MakeTitle(_ title: LocalizedStringKey) -> some View {
        Text(title)
            .font(.title2.weight(.bold))
            .multilineTextAlignment(.leading)
    }
    
    /// Creates a subtitle text view.
    /// - Parameter subtitle: Subtitle text
    /// - Returns: Configured subtitle view
    @ViewBuilder 
    func MakeSubtitle(_ subtitle: LocalizedStringKey) -> some View {
        Text(subtitle)
            .font(.body)
            .foregroundStyle(.secondary)
            .multilineTextAlignment(.center)
    }
    
    /// Creates a text field with placeholder and clear button.
    /// - Parameters:
    ///   - placeholder: Placeholder text
    ///   - text: Binding to text value
    ///   - inputType: Input configuration type
    /// - Returns: Configured text field with clear functionality
    @ViewBuilder 
    func MakeTextField(placeholder: String, text: Binding<String>, inputType: InputType = .text) -> some View {
        TextFieldView(placeholder: LocalizedStringKey(placeholder), text: text, inputType: inputType)
            .padding(.horizontal, 12)
    }

    @ViewBuilder
    func MakeButton(_ title: LocalizedStringKey, image: String? = nil, systemImage: String? = nil, action: @escaping () -> Void) -> some View {
           Button(action: action) {
               if let image {
                   HStack(alignment: .center) {
                       Image(image)
                           .cornerRadius(5)
                       Text(title)
                           .frame(maxWidth: .infinity, alignment: .center)
                   }
               } else if let systemImage {
                   HStack(alignment: .center) {
                       Image(systemName: systemImage)
                       Text(title)
                           .frame(maxWidth: .infinity, alignment: .center)
                   }
               } else {
                   Text(title)
                       .frame(maxWidth: .infinity, alignment: .center)
               }
           }
           .buttonStyle(PrimaryButtonStyle())
       }
    
    @ViewBuilder
    func MakeSecondaryButton(_ title: LocalizedStringKey, image: String? = nil, systemImage: String? = nil, action: @escaping () -> Void) -> some View {
           Button(action: action) {
               if let image {
                   HStack(alignment: .center) {
                       Image(image)
                           .cornerRadius(5)
                       Text(title)
                           .frame(maxWidth: .infinity, alignment: .center)
                   }
               } else if let systemImage {
                   HStack(alignment: .center) {
                       Image(systemName: systemImage)
                       Text(title)
                           .frame(maxWidth: .infinity, alignment: .center)
                   }
               } else {
                   Text(title)
                       .frame(maxWidth: .infinity, alignment: .center)
               }
           }
           .buttonStyle(SecondaryButtonStyle())
       }
}

// MARK: - Private Implementation

public struct TextFieldView: View {
    let placeholder: LocalizedStringKey
    @Binding var text: String
    let inputType: InputType
    
    public var body: some View {
        HStack {
            Group {
                if inputType == .password {
                    SecureField(placeholder, text: $text)
                } else {
                    TextField(placeholder, text: $text)
                        .keyboardType(inputType.keyboardType)
                        .textContentType(inputType.contentType)
                }
            }
            
            if !text.isEmpty {
                Button(action: { text = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.tertiary)
                }
            }
        }
        .frame(height: 44)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

public enum IconSize {
    case small, medium, large
    
    var font: Font {
        switch self {
        case .small: return .body
        case .medium: return .title3
        case .large: return .largeTitle
        }
    }
    
    var size: CGSize {
        switch self {
        case .small: return .init(width: 32, height: 32)
        case .medium: return .init(width: 64, height: 64)
        case .large: return .init(width: 96, height: 96)
        }
    }
}

public enum InputType {
    case text, email, password, phone
    
    var keyboardType: UIKeyboardType {
        switch self {
        case .text: return .default
        case .email: return .emailAddress
        case .password: return .default
        case .phone: return .phonePad
        }
    }
    
    var contentType: UITextContentType? {
        switch self {
        case .text: return nil
        case .email: return .emailAddress
        case .password: return .password
        case .phone: return .telephoneNumber
        }
    }
}
