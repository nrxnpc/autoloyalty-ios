import Dependencies
import SwiftUI

@main
struct EntryPoint: App {
    @Dependency(\.scope) var scope
    
    var body: some Scene {
        WindowGroup {
            MainView()
                .environment(\.managedObjectContext, scope.coreDataContext)
        }
    }
}
