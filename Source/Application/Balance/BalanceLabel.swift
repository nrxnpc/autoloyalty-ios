import SwiftUI

struct BalanceLabel: View {
    let points: Int
    let hasBackground: Bool
    let hasIcon: Bool
    let operation: Operation
    
    enum Operation {
        case none, income, outcome
        
        var prefix: String {
            switch self {
            case .none: return ""
            case .income: return "+"
            case .outcome: return "-"
            }
        }
        
        var color: Color {
            switch self {
            case .none: return .primary
            case .income: return .green
            case .outcome: return .red
            }
        }
    }
    
    init(points: Int, hasBackground: Bool = true, hasIcon: Bool = true, operation: Operation = .none) {
        self.points = points
        self.hasBackground = hasBackground
        self.hasIcon = hasIcon
        self.operation = operation
    }
    
    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 2) {
            Text("\(operation.prefix)\(points)")
                .foregroundColor(operation.color)
            if hasIcon {
                Image(systemName: "star.fill")
                    .foregroundColor(.orange)
            }
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 4)
        .background {
            if hasBackground {
                RoundedRectangle(cornerRadius: 6)
                    .foregroundStyle(.regularMaterial)
            }
        }
    }
}

#Preview {
    VStack {
        BalanceLabel(points: 100, operation: .income)
        BalanceLabel(points: 50, operation: .outcome)
        BalanceLabel(points: 100)
    }
}
