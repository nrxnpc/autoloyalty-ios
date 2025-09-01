import Foundation

// MARK: - Session Protocol

public protocol SessionProtocol {
    func data(for request: URLRequest) async throws -> (Data, URLResponse)
}

extension URLSession: SessionProtocol {}

/// A protocol that defines an asynchronous authentication strategy.
public protocol SessionBuilder {
}

/// An extension to provide reusable helper methods for common authentication tasks.
public extension SessionBuilder {
    /// Encapsulates the logic for setting a bearer token on a request.
    static func createSession() -> SessionProtocol {
        URLSession(configuration: .default)
    }
}

private final class SessionDelegate: NSObject, URLSessionDelegate, URLSessionDataDelegate {
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        NSLog("[\(dataTask.taskIdentifier)] didReceive: \(data.count)")
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didFinishCollecting metrics: URLSessionTaskMetrics) {
        NSLog("[\(task.taskIdentifier)] didFinishCollectingMetrics: \(metrics)")
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: (any Error)?) {
        NSLog("[\(task.taskIdentifier)] didCompleteWithError: \(String(describing: error))")
    }
}
