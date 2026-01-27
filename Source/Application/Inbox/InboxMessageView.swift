import SwiftUI

struct InboxMessageView: View {
    // MARK: - Dependencies
    
    @Environment(\.dismiss) var dismiss
    let message: InboxMessage
    
    // MARK: -
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 0) {
                    Text(LocalizedStringKey(message.title))
                        .font(.title)
                    Text(DateFormatters.shared.day.string(from: message.createdAt))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Divider()
                Text(LocalizedStringKey(message.subtitle))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
        }
        .toolbar(content: makeToolbar)
        .onAppear {
            markAsRead()
        }
    }
    
    private func markAsRead() {
        guard message.wasReaded == false else {
            return
        }
        
        message.wasReaded = true
        try? message.managedObjectContext?.save()
    }
}

extension InboxMessageView {
    @ToolbarContentBuilder func makeToolbar() -> some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button(action: dismiss.callAsFunction) {
                Image(systemName: "xmark")
            }
        }
    }
}
