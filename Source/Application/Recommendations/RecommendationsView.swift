import SwiftUI
import SwiftUIComponents
import CoreData

struct RecommendationsView: View {
    @Environment(\.dismiss) var dismiss
    @FetchRequest var recommendations: FetchedResults<CarRecommendation>
    @State private var cards: [CarRecommendation] = []
    @State private var selectedCard: CarRecommendation?
    @State private var popTrigger: CardSwipeDirection?
    
    init() {
        _recommendations = FetchRequest(fetchRequest: CarRecommendation.all())
    }
    
    var body: some View {
        VStack {
            if recommendations.isEmpty {
                emptyView
            } else {
                CardSwipeView(items: $cards, selectedItem: $selectedCard, popTrigger: $popTrigger) { recommendation, progress, direction in
                    CarCardView(recommendation: recommendation, progress: progress, direction: direction)
                }
                .configure(threshold: 150, minimumDistance: 20, animateOnYAxes: false)
                .onSwipeEnd { card, direction in
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                }
                .onNoMoreCardsLeft {
                    // Cards finished
                }
                .aspectRatio(1/1.4, contentMode: .fit)
                .padding(32)
            }
            Spacer()
        }
        .interactiveDismissDisabled()
        .onAppear {
            cards = Array(recommendations)
        }
        .toolbar(content: makeToolbar)
    }
    
    private var emptyView: some View {
        VStack {
            Text("No recommendations")
                .font(.title)
                .foregroundStyle(.gray)
        }
    }
    
    private var completionView: some View {
        VStack {
            Text("All cards viewed")
                .font(.title)
                .padding(.bottom, 20)
            
            Button("Reset") {
                cards = Array(recommendations)
            }
            .font(.headline)
            .frame(width: 200, height: 50)
            .background(Color.accentColor)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
    }
}

struct CarCardView: View {
    let recommendation: CarRecommendation
    let progress: CGFloat
    let direction: CardSwipeDirection
    
    var body: some View {
        ZStack(alignment: .bottom) {
            makePreview()
        }
        .background(.ultraThinMaterial)
        .cornerRadius(32)
        .shadow(radius: 8)
        .overlay(alignment: .topTrailing) {
            if direction != .idle {
                Text(direction == .left ? "NOPE" : "LIKE")
                    .font(.title.weight(.bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(direction == .left ? .red : .green)
                    .cornerRadius(8)
                    .rotationEffect(.degrees(direction == .left ? -30 : 30))
                    .opacity(progress)
                    .padding()
            }
        }
    }
    
    @ViewBuilder func makePreview() -> some View {
        ZStack {
            makeImagePreview()
            
            VStack {
                Spacer()
                VStack(alignment: .leading) {
                    makeHeadlineRow()
                    makeSpecificatoinsRow()
                }
                .padding()
                .background(.ultraThinMaterial)
            }
        }
    }
    
    @ViewBuilder func makeImagePreview() -> some View {
        AsyncImage(url: recommendation.imageURL) { image in
            image
                .resizable()
                .aspectRatio(contentMode: .fill)
        } placeholder: {
            Rectangle()
                .fill(.gray.opacity(0.3))
                .overlay {
                    Image(systemName: "car")
                        .font(.system(size: 40))
                        .foregroundColor(.gray)
                }
        }
        .clipped()
    }
    
    @ViewBuilder func makeHeadlineRow() -> some View {
        HStack(alignment: .firstTextBaseline) {
            Text(recommendation.brand)
                .font(.title2.weight(.semibold))
                .foregroundColor(.primary)
            Text(recommendation.model)
                .font(.headline.weight(.semibold))
                .foregroundColor(.secondary)
            
            Spacer()
        }
    }
    
    @ViewBuilder func makeSpecificatoinsRow() -> some View {
        HStack {
            if recommendation.year != 0 {
                Text(String(recommendation.year))
                    .font(.subheadline)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(.ultraThinMaterial)
                    .cornerRadius(6)
            }
            
            if !recommendation.engine.isEmpty {
                HStack(spacing: 4) {
                    Image(systemName: "engine.combustion")
                    Text(recommendation.engine)
                }
                .font(.subheadline)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(.ultraThinMaterial)
                .cornerRadius(6)
            }
            
            Spacer()
        }
    }
    
    private func specItem(_ title: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption2)
                .foregroundColor(.secondary)
            Text(value)
                .font(.caption)
                .foregroundColor(.primary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(8)
        .background(.secondary.opacity(0.1))
        .cornerRadius(6)
    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
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
