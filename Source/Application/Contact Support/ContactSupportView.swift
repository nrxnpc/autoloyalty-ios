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
        }
        .animation(.smooth, value: messages.isEmpty)
        .navigationTitle("Contact Support")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(content: makeToolbar)
    }
    
    func sentMessage() {
        guard !userMessageText.isEmpty else {
            return
        }
        
        let text = userMessageText
        Task {
            do {
                try await SendMessageToSupportUseCase().send(text: text)
            } catch {
                UINotificationFeedbackGenerator().notificationOccurred(.error)
            }
        }
        userMessageText = ""
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
        ScrollViewReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    ForEach(messages, id: \.id) { message in
                        makeMessagesRow(message)
                    }
                }
            }
            .scrollDismissesKeyboard(.interactively)
            .onChange(of: messages.count) {
                if let lastMessage = messages.last {
                    withAnimation(.easeOut(duration: 0.3)) {
                        proxy.scrollTo(lastMessage.id, anchor: .bottom)
                    }
                }
            }
            .onAppear {
                if let lastMessage = messages.last {
                    proxy.scrollTo(lastMessage.id, anchor: .bottom)
                }
            }
        }
    }
    
    @ViewBuilder func makeMessagesRow(_ message: SupportMessage) -> some View {
        if message.isOwned {
            // User message (right side, blue bubble)
            HStack {
                Spacer(minLength: 60)
                VStack(alignment: .trailing, spacing: 4) {
                    Text(message.text)
                        .font(.body)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background {
                            RoundedRectangle(cornerRadius: 18)
                                .fill(.blue)
                        }
                    
                    Text(DateFormatters.shared.day.string(from: message.createdAt))
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .padding(.trailing, 4)
                }
            }
            .padding(.horizontal)
        } else {
            // Support message (left side, gray bubble)
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(alignment: .top, spacing: 8) {
                        Image(systemName: "headphones")
                            .font(.caption)
                            .foregroundStyle(.blue)
                            .padding(6)
                            .background {
                                Circle()
                                    .fill(.blue.opacity(0.1))
                            }
                        
                        Text(message.text)
                            .font(.body)
                            .foregroundStyle(.primary)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background {
                                RoundedRectangle(cornerRadius: 18)
                                    .fill(.gray.opacity(0.1))
                            }
                    }
                    
                    Text(DateFormatters.shared.day.string(from: message.createdAt))
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .padding(.leading, 38)
                }
                Spacer(minLength: 60)
            }
            .padding(.horizontal)
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
        
        ToolbarItemGroup(placement: .bottomBar) {
            TextField("Type a message...", text: $userMessageText)
                .textFieldStyle(.automatic)
                .submitLabel(.send)
                .onSubmit {
                    Task { @MainActor in
                        if !userMessageText.isEmpty {
                            sentMessage()
                        }
                    }
                }
                .padding(.horizontal)
            Button(action: sentMessage) {
                Image(systemName: "arrow.up")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .padding(8)
                    .background(userMessageText.isEmpty ? .gray : .blue)
                    .clipShape(Capsule())
            }
            .disabled(userMessageText.isEmpty)
            .animation(.easeInOut, value: userMessageText.isEmpty)
        }
    }
}
