import SwiftUI

// MARK: - Toast Service

@MainActor
class ToastService: ObservableObject {
    static let shared = ToastService()
    
    @Published var toasts: [ToastItem] = []
    
    private init() {}
    
    func show(_ toast: ToastItem) {
        withAnimation(AnimationSystem.Spring.bouncy) {
            toasts.append(toast)
        }
        
        // Автоматическое скрытие
        DispatchQueue.main.asyncAfter(deadline: .now() + toast.duration) {
            self.dismiss(toast)
        }
    }
    
    func dismiss(_ toast: ToastItem) {
        withAnimation(AnimationSystem.Spring.smooth) {
            toasts.removeAll { $0.id == toast.id }
        }
    }
    
    // MARK: - Convenience Methods
    func success(_ message: String, duration: Double = 3.0) {
        let toast = ToastItem(
            message: message,
            type: .success,
            duration: duration
        )
        show(toast)
        HapticService.shared.success()
    }
    
    func error(_ message: String, duration: Double = 4.0) {
        let toast = ToastItem(
            message: message,
            type: .error,
            duration: duration
        )
        show(toast)
        HapticService.shared.error()
    }
    
    func info(_ message: String, duration: Double = 3.0) {
        let toast = ToastItem(
            message: message,
            type: .info,
            duration: duration
        )
        show(toast)
        HapticService.shared.light()
    }
    
    func warning(_ message: String, duration: Double = 3.5) {
        let toast = ToastItem(
            message: message,
            type: .warning,
            duration: duration
        )
        show(toast)
        HapticService.shared.warning()
    }
}

// MARK: - Toast Item

struct ToastItem: Identifiable, Equatable {
    let id = UUID()
    let message: String
    let type: ToastType
    let duration: Double
    
    enum ToastType {
        case success, error, warning, info
        
        var color: Color {
            switch self {
            case .success: return DesignSystem.Colors.success
            case .error: return DesignSystem.Colors.error
            case .warning: return DesignSystem.Colors.warning
            case .info: return DesignSystem.Colors.info
            }
        }
        
        var icon: String {
            switch self {
            case .success: return "checkmark.circle.fill"
            case .error: return "xmark.circle.fill"
            case .warning: return "exclamationmark.triangle.fill"
            case .info: return "info.circle.fill"
            }
        }
        
        var gradient: [Color] {
            switch self {
            case .success: return [DesignSystem.Colors.success, Color.green]
            case .error: return [DesignSystem.Colors.error, Color.red]
            case .warning: return [DesignSystem.Colors.warning, Color.orange]
            case .info: return [DesignSystem.Colors.info, Color.blue]
            }
        }
    }
}

// MARK: - Toast View

struct ToastView: View {
    let toast: ToastItem
    let onDismiss: () -> Void
    
    @State private var dragOffset: CGSize = .zero
    @State private var isVisible = false
    
    var body: some View {
        HStack(spacing: DesignSystem.Spacing.medium) {
            // Иконка с анимацией
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: toast.type.gradient,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 32, height: 32)
                
                Image(systemName: toast.type.icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .scaleEffect(isVisible ? 1.0 : 0.5)
                    .animation(AnimationSystem.Spring.bouncy.delay(0.1), value: isVisible)
            }
            
            // Текст сообщения
            Text(toast.message)
                .font(DesignSystem.Typography.body)
                .foregroundColor(DesignSystem.Colors.text)
                .multilineTextAlignment(.leading)
                .opacity(isVisible ? 1.0 : 0.0)
                .animation(AnimationSystem.Spring.smooth.delay(0.2), value: isVisible)
            
            Spacer()
            
            // Кнопка закрытия
            Button(action: onDismiss) {
                Image(systemName: "xmark")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(DesignSystem.Colors.secondaryText)
            }
            .opacity(isVisible ? 1.0 : 0.0)
            .animation(AnimationSystem.Spring.smooth.delay(0.3), value: isVisible)
        }
        .padding(DesignSystem.Spacing.medium)
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
                .fill(DesignSystem.Colors.cardBackground)
                .shadow(
                    color: toast.type.color.opacity(0.3),
                    radius: 8,
                    x: 0,
                    y: 4
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
                .stroke(
                    LinearGradient(
                        colors: [toast.type.color.opacity(0.5), toast.type.color.opacity(0.1)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        .offset(x: dragOffset.width, y: dragOffset.height)
        .scaleEffect(isVisible ? 1.0 : 0.8)
        .opacity(isVisible ? 1.0 : 0.0)
        .animation(AnimationSystem.Spring.bouncy, value: isVisible)
        .gesture(
            DragGesture()
                .onChanged { value in
                    dragOffset = value.translation
                }
                .onEnded { value in
                    if abs(value.translation.width) > 100 || abs(value.translation.height) > 50 {
                        onDismiss()
                    } else {
                        withAnimation(AnimationSystem.Spring.smooth) {
                            dragOffset = .zero
                        }
                    }
                }
        )
        .onAppear {
            isVisible = true
        }
    }
}

// MARK: - Toast Container

struct ToastContainer: View {
    @StateObject private var toastService = ToastService.shared
    
    var body: some View {
        VStack {
            Spacer()
            
            VStack(spacing: DesignSystem.Spacing.small) {
                ForEach(toastService.toasts) { toast in
                    ToastView(toast: toast) {
                        toastService.dismiss(toast)
                    }
                    .transition(.asymmetric(
                        insertion: .move(edge: .bottom).combined(with: .opacity),
                        removal: .move(edge: .trailing).combined(with: .opacity)
                    ))
                }
            }
            .padding(.horizontal, DesignSystem.Spacing.medium)
            .padding(.bottom, DesignSystem.Spacing.large)
        }
        .allowsHitTesting(false)
    }
}