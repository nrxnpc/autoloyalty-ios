import SwiftUI
import CoreData

public struct FetchedCardSwipeView<Item: NSManagedObject & Identifiable & Hashable, Content: View>: View {
    private let fetchedResults: FetchedResults<Item>
    @Binding private var selectedItem: Item?
    @Binding private var popTrigger: CardSwipeDirection?
    private let content: (Item, CGFloat, CardSwipeDirection) -> Content
    
    @State private var items: [Item] = []
    @State private var configuration = Configuration<Item>()
    
    public init(
        fetchedResults: FetchedResults<Item>,
        selectedItem: Binding<Item?> = .constant(nil),
        popTrigger: Binding<CardSwipeDirection?> = .constant(nil),
        @ViewBuilder content: @escaping (Item, CGFloat, CardSwipeDirection) -> Content
    ) {
        self.fetchedResults = fetchedResults
        self._selectedItem = selectedItem
        self._popTrigger = popTrigger
        self.content = content
        self._items = State(initialValue: Array(fetchedResults))
    }
    
    public var body: some View {
        CardSwipeView(
            items: $items,
            selectedItem: $selectedItem,
            popTrigger: $popTrigger,
            content: content
        )
        .configure(
            threshold: configuration.triggerThreshold,
            minimumDistance: configuration.minimumDistance,
            animateOnYAxes: configuration.animateOnYAxes,
            cardSpacing: configuration.cardSpacing
        )
        .onSwipeEnd { item, direction in
            configuration.onSwipeEnd?(item, direction)
        }
        .onNoMoreCardsLeft {
            configuration.onNoMoreCardsLeft?()
        }
        .onThresholdPassed {
            configuration.onThresholdPassed?()
        }
        .onChange(of: fetchedResults.map(\.id)) { _, newIDs in
            let currentIDs = items.map(\.id)
            if newIDs != currentIDs {
                items = Array(fetchedResults)
            }
        }
        .onAppear {
            items = Array(fetchedResults)
        }
    }
}

public extension FetchedCardSwipeView {
    func configure(threshold: CGFloat = 150, minimumDistance: CGFloat = 20, animateOnYAxes: Bool = false, cardSpacing: CGFloat = 20) -> FetchedCardSwipeView {
        configuration.triggerThreshold = threshold
        configuration.minimumDistance = minimumDistance
        configuration.animateOnYAxes = animateOnYAxes
        configuration.cardSpacing = cardSpacing
        return self
    }
    
    func onSwipeEnd(_ handler: @escaping (Item, CardSwipeDirection) -> Void) -> FetchedCardSwipeView {
        configuration.onSwipeEnd = handler
        return self
    }
    
    func onNoMoreCardsLeft(_ handler: @escaping () -> Void) -> FetchedCardSwipeView {
        configuration.onNoMoreCardsLeft = handler
        return self
    }
    
    func onThresholdPassed(_ handler: @escaping () -> Void) -> FetchedCardSwipeView {
        configuration.onThresholdPassed = handler
        return self
    }
}


/// A SwiftUI view that provides Tinder-like swipeable card functionality.
///
/// `CardSwipeView` manages a stack of cards that can be swiped left or right with smooth animations
/// and visual feedback. It supports programmatic card dismissal and provides callbacks for swipe events.
///
/// ## Usage
///
/// ```swift
/// CardSwipeView(items: $cards, selectedItem: $selectedCard) { card, progress, direction in
///     CardContentView(card: card)
///         .opacity(1.0 - progress * 0.3)
/// }
/// .configure(threshold: 150, minimumDistance: 20, animateOnYAxes: false)
/// .onSwipeEnd { card, direction in
///     print("Swiped \(direction) on card: \(card.id)")
/// }
/// ```
///
/// - Note: The view automatically manages up to 4 visible cards with depth effects.
public struct CardSwipeView<Item: Identifiable & Hashable, Content: View>: View {
    @State private var configuration = Configuration<Item>()
    @State private var poppedItem: Item?
    @State private var poppedOffset: CGPoint = .zero
    @State private var poppedDirection: CardSwipeDirection = .idle
    @State private var lastDirection: CardSwipeDirection = .idle
    @State private var offset: CGPoint = .zero
    @State private var thresholdPassed = false
    
    @Binding private var items: [Item]
    @Binding private var selectedItem: Item?
    @Binding private var popTrigger: CardSwipeDirection?
    private let content: (Item, _ progress: CGFloat, _ direction: CardSwipeDirection) -> Content
    
    private var screenWidth: CGFloat {
        configuration.screenWidth
    }
    
