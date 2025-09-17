import Foundation
import SwiftUI

// MARK: - Notification.Name Extensions
extension Notification.Name {
    static let userLoggedOut = Notification.Name("userLoggedOut")
    static let userRegistered = Notification.Name("userRegistered")
    static let dataCleared = Notification.Name("dataCleared")
    static let qrCodeScanned = Notification.Name("qrCodeScanned")
}

// MARK: - View Extensions
extension View {
    func equatable<T: Hashable>(by value: T) -> some View {
        self.id(value)
    }
    
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

// MARK: - Custom Shapes
struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

// MARK: - Constants
struct AppConstants {
    struct Colors {
        static let primary = DesignSystem.Colors.primary
        static let secondary = DesignSystem.Colors.secondary
        static let background = DesignSystem.Colors.background
        static let accent = DesignSystem.Colors.accent
        static let success = DesignSystem.Colors.success
        static let warning = DesignSystem.Colors.warning
        static let error = DesignSystem.Colors.error
        static let text = DesignSystem.Colors.text
    }
    
    struct Spacing {
        static let small = DesignSystem.Spacing.small
        static let medium = DesignSystem.Spacing.medium
        static let large = DesignSystem.Spacing.large
        static let extraLarge = DesignSystem.Spacing.xl
    }
    
    struct FontSizes {
        static let caption: CGFloat = 12
        static let body: CGFloat = 16
        static let title: CGFloat = 20
        static let largeTitle: CGFloat = 32
    }
    
    struct Images {
        static let placeholder = "photo"
        static let car = "car.fill"
        static let qrCode = "qrcode.viewfinder"
        static let gift = "gift.fill"
        static let person = "person.fill"
        static let house = "house.fill"
    }
    
    struct URLs {
        static let baseURL = "https://api.nsp.com"
        static let imageBaseURL = "https://images.nsp.com"
    }
}

// MARK: - Date Extensions
extension Date {
    var isToday: Bool {
        Calendar.current.isDateInToday(self)
    }
    
    var isYesterday: Bool {
        Calendar.current.isDateInYesterday(self)
    }
    
    func timeAgoDisplay() -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: self, relativeTo: Date())
    }
    
    func formattedDate() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter.string(from: self)
    }
}

// MARK: - String Extensions
extension String {
    var isValidEmail: Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: self)
    }
    
    var isValidPhone: Bool {
        let phoneRegEx = "^[+]?[0-9]{10,15}$"
        let phonePred = NSPredicate(format: "SELF MATCHES %@", phoneRegEx)
        return phonePred.evaluate(with: self)
    }
    
    func truncated(to length: Int) -> String {
        if self.count > length {
            return String(self.prefix(length)) + "..."
        }
        return self
    }
}

// MARK: - Array Extensions
extension Array where Element: Identifiable {
    func removingDuplicates() -> [Element] {
        var seen = Set<Element.ID>()
        return filter { seen.insert($0.id).inserted }
    }
}

// MARK: - UIApplication Extensions
extension UIApplication {
    func hideKeyboard() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

// MARK: - Color Extensions
extension Color {
    static let systemBackground = Color(.systemBackground)
    static let secondarySystemBackground = Color(.secondarySystemBackground)
    static let label = Color(.label)
    static let secondaryLabel = Color(.secondaryLabel)
    
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Bundle Extensions
extension Bundle {
    var displayName: String? {
        return object(forInfoDictionaryKey: "CFBundleDisplayName") as? String ??
               object(forInfoDictionaryKey: "CFBundleName") as? String
    }
    
    var version: String? {
        return object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
    }
    
    var buildNumber: String? {
        return object(forInfoDictionaryKey: "CFBundleVersion") as? String
    }
}

// MARK: - Error Extensions
extension Error {
    var localizedDescription: String {
        if let error = self as? LocalizedError {
            return error.errorDescription ?? "Unknown error"
        }
        return "Unknown error"
    }
}

// MARK: - UserDefaults Extensions
extension UserDefaults {
    private enum Keys {
        static let isFirstLaunch = "isFirstLaunch"
        static let lastSyncDate = "lastSyncDate"
        static let cacheSize = "cacheSize"
    }
    
    var isFirstLaunch: Bool {
        get { bool(forKey: Keys.isFirstLaunch) }
        set { set(newValue, forKey: Keys.isFirstLaunch) }
    }
    
    var lastSyncDate: Date? {
        get { object(forKey: Keys.lastSyncDate) as? Date }
        set { set(newValue, forKey: Keys.lastSyncDate) }
    }
    
    var cacheSize: Int {
        get { integer(forKey: Keys.cacheSize) }
        set { set(newValue, forKey: Keys.cacheSize) }
    }
}

// MARK: - Date ISO8601 Extension
fileprivate let sharedISO8601DateFormatter = ISO8601DateFormatter()
extension Date {
    /// Returns ISO8601 formatted string representation of the date
    public var ISO8601String: String {
        return sharedISO8601DateFormatter.string(from: self)
    }
}
