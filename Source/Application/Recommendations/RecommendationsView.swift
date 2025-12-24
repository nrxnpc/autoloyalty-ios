import SwiftUI
import SwiftUIComponents
import Nuke
import NukeUI
import CoreData

struct RecommendationsView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.managedObjectContext) private var context
    @Environment(Recommendations.self) var recommendations
    
    @State var selectedCard: CarRecommendation?
    @State var popTrigger: CardSwipeDirection?
    
    @FetchRequest var recommendationSet: FetchedResults<CarRecommendation>
    init() {
        _recommendationSet = FetchRequest(fetchRequest: CarRecommendation.all(), animation: .smooth)
    }
    
    var body: some View {
        @Bindable var recommendations = recommendations
        VStack {
            if recommendations.isEmpty {
                emptyView
            } else {
                makeStackView()
            }
            Spacer()
        }
        .interactiveDismissDisabled()
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
                recommendations.reset()
            }
            .font(.headline)
            .frame(width: 200, height: 50)
            .background(Color.accentColor)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
    }
}

extension RecommendationsView {
    @ViewBuilder func makeStackView() -> some View {
        FetchedCardSwipeView(fetchedResults: recommendationSet, selectedItem: $selectedCard, popTrigger: $popTrigger) { recommendation, progress, direction in
            CarCardView(recommendation: recommendation, progress: progress, direction: direction, compact: false)
        }
        .configure(cardSpacing: 16)
        .onSwipeEnd { card, direction in
            recommendations.removeCard(card)
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        }
        .onNoMoreCardsLeft {
            // Cards finished
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
        }
        
        ToolbarItem(placement: .topBarTrailing) {
            Menu {
                Button("Reset", systemImage: "arrow.clockwise") {
                    recommendations.reset()
                }
            } label: {
                Image(systemName: "ellipsis")
                    .contentShape(Rectangle())
            }
        }
        
        ToolbarItemGroup(placement: .bottomBar) {
            Button {
                
            } label: {
                Image(systemName: "xmark")
                    .foregroundStyle(.red)
            }
            
            Button {
                
            } label: {
                Image(systemName: "checkmark")
                    .foregroundStyle(.green)
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
                .background(.ultraThinMaterial)
            }
        }
    }
    
    @ViewBuilder func makeImagePreview() -> some View {
        ZStack {
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
            .background {
                RoundedRectangle(cornerRadius: 6)
                    .foregroundStyle(.ultraThinMaterial)
            }
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

