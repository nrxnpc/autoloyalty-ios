import SwiftUI

public protocol ComponentBuilder: View {
    /// A protocol designed to provide a lightweight, declarative DSL for creating common UI components in SwiftUI.
    ///
    /// The core idea is to enable rapid UI construction by calling simple `Build...` methods
    /// from any `View` that conforms to the protocol. These components are intentionally decoupled
    /// from specific ViewModels, making them highly reusable across different screens like onboarding,
    /// settings, or feature introductions.
    ///
    ///## Usage
    ///
    /// To use the builder methods, conform your SwiftUI `View` to `ComponentBuilder`:
    ///
    /// ```swift
    /// struct OnboardingScreen: View, ComponentBuilder {
    ///     var body: some View {
    ///         BuildLayout {
    ///             // Main content
    ///             BuildImage("onboarding-hero")
    ///             BuildLargeTitle("Welcome to the App")
    ///             BuildSubtitle("Let's get you set up in a few simple steps.")
    ///         } bottom: {
    ///             // Bottom content
    ///             BuildContinueButton("Get Started", action: { /* ... */ })
    ///         }
    ///     }
    /// }
    /// ```
}

// MARK: - Usage Example
// MARK: - Layout

public extension ComponentBuilder {
    /// Creates a standard vertical layout that pins primary content to the top and secondary content to the bottom.
    ///
    /// This is ideal for screens that have a main content area and a fixed action bar at the bottom,
    /// such as onboarding or login screens.
    ///
    /// - Parameters:
    ///   - content: A `ViewBuilder` closure for the main content area, which will be at the top.
    ///   - bottom: A `ViewBuilder` closure for the content pinned to the bottom (e.g., action buttons).
    /// - Returns: A configured view representing the standard layout.
    @ViewBuilder public func MakePageLayout<Content: View, Bottom: View>(@ViewBuilder content: () -> Content, @ViewBuilder bottom: () -> Bottom) -> some View {
        VStack(spacing: 32) {
            content()
            Spacer()
            bottom()
        }
        .padding(.horizontal)
        .padding(.bottom)
    }
    
    /// Creates a compact vertical layout.
    /// - Note: Currently identical to `BuildLayout`. Consider differentiating its spacing or padding for more compact use cases.
    /// - Parameters:
    ///   - content: A `ViewBuilder` closure for the main content area.
    ///   - bottom: A `ViewBuilder` closure for the bottom content area.
    /// - Returns: A configured view representing the compact layout.
    @ViewBuilder public func MakeCompactPageLayout<Content: View, Bottom: View>(@ViewBuilder content: () -> Content, @ViewBuilder bottom: () -> Bottom) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            content()
            Spacer()
            bottom()
        }
        .padding(.horizontal)
        .padding(.bottom)
    }

#if !os(macOS)
    @ViewBuilder func MakeHorizontalPagerLayout<Page: View, Index: Hashable & Equatable>(selection: Binding<Index>, indexDisplayMode: PageTabViewStyle.IndexDisplayMode = .never, @ViewBuilder pageBuilder: @escaping () -> Page) -> some View {
        TabView(selection: selection) {
            pageBuilder()
        }
        .tabViewStyle(.page(indexDisplayMode: indexDisplayMode))
        .animation(.snappy, value: selection.wrappedValue)
        .sensoryFeedback(.selection, trigger: selection.wrappedValue)
    }
#endif
}

// MARK: - Text

public extension ComponentBuilder {
    /// Builds a standard title text view.
    ///
    /// Styled with a bold font size of 24 and centered alignment.
    ///
    /// - Parameter stringKey: The `LocalizedStringKey` for the title text.
    /// - Returns: A configured `Text` view.
    @ViewBuilder public func BuildTitle(_ stringKey: LocalizedStringKey) -> some View {
        Text(stringKey)
            .font(.system(size: 24, weight: .bold))
            .multilineTextAlignment(.leading)
    }
    
    /// Builds a large, prominent title text view.
    ///
    /// Styled with a bold font size of 32 and centered alignment.
    ///
    /// - Parameter stringKey: The `LocalizedStringKey` for the title text.
    /// - Returns: A configured `Text` view.
    @ViewBuilder public func BuildLargeTitle(_ stringKey: LocalizedStringKey) -> some View {
        Text(stringKey)
            .font(.system(size: 32, weight: .bold))
            .multilineTextAlignment(.center)
    }
        
    /// Builds a subtitle or body text view.
    ///
    /// Styled with the standard `.body` font and centered alignment.
    ///
    /// - Parameter stringKey: The `LocalizedStringKey` for the subtitle text.
    /// - Returns: A configured `Text` view.
    @ViewBuilder public func BuildSubtitle(_ stringKey: LocalizedStringKey) -> some View {
        Text(stringKey)
            .font(.body)
            .multilineTextAlignment(.center)
    }
    
