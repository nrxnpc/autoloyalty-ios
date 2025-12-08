import SwiftUI

struct LoadingAnimationView: ViewModifier {
    @State var active: Bool
    
    func body(content: Content) -> some View {
        Group {
            if active {
                content
                    .phaseAnimator([1, 0.8], content: { content, phase in
                        content
                            .opacity(phase)
                    }, animation: { phase in
                        Animation
                            .easeInOut(duration: 1.0)
                            .repeatForever(autoreverses: true)
                    })
            } else {
                content
            }
        }
        .animation(.default, value: active)
    }
}

extension View {
    func loading() -> some View {
        modifier(LoadingAnimationView(active: true))
    }
    
    func loading(active: Bool) -> some View {
        modifier(LoadingAnimationView(active: active))
    }
}
