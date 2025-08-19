import Foundation

extension Date {
    /// Возвращает строковое представление даты в формате ISO8601
    var ISO8601String: String {
        return ISO8601DateFormatter().string(from: self)
    }
    
    /// Создает дату из ISO8601 строки
    static func fromISO8601String(_ string: String) -> Date? {
        return ISO8601DateFormatter().date(from: string)
    }
}

extension Optional where Wrapped == Date {
    /// Удобное свойство для опциональных дат
    var ISO8601String: String? {
        return self?.ISO8601String
    }
}

// MARK: - Дополнительные расширения для работы с API
extension ISO8601DateFormatter {
    static let shared: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()
}

extension DateFormatter {
    static let apiDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter
    }()
}