    /// Creates a new card swipe view.
    ///
    /// - Parameters:
    ///   - items: A binding to the array of items to display as cards.
    ///   - selectedItem: A binding to track the currently visible top card. Defaults to `nil`.
    ///   - popTrigger: A binding to programmatically trigger card swipes. Set to `.left` or `.right` to animate a swipe.
    ///   - content: A view builder that creates the content for each card.
    ///     - item: The current item being displayed.
    ///     - progress: Swipe progress from 0.0 to 1.0.
    ///     - direction: Current swipe direction (`.left`, `.right`, or `.idle`).
    public init(
        items: Binding<[Item]>,
        selectedItem: Binding<Item?> = .constant(nil),
        popTrigger: Binding<CardSwipeDirection?> = .constant(nil),
        @ViewBuilder content: @escaping (Item, _ progress: CGFloat, _ direction: CardSwipeDirection) -> Content
    ) {
        self._items = items
        self._selectedItem = selectedItem
        self._popTrigger = popTrigger
        self.content = content
    }
    
    private var swipeGesture: some Gesture {
        DragGesture(minimumDistance: configuration.minimumDistance)
            .onChanged { value in
                onDragChanged(value)
            }
            .onEnded { value in
                if abs(value.translation.width) < configuration.triggerThreshold {
                    withAnimation(.bouncy) {
                        offset = .zero
                    }
                } else if !items.isEmpty {
                    popItem()
                }
            }
    }
    
    public var body: some View {
        ZStack {
            ForEach(Array(items.prefix(configuration.visibleCount).enumerated()), id: \.element.id) { index, item in
                let progress = index == 0 ? min(abs(offset.x) / configuration.triggerThreshold, 1) : 0
                
                content(item, progress, lastDirection)
                    .modifier(
                        CardSwipeEffect(
                            index: index,
                            offset: offset,
                            triggerThreshold: configuration.triggerThreshold,
                            cardSpacing: configuration.cardSpacing
                        )
                    )
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .overlay { poppedCard }
        .gesture(swipeGesture)
        .onAppear {
            selectedItem = items.first
        }
        .onChange(of: popTrigger ?? .idle) {
            guard popTrigger != .idle else { return }
            lastDirection = popTrigger ?? .idle
            popItem(notifyCaller: false)
            popTrigger = nil
        }
    }
    
    @ViewBuilder
    var poppedCard: some View {
        if let poppedItem {
            content(poppedItem, min(abs(poppedOffset.x) / configuration.triggerThreshold, 1), poppedDirection)
                .modifier(
                    CardSwipeEffect(
                        index: 0,
                        offset: poppedOffset,
                        triggerThreshold: configuration.triggerThreshold,
                        cardSpacing: configuration.cardSpacing
                    )
                )
                .id(poppedItem.id)
                .onAppear {
                    animatePoppedItem()
                }
        }
    }
    
    func onDragChanged(_ value: DragGesture.Value) {
        let translation = value.translation.width
        let correction = correction(for: translation)
        let offsetX = translation + correction
        let offsetY = configuration.animateOnYAxes
            ? value.translation.height
            : 0
        offset = CGPoint(x: offsetX, y: offsetY)
        
        let newDirection = CardSwipeDirection(offset: offsetX)
        if lastDirection != newDirection {
            lastDirection = newDirection
        }
        
        let thresholdReached = abs(offsetX) >= configuration.triggerThreshold
        if thresholdReached != thresholdPassed {
            thresholdPassed = thresholdReached
            if thresholdReached {
                configuration.onThresholdPassed?()
            }
        }
    }

    func correction(for translation: CGFloat) -> CGFloat {
        if translation >= configuration.minimumDistance {
            -configuration.minimumDistance
        } else if translation <= -configuration.minimumDistance {
            configuration.minimumDistance
        } else {
            -translation
        }
    }
    
    func animatePoppedItem() {
        let multiplier: CGFloat = poppedDirection == .left ? -1 : 1
        
        if #available(iOS 17.0, *) {
            withAnimation(.spring(duration: 0.5)) {
                poppedOffset.x += (screenWidth * multiplier)
            } completion: {
                self.poppedItem = nil
                self.poppedOffset = .zero
                
                if items.isEmpty {
                    configuration.onNoMoreCardsLeft?()
                }
            }
        } else {
            withAnimation(.spring(duration: 0.5)) {
                poppedOffset.x += (screenWidth * multiplier)
            }
            
            Task {
                try? await Task.sleep(nanoseconds: (1 * NSEC_PER_SEC) / 2)
                
                self.poppedItem = nil
                
                if items.isEmpty {
                    configuration.onNoMoreCardsLeft?()
                }
            }
        }
    }
    
    func popItem(notifyCaller: Bool = true) {
        guard !items.isEmpty else { return }
        poppedOffset = offset
        poppedDirection = lastDirection
        poppedItem = items.removeFirst()
        selectedItem = items.first
        if let poppedItem, notifyCaller {
            configuration.onSwipeEnd?(poppedItem, lastDirection)
        }
        offset = .zero
    }
}

public extension CardSwipeView {
    /// Configures swipe behavior parameters.
    ///
    /// - Parameters:
    ///   - threshold: Minimum distance in points to trigger a card dismissal. Default is 150.
    ///   - minimumDistance: Minimum drag distance to start gesture recognition. Default is 20.
    ///   - animateOnYAxes: Whether cards should follow vertical drag movements. Default is `false`.
    /// - Returns: The configured `CardSwipeView`.
    func configure(
        threshold: CGFloat,
        minimumDistance: CGFloat,
        animateOnYAxes: Bool,
        cardSpacing: CGFloat = 20
    ) -> CardSwipeView {
        configuration.triggerThreshold = threshold
        configuration.minimumDistance = minimumDistance
        configuration.animateOnYAxes = animateOnYAxes
        configuration.cardSpacing = cardSpacing
        return self
    }
    
