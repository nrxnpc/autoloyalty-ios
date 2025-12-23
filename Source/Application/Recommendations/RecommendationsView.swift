import SwiftUI
import SwiftUIComponents

struct RecommendationsView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            VStack {
                RoundedRectangle(cornerRadius: 16)
                    .foregroundStyle(.ultraThinMaterial)
                    .aspectRatio(1/1.4, contentMode: .fit)
                    .padding()
                Spacer()
            }
        }
        .toolbar(content: makeToolbar)
    }
}

extension RecommendationsView {
    @ToolbarContentBuilder func makeToolbar() -> some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button(action: dismiss.callAsFunction) {
                Image(systemName: "xmark")
            }
        }
    }
}
