import SwiftUI

public extension Color {
    public init(hex: UInt, opacity: Double = 1) {
        func value(_ component: UInt) -> Double { Double(component & 0xFF) / 255.0 }
        self.init(.sRGB, red: value(hex >> 16), green: value(hex >> 08), blue: value(hex), opacity: opacity)
    }
}
