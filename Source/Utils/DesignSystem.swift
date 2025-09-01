import SwiftUI

// MARK: - Design System

struct DesignSystem {
    
    // MARK: - Colors
    struct Colors {
        // Primary Brand Colors
        static let primary = Color(red: 0.2, green: 0.4, blue: 0.8)        // Синий #3366CC
        static let primaryLight = Color(red: 0.4, green: 0.6, blue: 0.9)   // Светло-синий
        static let primaryDark = Color(red: 0.1, green: 0.2, blue: 0.6)    // Темно-синий
        
        // Secondary Colors
        static let secondary = Color(red: 0.95, green: 0.95, blue: 0.97)   // Светло-серый
        static let accent = Color(red: 1.0, green: 0.6, blue: 0.0)         // Оранжевый
        
        // Status Colors
        static let success = Color(red: 0.2, green: 0.7, blue: 0.3)        // Зеленый
        static let warning = Color(red: 1.0, green: 0.7, blue: 0.0)        // Желтый
        static let error = Color(red: 0.9, green: 0.2, blue: 0.2)          // Красный
        static let info = Color(red: 0.3, green: 0.7, blue: 1.0)           // Голубой
        
        // Neutral Colors
        static let background = Color(UIColor.systemBackground)
        static let secondaryBackground = Color(UIColor.secondarySystemBackground)
        static let tertiaryBackground = Color(UIColor.tertiarySystemBackground)
        
        static let text = Color(UIColor.label)
        static let secondaryText = Color(UIColor.secondaryLabel)
        static let tertiaryText = Color(UIColor.tertiaryLabel)
        
        static let separator = Color(UIColor.separator)
        static let border = Color(UIColor.systemGray4)
        
        // Card Colors
        static let cardBackground = Color.white
        static let cardShadow = Color.black.opacity(0.1)
    }
    
    // MARK: - Typography
    struct Typography {
        static let largeTitle = Font.largeTitle.weight(.bold)
        static let title1 = Font.title.weight(.semibold)
        static let title2 = Font.title2.weight(.semibold)
        static let title3 = Font.title3.weight(.medium)
        static let headline = Font.headline.weight(.medium)
        static let body = Font.body
        static let bodyMedium = Font.body.weight(.medium)
        static let callout = Font.callout
        static let subheadline = Font.subheadline
        static let footnote = Font.footnote
        static let caption = Font.caption
        static let caption2 = Font.caption2
    }
    
    // MARK: - Spacing
    struct Spacing {
        static let xs: CGFloat = 4
        static let small: CGFloat = 8
        static let medium: CGFloat = 16
        static let large: CGFloat = 24
        static let xl: CGFloat = 32
        static let xxl: CGFloat = 48
    }
    
    // MARK: - Corner Radius
    struct CornerRadius {
        static let small: CGFloat = 8
        static let medium: CGFloat = 12
        static let large: CGFloat = 16
        static let xl: CGFloat = 24
    }
    
    // MARK: - Shadows
    struct Shadow {
        static let small = (color: Colors.cardShadow, radius: CGFloat(4), x: CGFloat(0), y: CGFloat(2))
        static let medium = (color: Colors.cardShadow, radius: CGFloat(8), x: CGFloat(0), y: CGFloat(4))
        static let large = (color: Colors.cardShadow, radius: CGFloat(16), x: CGFloat(0), y: CGFloat(8))
    }
    
    // MARK: - Animation
    struct Animation {
        static let quick = SwiftUI.Animation.easeInOut(duration: 0.2)
        static let standard = SwiftUI.Animation.easeInOut(duration: 0.3)
        static let slow = SwiftUI.Animation.easeInOut(duration: 0.5)
    }
}

// MARK: - View Extensions

extension View {
    func cardStyle() -> some View {
        self
            .background(DesignSystem.Colors.cardBackground)
            .cornerRadius(DesignSystem.CornerRadius.medium)
            .shadow(
                color: DesignSystem.Shadow.small.color,
                radius: DesignSystem.Shadow.small.radius,
                x: DesignSystem.Shadow.small.x,
                y: DesignSystem.Shadow.small.y
            )
    }
    
    func primaryButtonStyle() -> some View {
        self
            .font(DesignSystem.Typography.bodyMedium)
            .foregroundColor(.white)
            .padding(.horizontal, DesignSystem.Spacing.large)
            .padding(.vertical, DesignSystem.Spacing.medium)
            .background(DesignSystem.Colors.primary)
            .cornerRadius(DesignSystem.CornerRadius.medium)
    }
    
    func secondaryButtonStyle() -> some View {
        self
            .font(DesignSystem.Typography.bodyMedium)
            .foregroundColor(DesignSystem.Colors.primary)
            .padding(.horizontal, DesignSystem.Spacing.large)
            .padding(.vertical, DesignSystem.Spacing.medium)
            .background(DesignSystem.Colors.secondary)
            .cornerRadius(DesignSystem.CornerRadius.medium)
            .overlay(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
                    .stroke(DesignSystem.Colors.primary, lineWidth: 1)
            )
    }
}

