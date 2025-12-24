import SwiftUI

struct OffersView: View {
    // MARK: - Dependencies
    
    @Environment(\.dismiss) private var dismiss
    @Environment(Main.Router.self) var router
    @Environment(Recommendations.self) var recommendations
    
    // MARK: -
    
    var body: some View {
        Group {
            makeEmptyState()
        }
        .navigationTitle("Offers")
        .toolbar(content: makeToolbar)
    }
}

extension OffersView {
    @ViewBuilder func makeEmptyState() -> some View {
        ScrollView {
            VStack(spacing: 16) {
                HStack(alignment: .center) {
                    Image(systemName: "heart.text.square")
                        .font(.title)
                        .foregroundStyle(.orange)
                    Text("Personalized offers will appear here as you interact with car recommendations and show your preferences")
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
    
    
    @ToolbarContentBuilder func makeToolbar() -> some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button(action: dismiss.callAsFunction) {
                Image(systemName: "xmark")
            }
        }
        
        ToolbarItem(placement: .topBarTrailing) {
            Menu {
                Text("Recommendations")
                Button("Reset", systemImage: "arrow.clockwise") {
                    recommendations.reset()
                }
            } label: {
                Image(systemName: "ellipsis")
            }
        }
    }
}

#Preview {
    NavigationView {
        OffersView()
    }
}
