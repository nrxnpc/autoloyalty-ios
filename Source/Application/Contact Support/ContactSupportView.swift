import SwiftUI
import SwiftUIComponents

struct ContactSupportView: View, ComponentBuilder {
    @Environment(\.dismiss) var dismiss
    
    @State private var userMessageText = ""
    @FetchRequest var messages: FetchedResults<SupportMessage>
    
    init() {
        _messages = .init(fetchRequest: SupportMessage.allMessagesSortedByCreatedDate(), animation: .smooth)
    }
    
    var body: some View {
        ZStack {
            if messages.isEmpty {
                makeEmptyState()
            } else {
                makeMessagesList()
            }
            VStack(spacing: 0) {
                Spacer()
                makeMessageInput()
            }
        }
        .animation(.smooth, value: messages.isEmpty)
        .navigationTitle("Contact Support")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(content: makeToolbar)
    }
}

// MARK: - View Builder

extension ContactSupportView {
    @ViewBuilder func makeEmptyState() -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                HStack(alignment: .center) {
                    Image(systemName: "headphones")
                        .font(.title)
                        .foregroundStyle(.blue)
                    Text("Start a conversation with our support team. We're here to help with any questions or issues you may have.")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.leading)
                }
            }
            .padding()
            .background {
                RoundedRectangle(cornerRadius: 24)
                    .foregroundStyle(.regularMaterial)
            }
            .padding()
        }
    }
    
    @ViewBuilder func makeMessagesList() -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                ForEach(messages, id: \.id) { message in
                    makeMessagesRow(message)
                }
            }
        }
    }
    
    @ViewBuilder func makeMessagesRow(_ message: SupportMessage) -> some View {
        HStack(alignment: .firstTextBaseline) {
            Text(message.text)
            Spacer()
            Text(DateFormatters.shared.day.string(from: message.createdAt))
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
    }
    
    @ViewBuilder func makeMessageInput() -> some View {
        HStack(spacing: 12) {
            TextField("Type a message...", text: $userMessageText)
                .textFieldStyle(.automatic)
                .padding()
                .background {
                    RoundedRectangle(cornerRadius: 16)
                        .foregroundStyle(.thickMaterial)
                }
            
            Button(action: {}) {
                Image(systemName: "paperplane.fill")
                    .foregroundStyle(.white)
                    .padding(8)
                    .background(.thickMaterial)
                    .clipShape(Circle())
            }
            .disabled(userMessageText.isEmpty)
        }
        .animation(.smooth, value: userMessageText.isEmpty)
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
    }
    
    @ToolbarContentBuilder func makeToolbar() -> some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button(action: dismiss.callAsFunction) {
                Image(systemName: "xmark")
            }
        }
    }
}