    /// Builds a label.
    ///
    /// - Parameter stringKey: The `LocalizedStringKey` for the subtitle text.
    /// - Returns: A configured `Text` view.
    @ViewBuilder public func BuildLabel(_ stringKey: LocalizedStringKey, systemImage: String) -> some View {
        HStack(alignment: .firstTextBaseline) {
            Image(systemName: systemImage)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundStyle(Color.interactiveAccent)
            Text(stringKey)
                .font(.system(size: 16, weight: .regular))
            Spacer()
        }
    }
}

// MARK: - Buttons

public extension ComponentBuilder {
    /// Builds a primary action button for continuing a flow.
    ///
    /// - Note: This button uses `PrimaryButtonStyle` to define its appearance.
    ///
    /// - Parameters:
    ///   - titleStringKey: The `LocalizedStringKey` for the button's title.
    ///   - action: The closure to execute when the button is tapped.
    /// - Returns: A configured `Button` view.
    @ViewBuilder public func BuildPrimaryButton(_ titleStringKey: LocalizedStringKey, action: @escaping () -> Void) -> some View {
        Button(titleStringKey, action: action)
            .buttonStyle(PrimaryButtonStyle())
    }
    
    /// Builds a secondary action button, often used for skipping or dismissing an action.
    ///
    /// - Note: This button uses `SecondaryButtonStyle` to define its appearance.
    ///
    /// - Parameters:
    ///   - titleStringKey: The `LocalizedStringKey` for the button's title.
    ///   - action: The closure to execute when the button is tapped.
    /// - Returns: A configured `Button` view.
    @ViewBuilder public func BuildSecondaryButton(_ titleStringKey: LocalizedStringKey, action: @escaping () -> Void) -> some View {
        Button(titleStringKey, action: action)
            .buttonStyle(SecondaryButtonStyle())
    }
    
    // MARK: - Navigation Buttons
    
    /// Builds a circular back button with a chevron icon.
    ///
    /// Features a backward chevron icon inside a semi-transparent circular background.
    ///
    /// - Parameter action: The closure to execute when the button is tapped.
    /// - Returns: A configured back button view.
    @ViewBuilder public func BuildBackButton(action: @escaping () -> Void) -> some View {
        Button(action: action, label: {
            ZStack {
                Image(systemName: "chevron.backward")
                    .tint(.accentColor)
            }
            .frame(width: 32, height: 32)
            .background {
                Circle()
                    .fill(.white.opacity(0.5))
            }
        })
    }
    
    /// Builds a circular close button with an 'X' icon.
    ///
    /// Features an 'xmark' icon inside a semi-transparent circular background.
    ///
    /// - Parameter action: The closure to execute when the button is tapped.
    /// - Returns: A configured close button view.
    @ViewBuilder public func BuildCloseButton(action: @escaping () -> Void) -> some View {
        Button(action: action, label: {
            ZStack {
                Image(systemName: "xmark")
                    .tint(.secondary)
            }
            .frame(width: 32, height: 32)
            .background {
                Circle()
                    .fill(.secondary.opacity(0.2))
            }
        })
    }
}

// MARK: - Developer Tools

public extension ComponentBuilder {
    /// Creates a standardized button for use in a developer or settings menu.
    ///
    /// This function encapsulates the styling and layout for a menu button, ensuring
    /// all developer tools have a consistent appearance.
    ///
    /// - Parameters:
    ///   - title: The text to display on the button.
    ///   - systemImage: The name of the SF Symbol to display next to the title.
    ///   - action: The closure to execute when the button is tapped.
    /// - Returns: A configured `View` representing the button.
    public func MakeDeveloperButton(title: String, systemImage: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Image(systemName: systemImage)
                    .font(.body.weight(.semibold))
                    .frame(width: 25)
                Text(title)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .tint(.primary)
    }
    
    /// Creates a view that displays the app's version and build number.
    ///
    /// This component reads version details directly from the main bundle's `Info.plist`.
    /// The text is automatically made copyable, which is useful for attaching
    /// debug information to bug reports.
    ///
    /// - Returns: A configured `View` showing the copyable version info.
    func MakeAppVersionInfo() -> some View {
        // Safely retrieve the version and build numbers from the bundle's Info.plist.
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "N/A"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "N/A"
        let versionString = "Version \(version) (\(build))"
        
        return Text(versionString)
            .font(.caption)
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity, alignment: .center)
            .textSelection(.enabled) // This modifier makes the text selectable and copyable.
    }
}
