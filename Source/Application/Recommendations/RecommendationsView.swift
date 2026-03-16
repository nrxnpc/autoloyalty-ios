import SwiftUI
import SwiftUIComponents
import Nuke
import NukeUI
import CoreData

struct RecommendationsView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(Recommendations.self) var recommendations
    
    @State var selectedCard: CarRecommendation?
    @State var popTrigger: CardSwipeDirection?
    
    let recommendationSet: FetchedResults<CarRecommendation>
    @State private var showCompletionState = false
    
    var body: some View {
        @Bindable var recommendations = recommendations
        VStack {
            if recommendationSet.isEmpty || showCompletionState  {
                makeEmptyState()
            } else {
                makeStackView()
            }
            Spacer()
        }
        .animation(.smooth, value: [showCompletionState, recommendationSet.isEmpty])
        .interactiveDismissDisabled()
        .toolbar(content: makeToolbar)
    }
}

extension RecommendationsView {
    @ViewBuilder func makeEmptyState() -> some View {
        ScrollView {
            VStack(spacing: 20) {
                Image(systemName: "heart.text.square")
                    .font(.system(size: 60))
                    .foregroundStyle(.orange)
                
                VStack(spacing: 12) {
                    Text("That's all for today!")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text("Keep exploring cars you love - we'll send you exclusive offers based on your preferences")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                
                Button("Review Recommendations Again", systemImage: "arrow.clockwise") {
                    recommendations.reset {
                        showCompletionState = false
                    }
                }
                .font(.callout)
                .foregroundStyle(.secondary)
            }
            .padding()
        }
    }
    
    @ViewBuilder func makeStackView() -> some View {
        FetchedCardSwipeView(fetchedResults: recommendationSet, selectedItem: $selectedCard, popTrigger: $popTrigger) { recommendation, progress, direction in
            CarCardView(recommendation: recommendation, progress: progress, direction: direction, compact: false)
        }
        .configure(cardSpacing: 16)
        .onSwipeEnd { card, direction in
            Task {
                switch direction {
                case .left:
                    try await recommendations.feedback(recommendation: card.id, sentiment: .reject)
                case .right:
                    try  await recommendations.feedback(recommendation: card.id, sentiment: .accept)
                case .idle: break
                }
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            }
        }
        .onNoMoreCardsLeft {
            showCompletionState = true
        }
        .aspectRatio(1/1.6, contentMode: .fit)
        .padding(.horizontal, 16)
        .padding(.bottom, 32)
    }
    
    @ToolbarContentBuilder func makeToolbar() -> some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button(action: dismiss.callAsFunction) {
                Image(systemName: "xmark")
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        
        ToolbarItem(placement: .topBarTrailing) {
            Menu {
                Button("Reset", systemImage: "arrow.clockwise") {
                    recommendations.reset {
                        showCompletionState = false
                    }
                }
            } label: {
                Image(systemName: "ellipsis")
                    .contentShape(Rectangle())
            }
        }
        
        if !showCompletionState {
            ToolbarItemGroup(placement: .bottomBar) {
                Button {
                    if let card = selectedCard {
                        popTrigger = .left
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        Task {
                            do {
                                try await recommendations.feedback(recommendation: card.id, sentiment: .reject)
                            } catch {
                                UINotificationFeedbackGenerator().notificationOccurred(.error)
                            }
                        }
                    }
                } label: {
                    Image(systemName: "xmark")
                        .font(.headline)
                        .foregroundStyle(.red)
                        .frame(width: 44, height: 44)
                        .contentShape(Rectangle())
                }
                .disabled(selectedCard == nil)
                
                Button {
                    if let card = selectedCard {
                        popTrigger = .right
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        Task {
                            do {
                                try await recommendations.feedback(recommendation: card.id, sentiment: .accept)
                            } catch {
                                UINotificationFeedbackGenerator().notificationOccurred(.error)
                            }
                        }
                    }
                } label: {
                    Image(systemName: "checkmark")
                        .font(.headline)
                        .foregroundStyle(.green)
                        .frame(width: 44, height: 44)
                        .contentShape(Rectangle())
                }
                .disabled(selectedCard == nil)
            }
        }
    }
}

struct CarCardView: View {
    let recommendation: CarRecommendation
    let progress: CGFloat
    let direction: CardSwipeDirection
    let compact: Bool
    
    var body: some View {
        ZStack(alignment: .bottom) {
            makePreview()
        }
        .modifier(DefaultBackgroundStyle())
        .cornerRadius(32)
        .shadow(radius: 2, y: 2)
        .overlay(alignment: direction == .left ? .topTrailing : .topLeading) {
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
            VStack(spacing: 0) {
                makeImagePreview()
                VStack(alignment: .leading, spacing: 8) {
                    makeHeadlineRow()
                    if !compact {
                        makeSpecificationsRow()
                        
                        if !recommendation.carDescription.isEmpty {
                            makeDescriptionRow()
                        }
                    }
                }
                .padding()
            }
        }
    }
    
    @ViewBuilder func makeImagePreview() -> some View {
        LazyImage(url: recommendation.imageURL) { state in
            if let image = state.image {
                GeometryReader { geometry in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .clipped()
                }
            } else {
                Rectangle()
                    .fill(.gray.opacity(0.3))
                    .overlay {
                        Image(systemName: "car")
                            .font(.system(size: 40))
                            .foregroundColor(.gray)
                    }
            }
        }
    }
    
    @ViewBuilder func makeHeadlineRow() -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(alignment: .firstTextBaseline) {
                Text(recommendation.brand)
                    .font(.title2.weight(.semibold))
                    .foregroundColor(.primary)
                Text(recommendation.model)
                    .font(.headline.weight(.semibold))
                    .foregroundColor(.secondary)
                
                Spacer()
                
                if compact {
                    makeYearLabel()
                }
            }
            
            if !compact {
                makeYearLabel()
            }
        }
    }
    
    @ViewBuilder func makeYearLabel() -> some View {
        Text(String(recommendation.year))
            .font(.caption)
            .fontWeight(.semibold)
            .foregroundColor(.primary)
            .padding(.vertical, 6)
            .padding(.horizontal, 8)
            .modifier(DefaultBackgroundStyle())
    }
    
    @ViewBuilder func makeDescriptionRow() -> some View {
        Text(recommendation.carDescription)
            .font(.caption)
            .foregroundColor(.secondary)
    }
    
    @ViewBuilder func makeSpecificationsRow() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            specItem("engine.combustion", recommendation.engine)
            
            LazyVGrid(columns: [GridItem(.flexible(), alignment: .centerFirstTextBaseline), GridItem(.flexible(), alignment: .centerFirstTextBaseline)], spacing: 8) {
                specItem("fuelpump", recommendation.fuelType)
                specItem("gearshift.layout.sixspeed", recommendation.transmission)
                //specItem("gearshape.2", recommendation.drivetrain)
                //specItem("car.side", recommendation.bodyType)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(.ultraThinMaterial)
        .cornerRadius(6)
    }
    
    private func specItem(_ icon: String, _ value: String) -> some View {
        HStack(alignment: .center, spacing: 6) {
            Image(systemName: icon)
                .font(.caption)
                .frame(width: 16)
                .foregroundStyle(.secondary)
                .scaleEffect(.init(width: 0.8, height: 0.8))
            Text(value)
                .font(.caption)
                .foregroundColor(.primary)
            Spacer()
        }
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

