import SwiftUI

struct BalanceLabel: View {
    let points: Int
    let hasBackground: Bool
    
    init(points: Int, hasBackground: Bool = true) {
        self.points = points
        self.hasBackground = hasBackground
    }
    
    var body: some View {
        ZStack {
            HStack(alignment: .firstTextBaseline, spacing: 2) {
                Text("\(points)")
                if hasBackground {
                    Image(systemName: "star.fill")
                        .foregroundColor(.orange)
                }
            }
            .padding(.horizontal, 6)
            .padding(.vertical, 4)
        }
        .background {
            if hasBackground {
                RoundedRectangle(cornerRadius: 6)
                    .foregroundStyle(.regularMaterial)
            }
        }
    }
}

#Preview {
    BalanceLabel(points: 100000)
}
