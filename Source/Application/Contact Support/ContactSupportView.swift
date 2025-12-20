import SwiftUI
import SwiftUIComponents

struct ContactSupportView: View, ComponentBuilder {
    @Environment(\.dismiss) var dismiss
    @State private var messageText = ""
    
    var body: some View {
        VStack(spacing: 0) {
            makeEmptyState()
            makeMessageInput()
        }
        .navigationTitle("Contact Support")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(content: makeToolbar)
    }
}

// MARK: - View Builder

extension ContactSupportView {
    @ViewBuilder func makeEmptyState() -> some View {
        ScrollView {
            VStack(spacing: 16) {
                HStack(alignment: .center) {
                    Image(systemName: "headphones")
                        .font(.title)
                        .foregroundStyle(.blue)
                    Text("Start a conversation with our support team. We're here to help with any questions or issues you may have.")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
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
    
    @ViewBuilder func makeMessageInput() -> some View {
        HStack(spacing: 12) {
            TextField("Type a message...", text: $messageText)
                .textFieldStyle(.automatic)
                .padding()
                .background {
                    RoundedRectangle(cornerRadius: 16)
                        .foregroundStyle(.thickMaterial)
                }
                .disabled(true)
            
            Button(action: {}) {
                Image(systemName: "paperplane.fill")
                    .foregroundStyle(.white)
                    .padding(8)
                    .background(.thickMaterial)
                    .clipShape(Circle())
            }
            .disabled(true)
        }
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
