import SwiftUI
import SwiftUIComponents

struct InboxView: View {
    // MARK: - Dependencies
    
    @Environment(Main.Router.self) private var router
    
    //@EnvironmentObject var router: Main.Router
    @StateObject var inbox = Inbox()
    @StateObject var userNotifications = InboxUserNotifications()
    
    // MARK: -
    
    @FetchRequest private var messages: FetchedResults<InboxMessage>
    @State private var searchText = ""
    
    // MARK: -
    
    init() {
        _messages = FetchRequest(
            sortDescriptors: [NSSortDescriptor(key: "createdAt", ascending: false)],
            predicate: nil,
            animation: .smooth
        )
    }
    
    var body: some View {
        ZStack {
            if messages.isEmpty && searchText.isEmpty {
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
                .searchable(text: $searchText, prompt: "Search notifications")
            }
        }
        .animation(.easeInOut, value: userNotifications.authorizationStatus)
        .animation(.easeInOut, value: userNotifications.isSuggestionHidden)
        .toolbar(content: makeToolbar)
        .navigationTitle("Notifications")
        .navigationBarTitleDisplayMode(.large)
        .onChange(of: searchText) {
            updatePredicate()
        }
        .onAppear {
            updatePredicate()
        }
    }
    
    private func updatePredicate() {
        if searchText.isEmpty {
            messages.nsPredicate = nil
        } else {
            messages.nsPredicate = NSPredicate(format: "title CONTAINS[cd] %@ OR subtitle CONTAINS[cd] %@", searchText, searchText)
        }
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
