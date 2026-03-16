import SwiftUI
import SwiftUIComponents

// MARK: - View Builder

extension FeedView {
    // MARK: - Recommendations Section
    
    @ViewBuilder func makeRecommendationsSection() -> some View {
        VStack(alignment: .leading, spacing: 16) {
            makeRecommendationsHeader()
                .padding(.leading, 16)
                .padding(.horizontal)
            
            ZStack {
                RecommendationsView.Compact(recommendationSet: recommendationSet) {
                    router.route(fullScreen: .recommendations(namespace, recommendationSet))
                }
                .padding(.horizontal, 16)
                .aspectRatio(1/0.8, contentMode: .fit)
            }
            .onTapGesture {
                router.route(fullScreen: .recommendations(namespace, recommendationSet))
            }
        }
        .matchedTransitionSource(id: "recommendations", in: namespace)
    }
    
    @ViewBuilder func makeRecommendationsHeader() -> some View {
        HStack {
            Text(recommendationPrompts)
                .font(.title2.weight(.semibold))
            
            Spacer()
        }
        .foregroundStyle(.primary)
    }
}

// MARK: - View Builder

extension FeedView {
    // MARK: - Sweepstakes Section
    
    @ViewBuilder func makeSweepstakesSection(_ sweepstakes: [Sweepstakes]) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            makeSweepstakesHeader()
                .padding(.leading, 16)
                .padding(.horizontal)
            
            ZStack {
                SweepstakesView.Paginator(sweepstakes: sweepstakes, namespace: namespace) { sweepstake in
                    router.route(sheet: .sweepstakesDetails(sweepstake, namespace))
                }
            }
        }
    }
    
    @ViewBuilder func makeSweepstakesHeader() -> some View {
        HStack {
            Text("Sweepstakes")
                .font(.title2.weight(.semibold))
            
            Spacer()
        }
        .foregroundStyle(.primary)
    }
}
extension FeedView {
    // MARK: - Auto Mind Section
    
    @ViewBuilder func makeAutoMindSection() -> some View {
        VStack(alignment: .leading, spacing: 16) {
            makeAutoMindHeader()
                .padding(.leading, 16)
            
            ZStack {
                Text("I can guess any car you're thinking of in 10 questions or less!")
                    .font(.headline)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(16)
            }
            .background {
                RoundedRectangle(cornerRadius: 32)
                    .foregroundStyle(.ultraThinMaterial)
            }
            .padding(.horizontal)
            .onTap {
                router.route(sheet: .akinator(namespace))
            }
        }
        .matchedTransitionSource(id: "akinator", in: namespace)
        .padding(.vertical)
    }
    
    @ViewBuilder func makeAutoMindHeader() -> some View {
        HStack {
            Text(autoMindPrompts)
                .font(.title2.weight(.semibold))
            
            Spacer()
        }
        .foregroundStyle(.primary)
    }
}
