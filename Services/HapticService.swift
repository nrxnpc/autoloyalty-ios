import UIKit
import SwiftUI

// MARK: - Haptic Feedback Service

@MainActor
class HapticService: ObservableObject {
    static let shared = HapticService()
    
    private let impactLight = UIImpactFeedbackGenerator(style: .light)
    private let impactMedium = UIImpactFeedbackGenerator(style: .medium)
    private let impactHeavy = UIImpactFeedbackGenerator(style: .heavy)
    private let notification = UINotificationFeedbackGenerator()
    private let selection = UISelectionFeedbackGenerator()
    
    private init() {
        // Подготавливаем генераторы для быстрого отклика
        impactLight.prepare()
        impactMedium.prepare()
        impactHeavy.prepare()
        notification.prepare()
        selection.prepare()
    }
    
    // MARK: - Impact Feedback
    func light() {
        impactLight.impactOccurred()
        impactLight.prepare()
    }
    
    func medium() {
        impactMedium.impactOccurred()
        impactMedium.prepare()
    }
    
    func heavy() {
        impactHeavy.impactOccurred()
        impactHeavy.prepare()
    }
    
    // MARK: - Notification Feedback
    func success() {
        notification.notificationOccurred(.success)
        notification.prepare()
    }
    
    func warning() {
        notification.notificationOccurred(.warning)
        notification.prepare()
    }
    
    func error() {
        notification.notificationOccurred(.error)
        notification.prepare()
    }
    
    // MARK: - Selection Feedback
    func selectionChanged() {
        selection.selectionChanged()
        selection.prepare()
    }
    
    // MARK: - Complex Patterns
    func scanSuccess() {
        Task {
            light()
            try await Task.sleep(nanoseconds: 100_000_000) // 0.1 секунды
            success()
        }
    }
    
    func levelUp() {
        Task {
            medium()
            try await Task.sleep(nanoseconds: 150_000_000)
            heavy()
            try await Task.sleep(nanoseconds: 100_000_000)
            success()
        }
    }
    
    func buttonPress() {
        light()
    }
    
    func cardFlip() {
        medium()
    }
    
    func swipeAction() {
        selectionChanged()
    }
}

// MARK: - Haptic Button Wrapper

struct HapticButton<Content: View>: View {
    let action: () -> Void
    let hapticType: HapticType
    let content: Content
    
    enum HapticType {
        case light, medium, heavy, selection, success, warning, error
    }
    
    init(hapticType: HapticType = .light, action: @escaping () -> Void, @ViewBuilder content: () -> Content) {
        self.hapticType = hapticType
        self.action = action
        self.content = content()
    }
    
    var body: some View {
        Button(action: {
            performHaptic()
            action()
        }) {
            content
        }
        .scaleOnPress()
    }
    
    private func performHaptic() {
        let haptic = HapticService.shared
        switch hapticType {
        case .light: haptic.light()
        case .medium: haptic.medium()
        case .heavy: haptic.heavy()
        case .selection: haptic.selectionChanged()
        case .success: haptic.success()
        case .warning: haptic.warning()
        case .error: haptic.error()
        }
    }
}