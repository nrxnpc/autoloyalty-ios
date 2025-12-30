import Dependencies
import Foundation
import CoreData

@Observable
@MainActor
final class Inbox {
    @ObservationIgnored
    @Dependency(\.scope) var scope
}
