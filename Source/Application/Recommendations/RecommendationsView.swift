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
                    // TODO: end
                }
                .aspectRatio(1/1.3, contentMode: .fit)
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
            Text("Нет рекомендаций")
                .font(.title)
                .foregroundStyle(.gray)
        }
    }
    
    private var completionView: some View {
        VStack {
            Text("Все карточки просмотрены")
                .font(.title)
                .padding(.bottom, 20)
            
            Button("Сбросить") {
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
        RoundedRectangle(cornerRadius: 16)
            .foregroundStyle(.ultraThinMaterial)
            .contentShape(Rectangle())
            .overlay {
                VStack(spacing: 16) {
                    Text("\(recommendation.brand) \(recommendation.model)")
                        .font(.title2.weight(.semibold))
                        .multilineTextAlignment(.center)
                    
                    Text("Год: \(recommendation.year)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    
                    Text(recommendation.price)
                        .font(.title3.weight(.medium))
                        .foregroundStyle(.primary)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Характеристики:")
                            .font(.headline)
                        
                        Text("Двигатель: \(recommendation.engine)")
                        Text("КПП: \(recommendation.transmission)")
                        Text("Топливо: \(recommendation.fuelType)")
                        Text("Кузов: \(recommendation.bodyType)")
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)
                }
                .padding()
            }
            .overlay(alignment: .topTrailing) {
                if direction != .idle {
                    Text(direction == .left ? "НЕТ" : "ДА")
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
            .shadow(radius: 8)
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
