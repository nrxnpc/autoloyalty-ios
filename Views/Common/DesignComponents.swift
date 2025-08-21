import SwiftUI

// MARK: - Modern Card Component

struct ModernCard<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .padding(DesignSystem.Spacing.medium)
            .background(DesignSystem.Colors.cardBackground)
            .cornerRadius(DesignSystem.CornerRadius.medium)
            .shadow(
                color: DesignSystem.Shadow.small.color,
                radius: DesignSystem.Shadow.small.radius,
                x: DesignSystem.Shadow.small.x,
                y: DesignSystem.Shadow.small.y
            )
    }
}

// MARK: - Modern Button Styles

struct PrimaryButton: View {
    let title: String
    let action: () -> Void
    let isLoading: Bool
    let isDisabled: Bool
    
    init(_ title: String, isLoading: Bool = false, isDisabled: Bool = false, action: @escaping () -> Void) {
        self.title = title
        self.action = action
        self.isLoading = isLoading
        self.isDisabled = isDisabled
    }
    
    var body: some View {
        Button(action: action) {
            HStack {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.8)
                }
                
                Text(title)
                    .font(DesignSystem.Typography.bodyMedium)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, DesignSystem.Spacing.medium)
            .background(isDisabled ? DesignSystem.Colors.border : DesignSystem.Colors.primary)
            .foregroundColor(.white)
            .cornerRadius(DesignSystem.CornerRadius.medium)
        }
        .disabled(isDisabled || isLoading)
        .animation(DesignSystem.Animation.quick, value: isLoading)
    }
}

struct SecondaryButton: View {
    let title: String
    let action: () -> Void
    
    init(_ title: String, action: @escaping () -> Void) {
        self.title = title
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(DesignSystem.Typography.bodyMedium)
                .frame(maxWidth: .infinity)
                .padding(.vertical, DesignSystem.Spacing.medium)
                .background(DesignSystem.Colors.secondary)
                .foregroundColor(DesignSystem.Colors.primary)
                .cornerRadius(DesignSystem.CornerRadius.medium)
                .overlay(
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
                        .stroke(DesignSystem.Colors.primary, lineWidth: 1)
                )
        }
    }
}

// MARK: - Modern Status Badge

struct ModernStatusBadge: View {
    let text: String
    let color: Color
    
    var body: some View {
        Text(text)
            .font(DesignSystem.Typography.caption)
            .fontWeight(.medium)
            .padding(.horizontal, DesignSystem.Spacing.small)
            .padding(.vertical, DesignSystem.Spacing.xs)
            .background(color.opacity(0.1))
            .foregroundColor(color)
            .cornerRadius(DesignSystem.CornerRadius.small)
    }
}

// MARK: - Points Display

struct PointsDisplay: View {
    let points: Int
    let size: Size
    
    enum Size {
        case small, medium, large
        
        var font: Font {
            switch self {
            case .small: return DesignSystem.Typography.caption
            case .medium: return DesignSystem.Typography.headline
            case .large: return DesignSystem.Typography.title2
            }
        }
        
        var iconSize: CGFloat {
            switch self {
            case .small: return 12
            case .medium: return 16
            case .large: return 24
            }
        }
    }
    
    var body: some View {
        HStack(spacing: DesignSystem.Spacing.xs) {
            Image(systemName: "star.fill")
                .font(.system(size: size.iconSize))
                .foregroundColor(DesignSystem.Colors.accent)
            
            Text("\(points)")
                .font(size.font)
                .fontWeight(.semibold)
                .foregroundColor(DesignSystem.Colors.text)
        }
    }
}

// MARK: - Level Badge

struct LevelBadge: View {
    let tierName: String
    let points: Int
    
    private var levelInfo: (name: String, color: Color, icon: String) {
        switch points {
        case 0..<5000:
            return ("Бронза", Color.brown, "star.fill")
        case 5000..<15000:
            return ("Серебро", Color.gray, "star.fill")
        default:
            return ("Золото", Color.yellow, "star.fill")
        }
    }
    
