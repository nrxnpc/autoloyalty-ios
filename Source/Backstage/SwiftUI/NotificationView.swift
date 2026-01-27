import SwiftUI
import SwiftUIComponents

struct NotificationMessageView: View, ComponentBuilder {
    let text: LocalizedStringKey?
    let action: () -> Void
    
    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 0) {
            Text(text ?? "")
                .lineLimit(nil)
                .font(.subheadline)
                .padding(.horizontal, 8)
                .padding(.trailing, 4)
        }
        .padding()
        .background {
            RoundedRectangle(cornerRadius: 16)
                .foregroundStyle(.thickMaterial)
        }
        .overlay(alignment: .topTrailing) {
            Button {
                action()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 16))
                    .foregroundStyle(.tertiary)
            }
            .foregroundStyle(.secondary)
            .padding([.top, .trailing], 8)
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }
}

#Preview {
    NotificationMessageView(text: "Ups! Something went wrong. Please try again. Please try again.") {
        
    }
}
