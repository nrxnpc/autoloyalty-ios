import SwiftUI

// MARK: - Advanced Animation System

struct AnimationSystem {
    
    // MARK: - Spring Animations
    struct Spring {
        static let bouncy = Animation.spring(response: 0.6, dampingFraction: 0.8, blendDuration: 0)
        static let smooth = Animation.spring(response: 0.4, dampingFraction: 1.0, blendDuration: 0)
        static let snappy = Animation.spring(response: 0.3, dampingFraction: 0.9, blendDuration: 0)
        static let gentle = Animation.spring(response: 0.8, dampingFraction: 1.2, blendDuration: 0)
    }
    
    // MARK: - Timing Curves
    struct Timing {
        static let easeInOut = Animation.timingCurve(0.25, 0.1, 0.25, 1, duration: 0.3)
        static let easeOut = Animation.timingCurve(0, 0, 0.2, 1, duration: 0.3)
        static let easeIn = Animation.timingCurve(0.4, 0, 1, 1, duration: 0.3)
        static let sharp = Animation.timingCurve(0.4, 0, 0.6, 1, duration: 0.2)
    }
    
    // MARK: - Interactive Animations
    struct Interactive {
        static let press = Animation.spring(response: 0.1, dampingFraction: 0.8)
        static let drag = Animation.spring(response: 0.2, dampingFraction: 0.9)
        static let swipe = Animation.spring(response: 0.3, dampingFraction: 0.7)
    }
}

// MARK: - Animated View Modifiers

struct ScaleOnPress: ViewModifier {
    @State private var isPressed = false
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .animation(AnimationSystem.Interactive.press, value: isPressed)
            .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
                isPressed = pressing
            }, perform: {})
    }
}

struct FloatingEffect: ViewModifier {
    @State private var isFloating = false
    let amplitude: CGFloat
    let duration: Double
    
    func body(content: Content) -> some View {
        content
            .offset(y: isFloating ? -amplitude : amplitude)
            .animation(
                Animation.easeInOut(duration: duration).repeatForever(autoreverses: true),
                value: isFloating
            )
            .onAppear {
                isFloating = true
            }
    }
}

struct ShimmerEffect: ViewModifier {
    @State private var phase: CGFloat = 0
    
    func body(content: Content) -> some View {
        content
            .overlay(
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [.clear, .white.opacity(0.3), .clear],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .rotationEffect(.degrees(30))
                    .offset(x: phase)
                    .clipped()
            )
            .onAppear {
                withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                    phase = 300
                }
            }
    }
}

struct PulseEffect: ViewModifier {
    @State private var isPulsing = false
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(isPulsing ? 1.05 : 1.0)
            .opacity(isPulsing ? 0.8 : 1.0)
            .animation(
                Animation.easeInOut(duration: 1.0).repeatForever(autoreverses: true),
                value: isPulsing
            )
            .onAppear {
                isPulsing = true
            }
    }
}

// MARK: - View Extensions

extension View {
    func scaleOnPress() -> some View {
        modifier(ScaleOnPress())
    }
    
    func floating(amplitude: CGFloat = 5, duration: Double = 2.0) -> some View {
        modifier(FloatingEffect(amplitude: amplitude, duration: duration))
    }
    
    func shimmer() -> some View {
        modifier(ShimmerEffect())
    }
    
    func pulse() -> some View {
        modifier(PulseEffect())
    }
    
    func slideIn(from edge: Edge = .bottom, delay: Double = 0) -> some View {
        modifier(SlideInModifier(edge: edge, delay: delay))
    }
}

struct SlideInModifier: ViewModifier {
    let edge: Edge
    let delay: Double
    @State private var isVisible = false
    
    func body(content: Content) -> some View {
        content
            .offset(
                x: edge == .leading ? (isVisible ? 0 : -300) : (edge == .trailing ? (isVisible ? 0 : 300) : 0),
                y: edge == .top ? (isVisible ? 0 : -300) : (edge == .bottom ? (isVisible ? 0 : 300) : 0)
            )
            .opacity(isVisible ? 1 : 0)
            .animation(AnimationSystem.Spring.bouncy.delay(delay), value: isVisible)
            .onAppear {
                isVisible = true
            }
    }
}
