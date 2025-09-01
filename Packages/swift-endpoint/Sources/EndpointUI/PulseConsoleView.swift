import SwiftUI
#if os(iOS) || os(macOS) || os(tvOS) || os(watchOS) || os(visionOS)
import Pulse
import PulseUI

/// A SwiftUI wrapper for PulseUI's ConsoleView.
/// Provides network debugging interface for development and testing.
public struct PulseConsoleView: View {
    public init() {}
    public var body: some View {
        ConsoleView()
    }
}
#else
public struct PulseConsoleView: View {
    public init() {}
    public var body: some View {
        EmptyView()
    }
}
#endif
