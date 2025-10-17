import SwiftUI
import SwiftUIComponents

struct AboutMeView: View, ComponentBuilder {
    @StateObject var application = AboutMe()
    var body: some View {
        MakeCompactPage {
            MakeSubtitle(.init(application.username))
            MakeSubtitle(.init(application.email))
        } bottom: {
            MakeButton("Logout") {
                
            }
        }
        .id(application.accountID)
    }
}