    var body: some View {
        HStack(spacing: DesignSystem.Spacing.xs) {
            Image(systemName: levelInfo.icon)
                .font(.system(size: 12))
                .foregroundColor(levelInfo.color)
            
            Text(levelInfo.name)
                .font(DesignSystem.Typography.caption)
                .fontWeight(.medium)
                .foregroundColor(levelInfo.color)
        }
        .padding(.horizontal, DesignSystem.Spacing.small)
        .padding(.vertical, DesignSystem.Spacing.xs)
        .background(levelInfo.color.opacity(0.1))
        .cornerRadius(DesignSystem.CornerRadius.small)
    }
}

// MARK: - Modern Search Bar

struct ModernSearchBar: View {
    @Binding var text: String
    let placeholder: String
    
    init(text: Binding<String>, placeholder: String = "Поиск...") {
        self._text = text
        self.placeholder = placeholder
    }
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(DesignSystem.Colors.secondaryText)
            
            TextField(placeholder, text: $text)
                .font(DesignSystem.Typography.body)
            
            if !text.isEmpty {
                Button(action: { text = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(DesignSystem.Colors.secondaryText)
                }
            }
        }
        .padding(DesignSystem.Spacing.medium)
        .background(DesignSystem.Colors.secondaryBackground)
        .cornerRadius(DesignSystem.CornerRadius.medium)
    }
}

// MARK: - Empty State View

struct EmptyStateView: View {
    let icon: String
    let title: String
    let description: String
    let actionTitle: String?
    let action: (() -> Void)?
    
    init(icon: String, title: String, description: String, actionTitle: String? = nil, action: (() -> Void)? = nil) {
        self.icon = icon
        self.title = title
        self.description = description
        self.actionTitle = actionTitle
        self.action = action
    }
    
    var body: some View {
        VStack(spacing: DesignSystem.Spacing.large) {
            Image(systemName: icon)
                .font(.system(size: 48))
                .foregroundColor(DesignSystem.Colors.secondaryText)
            
            VStack(spacing: DesignSystem.Spacing.small) {
                Text(title)
                    .font(DesignSystem.Typography.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(DesignSystem.Colors.text)
                
                Text(description)
                    .font(DesignSystem.Typography.body)
                    .foregroundColor(DesignSystem.Colors.secondaryText)
                    .multilineTextAlignment(.center)
            }
            
            if let actionTitle = actionTitle, let action = action {
                PrimaryButton(actionTitle, action: action)
                    .frame(maxWidth: 200)
            }
        }
        .padding(DesignSystem.Spacing.xl)
    }
}

// MARK: - Loading View

struct LoadingView: View {
    let message: String
    
    init(_ message: String = "Загрузка...") {
        self.message = message
    }
    
    var body: some View {
        VStack(spacing: DesignSystem.Spacing.medium) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: DesignSystem.Colors.primary))
                .scaleEffect(1.2)
            
            Text(message)
                .font(DesignSystem.Typography.body)
                .foregroundColor(DesignSystem.Colors.secondaryText)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(DesignSystem.Colors.background)
    }
}

// MARK: - Section Header

struct SectionHeader: View {
    let title: String
    let subtitle: String?
    let action: (() -> Void)?
    let actionTitle: String?
    
    init(_ title: String, subtitle: String? = nil, actionTitle: String? = nil, action: (() -> Void)? = nil) {
        self.title = title
        self.subtitle = subtitle
        self.actionTitle = actionTitle
        self.action = action
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                Text(title)
                    .font(DesignSystem.Typography.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(DesignSystem.Colors.text)
                
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(DesignSystem.Typography.caption)
                        .foregroundColor(DesignSystem.Colors.secondaryText)
                }
            }
            
            Spacer()
            
            if let actionTitle = actionTitle, let action = action {
                Button(action: action) {
                    Text(actionTitle)
                        .font(DesignSystem.Typography.callout)
                        .foregroundColor(DesignSystem.Colors.primary)
                }
            }
        }
    }
}