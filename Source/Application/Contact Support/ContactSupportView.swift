import SwiftUI
import SwiftUIComponents

struct ContactSupportView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            Text("Contact Support")
        }
        .toolbar(content: makeToolbar)
    }
}

// MARK: - View Builder

extension ContactSupportView {
    /// Builds the toolbar items, including the dynamic "Save" button.
    @ToolbarContentBuilder func makeToolbar() -> some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button(action: dismiss.callAsFunction) {
                Image(systemName: "xmark")
            }
        }
    }
}
