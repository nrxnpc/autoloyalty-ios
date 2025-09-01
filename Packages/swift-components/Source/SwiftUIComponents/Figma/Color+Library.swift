import SwiftUI

#if canImport(UIKit)
import UIKit
#endif

// MARK: - Themed Color System

public extension Color {

    // MARK: - Text Colors
    
    /// Text color for major headings.
    /// - Light: #111111, Dark: #FFFFFF
    static var textHeader: Color { dynamicColor(light: 0x111111, dark: 0xFFFFFF) }
    
    /// The primary color for text content.
    /// - Light: #111111, Dark: #D1D1D1
    static var textPrimary: Color { dynamicColor(light: 0x111111, dark: 0xD1D1D1) }
    
    /// The secondary color for less important text.
    /// - Light: #8A8A8E, Dark: #C8C7CD
    static var textSecondary: Color { dynamicColor(light: 0x8A8A8E, dark: 0xC8C7CD) }
    
    /// The tertiary color for disabled or placeholder text.
    /// - Light: #C8C7CD, Dark: #A3A3A3
    static var textTertiary: Color { dynamicColor(light: 0xC8C7CD, dark: 0xA3A3A3) }
    
    /// A semantic color for labels, often aliasing primary text.
    static var textLabel: Color { .textPrimary } // Corrected
    
    /// A semantic color for "call to action" text, aliasing the accent color.
    static var textCallToAction: Color { .interactiveAccent } // Corrected

    // MARK: - Icon Colors

    /// The primary color for icons.
    /// - Light: #222222, Dark: #D1D1D1
    static var iconPrimary: Color { dynamicColor(light: 0x3E3E3E, dark: 0xD1D1D1) }
    
    /// The secondary color for less prominent icons.
    /// - Light: #3E3E3E, Dark: #858589
    static var iconSecondary: Color { dynamicColor(light: 0x858589, dark: 0x858589) }
    
    /// The color for icons within navigation elements.
    /// - Light: #858589, Dark: #808080
    static var iconNavigation: Color { dynamicColor(light: 0x222222, dark: 0x808080) }
    
    /// The tertiary color for icons, aliasing secondary as a placeholder.
    static var iconTertiary: Color { .iconSecondary } // Corrected
    
    /// The destructive color for icons.
    static var iconDestructive: Color { Color(hex: 0xFF3F42) }
    
    /// The done color for icons.
    static var iconDone: Color { Color(hex: 0x2DC200) }
    
    /// The chat send icon color empty .
    static var iconChatSentEmpty: Color { Color(hex: 0xB6B6B6) }
    
    /// The chat send icon color .
    static var iconChatSentNonEmpty: Color { .blue }

    // MARK: - Background Colors
    
    /// The primary background color for screens and views.
    /// - Light: #FFFFFF, Dark: #191919
    static var backgroundPrimary: Color { dynamicColor(light: 0xFFFFFF, dark: 0x191919) }
    
    /// The secondary background color, for grouped content or cards.
    /// - Light: #F3F3F3, Dark: #252525
    static var backgroundSecondary: Color { dynamicColor(light: 0xF3F3F3, dark: 0x252525) }
    
    /// A tertiary background color.
    /// - Light: #EAEAEA, Dark: #333333
    static var backgroundTertiary: Color { dynamicColor(light: 0xEAEAEA, dark: 0x333333) }
    
    /// A tertiary background color.
    /// - Light: #EAEAEA, Dark: #333333
    static var backgroundChat: Color { dynamicColor(light: 0xEAEAEA, dark: 0x333333) }
    
    /// A quaternary background color.
    /// - Light: #E1E1E1, Dark: #404040
    static var backgroundQuaternary: Color { dynamicColor(light: 0xE1E1E1, dark: 0x404040) }
    

    // MARK: - Interactive Colors
    
    /// The main accent color for controls and actions.
    /// - Light: #007AFF, Dark: #FF594B
    static var interactiveAccent: Color { dynamicColor(light: 0x007AFF, dark: 0xFF594B) }
    
    /// An alternative interactive color, often for destructive or special actions.
    /// - Light: #FF594B, Dark: #449EFF
    static var interactiveMain: Color { dynamicColor(light: 0xFF594B, dark: 0x449EFF) }

    // MARK: - Private DRY Helper

    /// Creates a dynamic `Color` that resolves to a different hex value for light and dark modes.
    private static func dynamicColor(light: UInt, dark: UInt) -> Color {
#if canImport(UIKit)
        let uiColor = UIColor { traitCollection in
            if traitCollection.userInterfaceStyle == .dark {
                return UIColor(Color(hex: dark))
            } else {
                return UIColor(Color(hex: light))
            }
        }
        return Color(uiColor)
#else
        // Fallback for macOS - just return light color
        return Color(hex: light)
#endif
    }
}
