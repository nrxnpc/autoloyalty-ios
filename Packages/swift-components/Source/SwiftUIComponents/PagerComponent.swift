import SwiftUI
import SwiftUIPager

// MARK: - Pager Implementation Types

public enum PagerImplementation {
    case custom
    case native
}

// MARK: - Pager Components

public extension ComponentBuilder {
    /// Creates a pager with infinite scrolling capability
    @ViewBuilder 
    func MakeInfinitePager<Data, Content>(
        data: [Data],
        page: Page,
        @ViewBuilder content: @escaping (Data) -> Content,
        pagerImplementation: PagerImplementation = .custom
    ) -> some View where Data: Identifiable & Hashable, Content: View {
        switch pagerImplementation {
        case .custom:
            Pager(page: page, data: data, content: content)
                .loopPages()
        case .native:
            NativePager(
                data: data,
                currentIndex: Binding(
                    get: { page.index },
                    set: { page.update(.new(index: $0)) }
                ),
                content: content
            )
        }
    }
    
    /// Creates a pager with custom configuration
    @ViewBuilder 
    func MakePager<Data, Content>(
        data: [Data],
        page: Page,
        alignment: PositionAlignment = .center,
        @ViewBuilder content: @escaping (Data) -> Content,
        pagerImplementation: PagerImplementation = .custom
    ) -> some View where Data: Identifiable & Hashable, Content: View {
        switch pagerImplementation {
        case .custom:
            Pager(page: page, data: data, content: content)
                .alignment(alignment)
        case .native:
            NativePager(
                data: data,
                currentIndex: Binding(
                    get: { page.index },
                    set: { page.update(.new(index: $0)) }
                ),
                content: content
            )
        }
    }
    
    /// Creates a pager with page change callback
    @ViewBuilder 
    func MakePagerWithCallback<Data, Content>(
        data: [Data],
        page: Page,
        @ViewBuilder content: @escaping (Data) -> Content,
        onPageChanged: @escaping (Int) -> Void,
        pagerImplementation: PagerImplementation = .custom
    ) -> some View where Data: Identifiable & Hashable, Content: View {
        switch pagerImplementation {
        case .custom:
            Pager(page: page, data: data, content: content)
                .onPageWillChange(onPageChanged)
        case .native:
            NativePager(
                data: data,
                currentIndex: Binding(
                    get: { page.index },
                    set: { page.update(.new(index: $0)) }
                ),
                content: content,
                onPageChanged: onPageChanged
            )
        }
    }
    
    /// Creates a pager with full configuration
    @ViewBuilder 
    func MakeAdvancedPager<Data, Content>(
        data: [Data],
        page: Page,
        @ViewBuilder content: @escaping (Data) -> Content,
        onPageChanged: @escaping (Int) -> Void,
        bounces: Bool = true,
        pagerImplementation: PagerImplementation = .custom
    ) -> some View where Data: Identifiable & Hashable, Content: View {
        switch pagerImplementation {
        case .custom:
            Pager(page: page, data: data, content: content)
                .contentLoadingPolicy(.lazy(recyclingRatio: 3))
                .bounces(bounces)
                .sensitivity(.high)
                .swipeInteractionArea(.page)
                .onPageWillChange(onPageChanged)
        case .native:
            NativePager(
                data: data,
                currentIndex: Binding(
                    get: { page.index },
                    set: { page.update(.new(index: $0)) }
                ),
                content: content,
                onPageChanged: onPageChanged
            )
        }
    }
}

// Re-export SwiftUIPager types for convenience
public typealias Page = SwiftUIPager.Page
public typealias Pager = SwiftUIPager.Pager
public typealias PositionAlignment = SwiftUIPager.PositionAlignment

// MARK: - Built-in native SwiftUI pager

private struct NativePager<Data, Content>: View where Data: Identifiable & Hashable, Content: View {
    let data: [Data]
    @Binding var currentIndex: Int
    let content: (Data) -> Content
    let onPageChanged: ((Int) -> Void)?
    
    @State private var dragOffset: CGFloat = 0
    @State private var isLoading = false
    
    init(
        data: [Data],
        currentIndex: Binding<Int>,
        @ViewBuilder content: @escaping (Data) -> Content,
        onPageChanged: ((Int) -> Void)? = nil
    ) {
        self.data = data
        self._currentIndex = currentIndex
        self.content = content
        self.onPageChanged = onPageChanged
    }
    
    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: 0) {
                ForEach(data.indices, id: \.self) { index in
                    content(data[index])
                        .frame(width: geometry.size.width)
                        .opacity(isLoading && index != currentIndex ? 0.3 : 1.0)
                }
            }
            .offset(x: -CGFloat(currentIndex) * geometry.size.width + dragOffset)
            .animation(.spring(response: 0.5, dampingFraction: 0.8), value: currentIndex)
            .animation(.easeOut(duration: 0.2), value: dragOffset)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        dragOffset = value.translation.width
                    }
                    .onEnded { value in
                        let threshold = geometry.size.width * 0.25
                        let newIndex: Int
                        
                        if value.translation.width > threshold && currentIndex > 0 {
                            newIndex = currentIndex - 1
                        } else if value.translation.width < -threshold && currentIndex < data.count - 1 {
                            newIndex = currentIndex + 1
                        } else {
                            newIndex = currentIndex
                        }
                        
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                            currentIndex = newIndex
                            dragOffset = 0
                        }
                        
                        if newIndex != currentIndex {
                            onPageChanged?(newIndex)
                        }
                    }
            )
        }
        .clipped()
        .onChange(of: currentIndex) { _, newIndex in
            withAnimation(.easeInOut(duration: 0.3)) {
                isLoading = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.easeOut(duration: 0.2)) {
                    isLoading = false
                }
            }
        }
    }
}
