import Foundation
import UserNotifications
import SwiftUI

// MARK: - Notification Manager

/// Manages user notification permissions and status for Inbox context
@MainActor
final class InboxUserNotifications: ObservableObject {
    
    // MARK: - Types
    
    enum Status: String, CaseIterable {
        case unknown
        case authorized
        case denied
    }
    
    // MARK: - Properties
    
    @Published var authorizationStatus: Status {
        didSet {
            UserDefaults.standard.set(authorizationStatus.rawValue, forKey: "notificationAuthorizationStatus")
        }
    }
    
    @Published var isSuggestionHidden: Bool {
        didSet {
            UserDefaults.standard.set(isSuggestionHidden, forKey: "pushNotificationsSuggestionHidden")
        }
    }
    
    // MARK: - Initialization
    
    init() {
        // Load cached status from UserDefaults
        if let cachedStatus = UserDefaults.standard.string(forKey: "notificationAuthorizationStatus"),
           let status = Status(rawValue: cachedStatus) {
            self.authorizationStatus = status
        } else {
            self.authorizationStatus = .unknown
        }
        
        // Load cached suggestion hidden state
        self.isSuggestionHidden = UserDefaults.standard.bool(forKey: "pushNotificationsSuggestionHidden")
        
        checkAuthorizationStatus()
    }
    
    // MARK: - Public Methods
    
    /// Requests notification permission from user
    func requestPermission() async {
        do {
            let granted = try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound])
            if granted {
                await checkAuthorizationStatus()
                Task {
                    try? await Task.sleep(for: .seconds(3))
                    await MainActor.run {
                        isSuggestionHidden = authorizationStatus == .authorized
                    }
                }
            } else {
                authorizationStatus = .denied
            }
        } catch {
            debugPrint("Notification permission error: \(error)")
        }
    }
    
    /// Checks current notification authorization status
    func checkAuthorizationStatus() async {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        authorizationStatus = mapStatus(settings.authorizationStatus)
    }
    
    // MARK: - Private Methods
    
    private func checkAuthorizationStatus() {
        Task {
            await checkAuthorizationStatus()
        }
    }
    
    /// Maps system UNAuthorizationStatus to internal Status enum
    private func mapStatus(_ status: UNAuthorizationStatus) -> Status {
        switch status {
        case .authorized, .provisional, .ephemeral:
            return .authorized
        case .denied:
            return .denied
        case .notDetermined:
            return .unknown
        @unknown default:
            return .unknown
        }
    }
}

// MARK: - Local Notification Builder

/// Fluent interface for creating local notifications
struct LocalNotification {
    private let content = UNMutableNotificationContent()
    private var trigger: UNNotificationTrigger?
    
    func title(_ title: String) -> LocalNotification {
        let notification = self
        notification.content.title = title
        return notification
    }
    
    func subtitle(_ subtitle: String) -> LocalNotification {
        let notification = self
        notification.content.subtitle = subtitle
        return notification
    }
    
    func sound(_ sound: UNNotificationSound = .default) -> LocalNotification {
        let notification = self
        notification.content.sound = sound
        return notification
    }
    
    func after(seconds: TimeInterval) -> LocalNotification {
        var notification = self
        notification.trigger = UNTimeIntervalNotificationTrigger(timeInterval: seconds, repeats: false)
        return notification
    }
    
    func schedule() {
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: trigger
        )
        UNUserNotificationCenter.current().add(request)
    }
}

// MARK: - Push Notifications Suggestion View

/// View that suggests enabling push notifications with different states
struct PushNotificationsSuggestionView: View {
    
    // MARK: - Properties
    
    @EnvironmentObject var userNotifications: InboxUserNotifications
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: 4) {
            HStack(spacing: 12) {
                makeIcon()
                
                VStack(alignment: .leading, spacing: 8) {
                    HStack(alignment: .firstTextBaseline) {
                        Text(titleText)
                            .font(.headline)
                        Spacer()
                        makeHideButton()
                    }
                    Text(subtitleText)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            Spacer()
            makeButton()
        }
        .animation(.easeInOut, value: userNotifications.authorizationStatus)
        .animation(.easeInOut, value: userNotifications.isSuggestionHidden)
    }
    
    // MARK: - View Builders
    
    @ViewBuilder
    private func makeIcon() -> some View {
        switch userNotifications.authorizationStatus {
        case .unknown:
            Image(systemName: "bell.badge")
                .font(.title)
                .foregroundStyle(.red, .secondary)
                .symbolEffect(.wiggle.byLayer, options: .repeat(2))
                .symbolEffect(.bounce, value: userNotifications.authorizationStatus)
                .transition(.symbolEffect(.automatic))
        case .authorized:
            Image(systemName: "checkmark.circle.fill")
                .font(.title)
                .foregroundStyle(.green)
                .symbolEffect(.bounce, value: userNotifications.authorizationStatus)
                .transition(.symbolEffect(.automatic))
        case .denied:
            Image(systemName: "gear.badge.xmark")
                .font(.title)
                .foregroundStyle(.red.opacity(0.65), .secondary)
                .symbolEffect(.bounce, value: userNotifications.authorizationStatus)
                .transition(.symbolEffect(.automatic))
        }
    }
    
    @ViewBuilder
    private func makeButton() -> some View {
        switch userNotifications.authorizationStatus {
        case .unknown:
            Button {
                Task { @MainActor in
                    await userNotifications.requestPermission()
                }
            } label: {
                Label("Allow Notifications", systemImage: "gear.badge")
                    .font(.callout)
            }
            .foregroundStyle(.secondary)
            .padding(.vertical, 6)
            .padding(.horizontal)
            .buttonStyle(.plain)
            .transition(.scale.combined(with: .opacity))
        case .authorized:
            EmptyView()
        case .denied:
            Button {
                Task { @MainActor in
                    await openSettings()
                }
            } label: {
                Label("Go To Settings", systemImage: "gear")
                    .font(.callout)
            }
            .foregroundStyle(.secondary)
            .padding(.vertical, 6)
            .padding(.horizontal)
            .buttonStyle(.plain)
            .transition(.scale.combined(with: .opacity))
        }
    }
    
    @ViewBuilder
    private func makeHideButton() -> some View {
        Button("Hide") {
            userNotifications.isSuggestionHidden = true
        }
        .font(.caption)
        .fontWeight(.medium)
        .foregroundStyle(.secondary)
    }
    
    // MARK: - Computed Properties
    
    private var titleText: LocalizedStringKey {
        switch userNotifications.authorizationStatus {
        case .unknown:
            return "Never Miss Important Updates"
        case .authorized:
            return "Notifications Successfully Enabled"
        case .denied:
            return "Notifications Blocked"
        }
    }
    
    private var subtitleText: LocalizedStringKey {
        switch userNotifications.authorizationStatus {
        case .unknown:
            return "Tap to enable instant alerts for orders, rewards, and exclusive offers"
        case .authorized:
            return "You can always manage notification settings in app preferences"
        case .denied:
            return "Enable notifications in device settings to receive updates"
        }
    }
    
    // MARK: - Private Methods
    
    private func openSettings() async {
        if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
            await UIApplication.shared.open(settingsUrl)
        }
    }
}

// MARK: - Preview

#Preview {
    @Previewable @StateObject var userNotifications = InboxUserNotifications()
    ZStack {
        PushNotificationsSuggestionView()
            .environmentObject(userNotifications)
    }
    .animation(.easeOut, value: userNotifications.authorizationStatus)
}
