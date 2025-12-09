import SwiftUI

extension View {
    func onTap(action: @escaping () -> Void) -> some View {
        self
            .modifier(TapGestureModifier(action: action))
    }
}

private struct TapGestureModifier: ViewModifier {
    let action: () -> Void
    @State private var isPressed = false
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .animation(.easeOut(duration: 0.1), value: isPressed)
            .onTapGesture {
                action()
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
            }
            .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity) {
                // Empty action for long press
            } onPressingChanged: { pressing in
                isPressed = pressing
            }
    }
}
