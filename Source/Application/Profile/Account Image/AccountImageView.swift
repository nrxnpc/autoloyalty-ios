import Combine
import Dependencies
import ScopeGraph
import SwiftUI
import SwiftUIComponents

struct AccountImage: View, ComponentBuilder {
    /// The environment's managed object context for data fetching.
    @Dependency(\.scope) private var scope
    
    @ObservedObject var account: Account
    
    /// A stable instance of the loader to be used by the .task modifier.
    @State private var loader = AttachmentLoader()
    
    /// State to hold the most recently loaded image.
    @State private var image: UIImage?
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                if !account.image.isEmpty {
                    Circle()
                        .fill(.regularMaterial)
                } else {
                    let color = backgroundColor()
                    Circle()
                        .fill(color)
                }
                makeBackground(for: geometry)
                makeImageContent(for: geometry)
            }
            .animation(.smooth, value: image == nil)
            .clipShape(Circle())
        }
        .onChange(of: account.image) { oldValue, newValue in
            Task {
                guard let imageData = newValue.native ?? newValue.raw else {
                    return
                }
                let image = PlatformImage(data: imageData)
                await MainActor.run {
                    self.image = image
                }
            }
        }
        .task {
            guard let imageData = account.image.native ?? account.image.raw else {
                return
            }
            let image = PlatformImage(data: imageData)
            await MainActor.run {
                self.image = image
            }
        }
    }
}

private extension AccountImage {
    /// A predefined palette of colors for generating deterministic backgrounds.
    private static let backgroundColors: [Color] = [
        .blue, .cyan, .green, .indigo, .mint, .orange, .pink, .purple, .red, .teal, .yellow
    ]

    /// Generates a deterministic background color from a string ID.
    private func backgroundColor() -> Color {
        // A simple hash function: sum the Unicode scalar values of the characters.
        let hashValue = account.id.unicodeScalars.map { $0.value }.reduce(0, +)
        
        // Use the hash value to pick a color from the predefined palette.
        let index = Int(hashValue) % Self.backgroundColors.count
        return Self.backgroundColors[index]
    }
    
    /// Extracts initials from a full name string.
    private func initials(from name: String?) -> String {
        guard let name = name, !name.trimmingCharacters(in: .whitespaces).isEmpty else {
            return "?"
        }
        
        let components = name.components(separatedBy: .whitespacesAndNewlines).filter { !$0.isEmpty }
        
        if components.count > 1, let first = components.first?.first, let last = components.last?.first {
            return "\(first)\(last)".uppercased()
        }
        
        return "\(name.first ?? "?")".uppercased()
    }
        
    @ViewBuilder func makeBackground(for geometry: GeometryProxy) -> some View {
        let color = backgroundColor()
        Circle()
            .fill(color)
    }
    
    @ViewBuilder func makeImageContent(for geometry: GeometryProxy) -> some View {
        if let image {
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .transition(.opacity)
        } else if !account.name.isEmpty {
            makeInitialsPlaceholder(for: geometry)
        } else {
            makeDefaultPlaceholder()
        }
    }
    
    /// Builds the placeholder view with initials.
    @ViewBuilder func makeInitialsPlaceholder(for geometry: GeometryProxy) -> some View {
        let accountName = account.name
        let initialsText = initials(from: accountName)
        
        Text(initialsText)
            .font(.system(size: geometry.size.width * 0.4, weight: .semibold))
            .foregroundColor(.white)
            .transition(.opacity)
    }

    /// Builds the default placeholder view with a person icon.
    @ViewBuilder func makeDefaultPlaceholder() -> some View {
        Circle()
            .fill(.regularMaterial)
    }
}
