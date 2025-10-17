import SwiftUI
import SwiftUIComponents

struct AboutMeView: View {
    @StateObject var application = AboutMe()
    var body: some View {
        Text("About Me")
    }
}
