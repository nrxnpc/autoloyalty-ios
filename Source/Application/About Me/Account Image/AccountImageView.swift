import Combine
import Dependencies
import ScopeGraph
import SwiftUI
import SwiftUIComponents

struct AccountImage: View, ComponentBuilder {
    /// The environment's managed object context for data fetching.
    @Dependency(\.scope) private var scope
    
    /// A stable instance of the loader to be used by the .task modifier.
    @State private var loader = AttachmentLoader()
    @State private var accout: FetchedObject<Account>?
    
    /// State to hold the most recently loaded image.
    @State private var image: UIImage?
    
    /// The account ID for which to display the profile image.
    let accountID: String
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                makeBackground(for: geometry)
                makeImageContent(for: geometry)
            }
            .animation(.smooth, value: image == nil)
            .clipShape(Circle())
        }
        .task(id: accountID) {
            self.accout = .init(Account.byID(accountID), context: scope.coreDataContext)
            for await loadedImage in loader.imageStream(for: accountID, in: scope.coreDataContext) {
                // The loop will suspend until a new image is yielded by the stream.
                self.image = loadedImage
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
    private func backgroundColor(from externalID: String) -> Color {
        // A simple hash function: sum the Unicode scalar values of the characters.
        let hashValue = externalID.unicodeScalars.map { $0.value }.reduce(0, +)
        
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
        if image != nil {
            Circle()
                .fill(.regularMaterial)
        } else if let id = accout?.id {
            let color = backgroundColor(from: id)
            Circle()
                .fill(color)
        } else {
            Circle()
                .fill(.regularMaterial)
        }
    }
    
    @ViewBuilder func makeImageContent(for geometry: GeometryProxy) -> some View {
        if let image {
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .transition(.opacity)
        } else if accout != nil {
            makeInitialsPlaceholder(for: geometry)
        } else {
            makeDefaultPlaceholder(for: geometry)
        }
    }
    
    /// Builds the placeholder view with initials.
    @ViewBuilder func makeInitialsPlaceholder(for geometry: GeometryProxy) -> some View {
        let accountName = accout?.name
        let initialsText = initials(from: accountName)
        
        Text(initialsText)
            .font(.system(size: geometry.size.width * 0.4, weight: .semibold))
            .foregroundColor(.white)
            .transition(.opacity)
    }

    /// Builds the default placeholder view with a person icon.
    @ViewBuilder func makeDefaultPlaceholder(for geometry: GeometryProxy) -> some View {
        Image(systemName: "person")
            .resizable()
            .fontWeight(.thin)
            .scaledToFit()
            .padding(.all, geometry.size.width / 4)
            .foregroundColor(.gray.opacity(0.65))
            .transition(.opacity)
    }
}
