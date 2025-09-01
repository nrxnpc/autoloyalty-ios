import Foundation
import UserNotifications
import SwiftUI

@MainActor
class NotificationService: ObservableObject {
    static let shared = NotificationService()
    
    @Published var hasPermission = false
    @Published var notifications: [AppNotification] = []
    
    private init() {
        checkPermission()
    }
    
    func requestPermission() async {
        do {
            hasPermission = try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound])
        } catch {
            hasPermission = false
        }
    }
    
    private func checkPermission() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.hasPermission = settings.authorizationStatus == .authorized
            }
        }
    }
    
    func scheduleNotification(title: String, body: String, delay: TimeInterval = 0) {
        guard hasPermission else { return }
        
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: max(delay, 1), repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
    
    func addInAppNotification(_ notification: AppNotification) {
        notifications.insert(notification, at: 0)
        
        // Автоматически удаляем через 5 секунд
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            self.removeNotification(notification.id)
        }
    }
    
    func removeNotification(_ id: String) {
        notifications.removeAll { $0.id == id }
    }
    
    // Уведомления для разных событий
    func notifyQRScanned(points: Int) {
        let notification = AppNotification(
            title: "QR-код отсканирован!",
            message: "Вы получили \(points) баллов",
            type: .success
        )
        addInAppNotification(notification)
    }
    
    func notifyProductApproved(productName: String) {
        let notification = AppNotification(
            title: "Товар одобрен",
            message: "\(productName) успешно прошел модерацию",
            type: .success
        )
        addInAppNotification(notification)
    }
    
    func notifyContentRejected(title: String) {
        let notification = AppNotification(
            title: "Контент отклонен",
            message: "\(title) не прошел модерацию",
            type: .error
        )
        addInAppNotification(notification)
    }
}

struct AppNotification: Identifiable, Equatable {
    let id = UUID().uuidString
    let title: String
    let message: String
    let type: NotificationType
    let timestamp = Date()
    
    static func == (lhs: AppNotification, rhs: AppNotification) -> Bool {
        lhs.id == rhs.id
    }
    
    enum NotificationType {
        case success, warning, error, info
        
        var color: Color {
            switch self {
            case .success: return .green
            case .warning: return .orange
            case .error: return .red
            case .info: return .blue
            }
        }
        
        var icon: String {
            switch self {
            case .success: return "checkmark.circle.fill"
            case .warning: return "exclamationmark.triangle.fill"
            case .error: return "xmark.circle.fill"
            case .info: return "info.circle.fill"
            }
        }
    }
}

// MARK: - Notification Banner View
struct NotificationBanner: View {
    let notification: AppNotification
    let onDismiss: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: notification.type.icon)
                .foregroundColor(notification.type.color)
                .font(.title2)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(notification.title)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(notification.message)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Button(action: onDismiss) {
                Image(systemName: "xmark")
                    .foregroundColor(.secondary)
                    .font(.caption)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 8)
        .padding(.horizontal)
    }
}

// MARK: - Notification Overlay
struct NotificationOverlay: View {
    @ObservedObject var notificationService = NotificationService.shared
    
    var body: some View {
        VStack {
            ForEach(notificationService.notifications.prefix(3)) { notification in
                NotificationBanner(notification: notification) {
                    notificationService.removeNotification(notification.id)
                }
                .transition(.move(edge: .top).combined(with: .opacity))
            }
            
            Spacer()
        }
        .animation(.spring(), value: notificationService.notifications)
    }
}