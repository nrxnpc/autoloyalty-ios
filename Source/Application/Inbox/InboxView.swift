import SwiftUI
import SwiftUIComponents

struct InboxView: View {
    // MARK: - Dependencies
    
    @EnvironmentObject var router: Main.Router
    
    // MARK: -
    
    @FetchRequest(fetchRequest: InboxMessage.allMessagesSortedByCreatedDate())
    private var messages: FetchedResults<InboxMessage>
    
    @StateObject private var inbox = Inbox()
    @StateObject private var userNotifications = InboxUserNotifications()
    
    // MARK: -
    
    var body: some View {
        ZStack {
            if messages.isEmpty {
                makeEmptyState()
            } else {
                List {
                    if !userNotifications.isSuggestionHidden {
                        Section {
                            makeTurnOnNotificationsRow()
                        }
                    }
                    
                    Section {
                        ForEach(messages, id: \.id) { message in
                            makeRow(with: message)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    router.route(sheet: .inboxMessage(message))
                                }
                                .padding(.vertical, 4)
                        }
                    }
                }
            }
        }
        .animation(.easeInOut, value: userNotifications.authorizationStatus)
        .animation(.easeInOut, value: userNotifications.isSuggestionHidden)
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
    
    @ViewBuilder func makeTurnOnNotificationsRow() -> some View {
        PushNotificationsSuggestionView()
            .environmentObject(userNotifications)
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
