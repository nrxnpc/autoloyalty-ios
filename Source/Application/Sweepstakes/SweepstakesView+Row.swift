import SwiftUI
import NukeUI
import SwiftUIComponents

extension SweepstakesView {
    struct Row: View {
        let sweepstake: Sweepstakes
        
        var body: some View {
            ZStack(alignment: .bottomLeading) {
                makeImageBackground()
                makeGradientOverlay()
                makeContent()
            }
            .frame(height: 200)
            .clipShape(RoundedRectangle(cornerRadius: 24))
        }
    }
}

extension SweepstakesView.Row {
    @ViewBuilder func makeImageBackground() -> some View {
        LazyImage(url: sweepstake.images.first?.sourceURL) { state in
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
                        Image(systemName: "gift")
                            .font(.system(size: 48))
                            .foregroundColor(.gray)
                    }
            }
        }
    }
    
    @ViewBuilder func makeGradientOverlay() -> some View {
        LinearGradient(
            gradient: Gradient(colors: [
                .clear,
                .black.opacity(0.7)
            ]),
            startPoint: .top,
            endPoint: .bottom
        )
    }
    
    @ViewBuilder func makeContent() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                makeStatusBadge()
                Spacer()
                makeEntryConditionBadge()
            }
            
            Spacer()
            
            Text(sweepstake.title)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
            
            HStack(spacing: 4) {
                Image(systemName: "clock")
                    .font(.caption)
                Text("Ends \(sweepstake.endDate, style: .date)")
                    .font(.caption)
            }
            .foregroundColor(.white.opacity(0.9))
        }
        .padding()
    }
    
    @ViewBuilder func makeStatusBadge() -> some View {
        HStack(spacing: 4) {
            Image(systemName: sweepstake.status == .active ? "circle.fill" : "circle")
                .font(.caption2)
            Text(statusText)
                .font(.caption)
                .fontWeight(.medium)
        }
        .foregroundColor(.white)
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(
            sweepstake.status == .active ? Color.green.opacity(0.8) : Color.gray.opacity(0.8)
        )
        .clipShape(Capsule())
    }
    
    @ViewBuilder func makeEntryConditionBadge() -> some View {
        HStack(spacing: 4) {
            Image(systemName: entryConditionIcon)
                .font(.caption2)
            Text(entryConditionText)
                .font(.caption)
                .fontWeight(.medium)
        }
        .foregroundColor(.white)
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(Color.orange.opacity(0.8))
        .clipShape(Capsule())
    }
    
    private var statusText: String {
        switch sweepstake.status {
        case .draft: return "Coming Soon"
        case .active: return "Active"
        case .finished: return "Finished"
        }
    }
    
    private var entryConditionIcon: String {
        switch sweepstake.entryCondition {
        case .free: return "gift"
        case .minScans: return "qrcode"
        case .minPoints: return "star.fill"
        }
    }
    
    private var entryConditionText: String {
        switch sweepstake.entryCondition {
        case .free:
            return "Free"
        case .minScans:
            return "\(sweepstake.requiredValue) Scans"
        case .minPoints:
            return "\(sweepstake.requiredValue) Points"
        }
    }
}

// MARK: - Paginator

extension SweepstakesView {
    struct Paginator: View {
        let sweepstakes: [Sweepstakes]
        let namespace: Namespace.ID
        let onTap: (Sweepstakes) -> Void
        
        @State private var currentIndex: Int = 0
        
        var body: some View {
            VStack(spacing: 12) {
                TabView(selection: $currentIndex) {
                    ForEach(Array(sweepstakes.enumerated()), id: \.element.id) { index, sweepstake in
                        Row(sweepstake: sweepstake)
                            .matchedTransitionSource(id: sweepstake.id, in: namespace)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                onTap(sweepstake)
                            }
                            .padding(.horizontal, 16)
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .frame(height: 200)
                
                if sweepstakes.count > 1 {
                    makePageIndicator()
                }
            }
        }
    }
}

extension SweepstakesView.Paginator {
    @ViewBuilder func makePageIndicator() -> some View {
        HStack(spacing: 8) {
            ForEach(0..<sweepstakes.count, id: \.self) { index in
                Circle()
                    .fill(currentIndex == index ? Color.primary : Color.primary.opacity(0.3))
                    .frame(width: 8, height: 8)
                    .animation(.easeInOut, value: currentIndex)
            }
        }
    }
}

#Preview {
    SweepstakesView.Row(sweepstake: Sweepstakes())
        .padding()
}
