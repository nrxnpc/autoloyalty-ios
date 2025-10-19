import Foundation
#if os(iOS)
import UIKit
#endif

/// A component that provides the current battery charge status.
public struct BatteryMonitor: Sendable {

    /// Represents the current battery charge level.
    public enum BatteryStatus: Sendable {
        /// Battery has a healthy charge ( > 40% ).
        case normal
        /// Battery is low ( 20%...40% ). Non-critical tasks should be postponed or run less frequently.
        case low
        /// Battery is critically low ( < 20% ). Only essential tasks should run.
        case critical
    }
    
    public init() {}
    
    /// Fetches the current battery status.
    /// - Returns: The current `BatteryStatus` of the device.
    @MainActor public func status() -> BatteryStatus {
        let batteryLevel = getBatteryLevel()
        
        if batteryLevel > 0.4 {
            return .normal
        } else if batteryLevel > 0.2 {
            return .low
        } else {
            return .critical
        }
    }
    
    @MainActor private func getBatteryLevel() -> Double {
        #if os(iOS)
        UIDevice.current.isBatteryMonitoringEnabled = true
        // batteryLevel returns -1.0 if monitoring is disabled or state is unknown.
        // We treat this as a full battery to avoid unnecessary optimization.
        let level = UIDevice.current.batteryLevel
        return level < 0 ? 1.0 : Double(level)
        #else
        return 1.0 // Assume full battery on non-iOS platforms.
        #endif
    }
}
