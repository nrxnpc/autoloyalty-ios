import Foundation

class DateFormatters {
    // MARK: - Instance
    
    static let shared: DateFormatters = .init()
    
    // MARK: - Formatters
    
    let day: DateFormatter
    let shortDay: DateFormatter
    let weekday: DateFormatter
    let time: DateFormatter
    let hours: DateFormatter
    let short: DateFormatter
    let full: DateFormatter
    
    // MARK: - Initialization
    
    init() {
        day = DateFormatter()
        day.dateFormat = "dd MMMM"
        
        shortDay = DateFormatter()
        shortDay.dateFormat = "dd MMM"
        
        weekday = DateFormatter()
        weekday.dateFormat = "EEE"
        
        time = DateFormatter()
        time.dateFormat = "HH:mm"
        
        hours = DateFormatter()
        hours.dateFormat = "HH:mm:ss"
        
        short = DateFormatter()
        short.dateFormat = "yyyy-MM-dd"
        
        full = DateFormatter()
        full.dateFormat = "yyyy-MM-dd HH:mm:ss"
    }
}
