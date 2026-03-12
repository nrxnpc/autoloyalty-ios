import SwiftUI
import SwiftUIComponents
import NukeUI
import CoreData
import Dependencies

struct SweepstakesView: View {
    // MARK: - Dependencies
    
    @Dependency(\.scope) var scope
    @Environment(\.dismiss) var dismiss
    
    // MARK: - State
    
    @ObservedObject var sweepstake: Sweepstakes
    @State private var isEntering = false
    @State var balanceMonitor = BalanceMonitor()
    
    var canEnter: Bool {
        switch sweepstake.entryCondition {
        case .free:
            return true
        case .minPoints:
            return balanceMonitor.balance >= sweepstake.requiredValue
        case .minScans:
            return true // TODO: Check scan count
        }
    }
    
    // MARK: - Initialization
    
    init(sweepstake: Sweepstakes) {
        self.sweepstake = sweepstake
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                makeImagePreview()
                
                VStack(spacing: 16) {
                    makeTitle(sweepstake.title)
                    makeStatus()
                    makeEntryCondition()
                    makeDates()
                    makeDescription(sweepstake.promoDescription)
                    makePrizes()
                    Spacer(minLength: 100)
                }
                .padding()
            }
        }
        .ignoresSafeArea(edges: .top)
        .toolbar(content: makeToolbar)
    }
}

extension SweepstakesView {
    @ViewBuilder func makeImagePreview() -> some View {
        ZStack {
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
                                .font(.system(size: 32))
                                .foregroundColor(.gray)
                        }
                }
            }
        }
        .frame(height: 300)
        .clipped()
    }

    @ViewBuilder func makeTitle(_ title: String) -> some View {
        HStack {
            Text(title)
                .font(.largeTitle)
                .fontWeight(.bold)
                .multilineTextAlignment(.leading)
            Spacer()
        }
    }
    
    @ViewBuilder func makeStatus() -> some View {
        HStack {
            HStack(spacing: 4) {
                Image(systemName: sweepstake.status == .active ? "circle.fill" : "circle")
                    .font(.caption)
                    .foregroundStyle(sweepstake.status == .active ? .green : .gray)
                Text(statusText(sweepstake.status))
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(.ultraThinMaterial)
            .clipShape(Capsule())
            Spacer()
        }
    }
    
    @ViewBuilder func makeEntryCondition() -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Entry Requirement")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(entryConditionText())
                    .font(.headline)
            }
            Spacer()
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    @ViewBuilder func makeDates() -> some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Start Date")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(sweepstake.startDate, style: .date)
                    .font(.subheadline)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("End Date")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(sweepstake.endDate, style: .date)
                    .font(.subheadline)
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    @ViewBuilder func makeDescription(_ description: String) -> some View {
        HStack {
            Text(LocalizedStringKey(description))
                .font(.body)
                .multilineTextAlignment(.leading)
            Spacer()
        }
    }
    
    @ViewBuilder func makePrizes() -> some View {
        if !sweepstake.prizes.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                Text("Prizes")
                    .font(.headline)
                
                ForEach(Array(sweepstake.prizes), id: \.id) { prize in
                    HStack {
                        Image(systemName: "gift.fill")
                            .foregroundStyle(.orange)
                        Text(prize.name)
                            .font(.subheadline)
                        Spacer()
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
        }
    }
    
    private func statusText(_ status: Sweepstakes.Status) -> String {
        switch status {
        case .draft: return "Coming Soon"
        case .active: return "Active"
        case .finished: return "Finished"
        }
    }
    
    private func entryConditionText() -> String {
        switch sweepstake.entryCondition {
        case .free:
            return "Free Entry"
        case .minScans:
            return "\(sweepstake.requiredValue) Scans Required"
        case .minPoints:
            return "\(sweepstake.requiredValue) Points Required"
        }
    }
    
    private func enterSweepstakes() async {
        isEntering = true
        defer { isEntering = false }
        
        // TODO: Implement enter sweepstakes use case
        try? await Task.sleep(for: .seconds(1))
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        dismiss()
    }
    
    @ToolbarContentBuilder func makeToolbar() -> some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Button(action: dismiss.callAsFunction) {
                Image(systemName: "xmark")
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}