    /// Sets a callback for when a card swipe completes.
    ///
    /// - Parameter handler: Closure called with the swiped item and direction.
    /// - Returns: The configured `CardSwipeView`.
    func onSwipeEnd(_ newValue: @escaping (Item, CardSwipeDirection) -> Void) -> CardSwipeView {
        configuration.onSwipeEnd = newValue
        return self
    }
    
    /// Sets a callback for when all cards have been swiped.
    ///
    /// - Parameter handler: Closure called when the card stack becomes empty.
    /// - Returns: The configured `CardSwipeView`.
    func onNoMoreCardsLeft(_ newValue: @escaping () -> Void) -> CardSwipeView {
        configuration.onNoMoreCardsLeft = newValue
        return self
    }
    
    /// Sets a callback for when a card passes the swipe threshold.
    ///
    /// Useful for triggering haptic feedback or other effects during swipe gestures.
    ///
    /// - Parameter handler: Closure called when swipe threshold is exceeded.
    /// - Returns: The configured `CardSwipeView`.
    func onThresholdPassed(_ newValue: @escaping () -> Void) -> CardSwipeView {
        configuration.onThresholdPassed = newValue
        return self
    }
}

/// Represents the direction of a card swipe gesture.
public enum CardSwipeDirection: Sendable {
    /// Card swiped to the left (typically "reject" or "dislike")
    case left
    /// Card swiped to the right (typically "accept" or "like")
    case right
    /// Card is at rest or gesture is inactive
    case idle
    
    /// Creates a direction based on horizontal offset.
    ///
    /// - Parameter offset: Horizontal displacement value.
    init(offset: CGFloat) {
        if offset > 0 {
            self = .right
        } else if offset == 0 {
            self = .idle
        } else {
            self = .left
        }
    }
}

// MARK: - Internal

/// Internal configuration class for managing CardSwipeView behavior.
@MainActor
final class Configuration<Item: Identifiable> {
    var triggerThreshold: CGFloat = 150
    var minimumDistance: CGFloat = 20
    var animateOnYAxes: Bool = false
    var cardSpacing: CGFloat = 20
    var onSwipeEnd: ((Item, CardSwipeDirection) -> Void)?
    var onThresholdPassed: (() -> Void)?
    var onNoMoreCardsLeft: (() -> Void)?
    let visibleCount = 4
    let screenWidth = { UIScreen.current?.bounds.width ?? 400 }()
}

/// Visual effect modifier that handles card positioning and animations in the stack.
struct CardSwipeEffect: ViewModifier {
    let index: Int
    let offset: CGPoint
    let triggerThreshold: CGFloat
    let cardSpacing: CGFloat

    func body(content: Content) -> some View {
        switch index {
        case 0:
            let angle = Angle(degrees: Double(offset.x) / 20)
            content
                .offset(x: offset.x, y: offset.y)
                .rotationEffect(angle, anchor: .bottom)
                .zIndex(4)
        case 1:
            let progress = min(abs(offset.x) / triggerThreshold, 1)
            content
                .offset(y: CGFloat((1 - progress) * cardSpacing * 2.5))
                .scaleEffect(CGFloat(0.9 + progress * 0.1))
                .zIndex(3)
        case 2:
            let progress = min(abs(offset.x) / triggerThreshold, 1)
            content
                .offset(y: CGFloat(cardSpacing * 5.5 - progress * cardSpacing * 3))
                .scaleEffect(CGFloat(0.8 + progress * 0.1))
                .zIndex(2)
        case 3:
            let progress = min(abs(offset.x) / triggerThreshold, 1)
            content
                .opacity(progress)
                .offset(y: CGFloat(cardSpacing * 9 - progress * cardSpacing * 3.5))
                .scaleEffect(CGFloat(0.7 + progress * 0.1))
                .zIndex(1)
        default:
            content
                .opacity(0)
        }
    }
}

// MARK: - Helpers

extension UIWindow {
    static var current: UIWindow? {
        for scene in UIApplication.shared.connectedScenes {
            guard let windowScene = scene as? UIWindowScene else { continue }
            for window in windowScene.windows {
                if window.isKeyWindow { return window }
            }
        }
        return nil
    }
}

extension UIScreen {
    static var current: UIScreen? {
        UIWindow.current?.screen
    }
}
