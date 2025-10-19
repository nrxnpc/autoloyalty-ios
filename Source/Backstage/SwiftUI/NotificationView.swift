import SwiftUI
import SwiftUIComponents

struct NotificationMessageView: View, ComponentBuilder {
    let text: String
    let action: () -> Void
    
    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 0) {
            MakeSubtitle(.init(text))
                .padding(6)
            
            Button {
                action()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 16))
                    .foregroundStyle(.tertiary)
            }
            .foregroundStyle(.secondary)
            .padding(.trailing, 6)
        }
        .background {
            RoundedRectangle(cornerRadius: 8)
                .foregroundStyle(.regularMaterial)
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }
}
