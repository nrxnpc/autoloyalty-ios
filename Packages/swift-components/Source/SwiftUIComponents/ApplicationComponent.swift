import SwiftUI

// MARK: - Application UI Components

public extension ComponentBuilder {
    
    // MARK: - Cards & Containers
    
    /// Creates a standard card container with shadow and rounded corners.
    /// - Parameter content: Content to display inside the card
    /// - Returns: Styled card view
    @ViewBuilder
    func MakeCard<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
            .padding()
            .background(.regularMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .shadow(radius: 2)
    }
    
    /// Creates a gradient card with custom colors.
    /// - Parameters:
    ///   - colors: Gradient colors
    ///   - content: Content to display inside the card
    /// - Returns: Gradient card view
    @ViewBuilder
    func MakeGradientCard<Content: View>(colors: [Color], @ViewBuilder content: () -> Content) -> some View {
        content()
            .padding()
            .background(LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .shadow(radius: 4)
    }
    
    /// Creates an information row with label and value.
    /// - Parameters:
    ///   - label: Label text
    ///   - value: Value text
    /// - Returns: Info row view
    @ViewBuilder
    func MakeInfoRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.medium)
        }
    }
    
    /// Creates a header background with wave shape.
    /// - Parameter color: Fill color
    /// - Returns: Header background view
    @ViewBuilder
    func MakeHeaderBackground(color: Color = .blue) -> some View {
        WaveShape()
            .fill(color)
            .ignoresSafeArea()
    }
    
    // MARK: - Badges & Status
    
    /// Creates a colored badge with text.
    /// - Parameters:
    ///   - text: Badge text
    ///   - color: Badge color
    /// - Returns: Badge view
    @ViewBuilder
    func MakeBadge(text: String, color: Color = .blue) -> some View {
        Text(text)
            .font(.caption)
            .fontWeight(.medium)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(color.opacity(0.2))
            .foregroundStyle(color)
            .clipShape(Capsule())
    }
    
    /// Creates a points badge.
    /// - Parameter points: Points value
    /// - Returns: Points badge view
    @ViewBuilder
    func MakePointsBadge(points: Int) -> some View {
        HStack(spacing: 4) {
            Text("\(points)")
                .fontWeight(.bold)
            Image(systemName: "star.fill")
                .font(.caption)
        }
        .font(.caption)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(.blue.opacity(0.1))
        .foregroundStyle(.blue)
        .clipShape(Capsule())
    }
    
    /// Creates a status badge.
    /// - Parameters:
    ///   - status: Status text
    ///   - color: Status color
    /// - Returns: Status badge view
    @ViewBuilder
    func MakeStatusBadge(status: String, icon: String) -> some View {
        HStack(spacing: 4) {
            Text(status)
                .fontWeight(.bold)
            Image(systemName: icon)
                .font(.caption)
        }
        .font(.caption)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(.blue.opacity(0.1))
        .foregroundStyle(.blue)
        .clipShape(Capsule())
    }
    
    // MARK: - Lists & Navigation
    
    /// Creates a list row with icon and action.
    /// - Parameters:
    ///   - title: Row title
    ///   - subtitle: Optional subtitle
    ///   - icon: SF Symbol name
    ///   - action: Tap action
    /// - Returns: List row view
    @ViewBuilder
    func MakeListRow(title: String, subtitle: String? = nil, icon: String, iconColor: Color = .primary, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .frame(width: 24)
                    .foregroundStyle(iconColor)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .fontWeight(.medium)
                        .foregroundStyle(.primary)
                    if let subtitle {
                        Text(subtitle)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .buttonStyle(.plain)
    }
    
    /// Creates a navigation row.
    /// - Parameters:
    ///   - title: Row title
    ///   - subtitle: Optional subtitle
    ///   - icon: SF Symbol name
    /// - Returns: Navigation row view
    @ViewBuilder
    func MakeNavigationRow(title: String, subtitle: String? = nil, icon: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(.blue)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .fontWeight(.medium)
                if let subtitle {
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            
            Spacer()
        }
    }
    
    /// Creates a grid item with icon and value.
    /// - Parameters:
    ///   - title: Item title
    ///   - value: Item value
    ///   - icon: SF Symbol name
    /// - Returns: Grid item view
    @ViewBuilder
    func MakeGridItem(title: String, value: String, icon: String) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(.blue)
            
            Text(value)
                .font(.headline)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    /// Creates a menu button.
    /// - Parameters:
    ///   - title: Button title
    ///   - icon: SF Symbol name
    ///   - action: Tap action
    /// - Returns: Menu button view
    @ViewBuilder
    func MakeMenuButton(title: String, icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
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
        .foregroundStyle(.primary)
    }
    
    // MARK: - Progress & States
    
    /// Creates a progress bar.
    /// - Parameters:
    ///   - progress: Progress value (0.0 to 1.0)
    ///   - color: Progress color
    /// - Returns: Progress bar view
    @ViewBuilder
    func MakeProgressBar(progress: Double, color: Color = .blue) -> some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(.secondary.opacity(0.3))
                    .frame(height: 8)
                    .clipShape(Capsule())
                
                Rectangle()
                    .fill(color)
                    .frame(width: geometry.size.width * progress, height: 8)
                    .clipShape(Capsule())
            }
        }
        .frame(height: 8)
    }
    
    /// Creates a loading view.
    /// - Parameter message: Loading message
    /// - Returns: Loading view
    @ViewBuilder
    func MakeLoadingView(message: String) -> some View {
        VStack(spacing: 16) {
            ProgressView()
            Text(message)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    /// Creates an empty state view.
    /// - Parameters:
    ///   - icon: SF Symbol name
    ///   - title: Title text
    ///   - subtitle: Subtitle text
    /// - Returns: Empty state view
    @ViewBuilder
    func MakeEmptyState(icon: String, title: String, subtitle: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 60))
                .foregroundStyle(.secondary)
            
            Text(title)
                .font(.headline)
                .foregroundStyle(.secondary)
            
            Text(subtitle)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
    
    // MARK: - Interactive Elements
    
    /// Creates a toggle row.
    /// - Parameters:
    ///   - title: Toggle title
    ///   - isOn: Toggle binding
    /// - Returns: Toggle row view
    @ViewBuilder
    func MakeToggleRow(title: String, isOn: Binding<Bool>) -> some View {
        HStack {
            Text(title)
            Spacer()
            Toggle("", isOn: isOn)
                .labelsHidden()
        }
    }
    
    /// Creates a filter button.
    /// - Parameters:
    ///   - title: Button title
    ///   - isSelected: Selection state
    ///   - action: Tap action
    /// - Returns: Filter button view
    @ViewBuilder
    func MakeFilterButton(title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? .blue : .secondary.opacity(0.2))
                .foregroundStyle(isSelected ? .white : .primary)
                .clipShape(Capsule())
        }
    }
    
    /// Creates a search bar.
    /// - Parameters:
    ///   - text: Search text binding
    ///   - placeholder: Placeholder text
    /// - Returns: Search bar view
    @ViewBuilder
    func MakeSearchBar(text: Binding<String>, placeholder: String) -> some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)
            
            TextField(placeholder, text: text)
            
            if !text.wrappedValue.isEmpty {
                Button(action: { text.wrappedValue = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding()
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
    
    // MARK: - Media & Content
    
    /// Creates an image placeholder.
    /// - Parameters:
    ///   - icon: SF Symbol name
    ///   - size: Placeholder size
    /// - Returns: Image placeholder view
    @ViewBuilder
    func MakeImagePlaceholder(icon: String, size: CGSize) -> some View {
        Rectangle()
            .fill(.secondary.opacity(0.3))
            .frame(width: size.width, height: size.height)
            .overlay(
                Image(systemName: icon)
                    .font(.system(size: min(size.width, size.height) * 0.4))
                    .foregroundStyle(.secondary)
            )
            .clipShape(RoundedRectangle(cornerRadius: 8))
    }
    
    /// Creates an avatar view.
    /// - Parameters:
    ///   - name: User name for initials
    ///   - size: Avatar size
    /// - Returns: Avatar view
    @ViewBuilder
    func MakeAvatarView(name: String, size: CGFloat = 60) -> some View {
        Circle()
            .fill(.blue.opacity(0.2))
            .frame(width: size, height: size)
            .overlay(
                Text(String(name.prefix(1)).uppercased())
                    .font(.system(size: size * 0.4, weight: .bold))
                    .foregroundStyle(.blue)
            )
    }
}

// MARK: - Private Implementation

fileprivate struct WaveShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let waveHeight: CGFloat = 40
        let waveLength = rect.width / 2
        
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: 0, y: rect.height - waveHeight))
        
        path.addQuadCurve(
            to: CGPoint(x: waveLength, y: rect.height - waveHeight),
            control: CGPoint(x: waveLength / 2, y: rect.height)
        )
        
        path.addQuadCurve(
            to: CGPoint(x: rect.width, y: rect.height - waveHeight),
            control: CGPoint(x: waveLength + waveLength / 2, y: rect.height - waveHeight * 2)
        )
        
        path.addLine(to: CGPoint(x: rect.width, y: 0))
        path.closeSubpath()
        
        return path
    }
}
