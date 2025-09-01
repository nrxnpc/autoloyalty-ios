import Foundation
import Pulse
import PulseProxy

/// Network logging utilities for EndpointUI
public struct NetworkLogger {
    
    /// Enable network logging proxy for debugging
    public static func enableNetworkLoggerProxy() {
        Pulse.NetworkLogger.enableProxy()
    }
}