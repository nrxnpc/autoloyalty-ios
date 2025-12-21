import SwiftUI
import SwiftUIComponents

struct InboxView: View {
    // MARK: - Dependencies
    
    @Environment(Main.Router.self) private var router
    
    @StateObject var inbox = Inbox()
    @StateObject var userNotifications = InboxUserNotifications()
    
    // MARK: -
    
    @FetchRequest private var messages: FetchedResults<InboxMessage>
    @State private var searchText = ""
    @AppStorage("inbox.sortOrder") private var sortOrder = SortOrder.newestFirst.rawValue
    
    enum SortOrder: String {
        case newestFirst = "newest"
        case oldestFirst = "oldest"
    }
    
    // MARK: -
    
    init() {
        let key = "inbox.sortOrder"
        let savedSort = UserDefaults.standard.string(forKey: key) ?? SortOrder.newestFirst.rawValue
        
        _messages = FetchRequest(
            sortDescriptors: Self.sortDescriptors(for: SortOrder(rawValue: savedSort) ?? .newestFirst),
            predicate: nil,
            animation: .smooth
        )
    }
    
    var body: some View {
        let contentView = makeContentView()
        
        contentView
            .animation(.easeInOut, value: userNotifications.authorizationStatus)
            .animation(.easeInOut, value: userNotifications.isSuggestionHidden)
            .toolbar(content: makeToolbar)
            .navigationTitle("Notifications")
            .navigationBarTitleDisplayMode(.large)
            .onChange(of: sortOrder) {
                updateSortDescriptors()
            }
            .onChange(of: searchText) {
                updatePredicate()
            }
            .onAppear {
                updatePredicate()
            }
    }
    
    @ViewBuilder
    private func makeContentView() -> some View {
        ZStack {
            if messages.isEmpty && searchText.isEmpty {
                makeEmptyState()
            } else {
                makeListView()
            }
        }
    }
    
    @ViewBuilder
    private func makeListView() -> some View {
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
    
    private func updatePredicate() {
        if searchText.isEmpty {
            messages.nsPredicate = nil
        } else {
            messages.nsPredicate = NSPredicate(format: "title CONTAINS[cd] %@ OR subtitle CONTAINS[cd] %@", searchText, searchText)
        }
    }
    
    private func updateSortDescriptors() {
        messages.nsSortDescriptors = Self.sortDescriptors(for: SortOrder(rawValue: sortOrder) ?? .newestFirst)
        
    }
    
    private static func sortDescriptors(for order: SortOrder) -> [NSSortDescriptor] {
        switch order {
        case .newestFirst:
            return [NSSortDescriptor(key: "createdAt", ascending: false)]
        case .oldestFirst:
            return [NSSortDescriptor(key: "createdAt", ascending: true)]
        }
    }
}

extension InboxView {
    @ViewBuilder func makeEmptyState() -> some View {
        ScrollView {
            HStack {
                Image(systemName: "tray")
                    .font(.title2)
                    .foregroundStyle(.secondary)
                
                VStack(alignment: .leading) {
                    Text("Your inbox is empty")
                        .font(.headline)
                    Text("All your relevant notifications will be here.")
                        .font(.subheadline)
                }
                .frame(maxWidth: .infinity)
            }
            .padding()
            .background {
                RoundedRectangle(cornerRadius: 16)
                    .foregroundStyle(.ultraThinMaterial)
            }
            .padding(.horizontal)
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
                
                Divider()
                
                Menu("Sort", systemImage: "arrow.up.arrow.down") {
                    Button("Newest First", systemImage: sortOrder == SortOrder.newestFirst.rawValue ? "checkmark" : "") {
                        sortOrder = SortOrder.newestFirst.rawValue
                    }
                    
                    Button("Oldest First", systemImage: sortOrder == SortOrder.oldestFirst.rawValue ? "checkmark" : "") {
                        sortOrder = SortOrder.oldestFirst.rawValue
                    }
                }
            } label: {
                Image(systemName: "ellipsis")
            }
        }
    }
}

#Preview {
    InboxView()
}
