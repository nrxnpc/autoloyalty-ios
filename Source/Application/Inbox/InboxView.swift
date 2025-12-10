import SwiftUI
import SwiftUIComponents

struct InboxView: View {
    // MARK: - Dependencies
    
    @EnvironmentObject var router: Main.Router
    
    // MARK: -
    
    @FetchRequest(fetchRequest: InboxMessage.allMessagesSortedByCreatedDate())
    private var messages: FetchedResults<InboxMessage>
    
    @StateObject private var inbox = Inbox()
    
    // MARK: -
    
    var body: some View {
        ZStack {
            if messages.isEmpty {
                makeEmptyState()
            } else {
                List(messages, id: \.id) { message in
                    makeRow(with: message)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            router.route(sheet: .inboxMessage(message))
                        }
                        .padding(.vertical, 4)
                }
            }
        }
        .toolbar(content: makeToolbar)
        .navigationTitle("Notifications")
        .navigationBarTitleDisplayMode(.large)
    }
}

extension InboxView {
    @ViewBuilder func makeEmptyState() -> some View {
        ScrollView {
            VStack {
                Text("Your inbox is empty")
                        .font(.headline)
                Text("All your relevant notifications will be here.")
                    .font(.subheadline)
            }
        }
    }
    
    @ViewBuilder func makeRow(with message: InboxMessage) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .firstTextBaseline) {
                HStack(alignment: .center) {
                    if !message.wasReaded {
                        Text("•")
                            .font(.headline)
                            .foregroundStyle(.red)
                    }
                    Text(message.title)
                        .font(.headline)
                }
                .animation(.smooth, value: message.wasReaded)
                
                Spacer()
                Text(DateFormatters.shared.shortDay.string(from: message.createdAt))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Text(message.subtitle)
                .font(.subheadline)
        }
        .lineLimit(2)
    }
    
    @ToolbarContentBuilder func makeToolbar() -> some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Menu {
                Button {
                    inbox.markAllAsRead()
                } label: {
                    Label("Mark all as read", systemImage: "checkmark.circle")
                }
                .disabled(messages.isEmpty)
            } label: {
                Image(systemName: "ellipsis")
            }
        }
    }
}

#Preview {
    InboxView()
}
