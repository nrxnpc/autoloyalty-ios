import SwiftUI
import SwiftUIComponents
import PhotosUI

struct ChangeAboutMeView: View, ComponentBuilder {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var application: AboutMe
    
    ///  Change Profile Image
    @StateObject private var changeAccountImage: ChangeAccountImage = .init()
    
    var body: some View {
        ZStack {
            if application.isUpdating {
                makeLoadingPlaceholder()
            } else {
                MakeList {
                    makeProfileImage()
                    makeInfoSection()
                }
            }
        }
        .animation(.smooth, value: application.isUpdating)
        .toolbar(content: makeToolbar)
    }
}

extension ChangeAboutMeView {
    @ViewBuilder func makeLoadingPlaceholder() -> some View {
        MakeList {
            VStack(spacing: 16) {
                Circle()
                    .fill(.regularMaterial)
                    .frame(width: 160, height: 160)
                RoundedRectangle(cornerRadius: 6)
                    .frame(width: 170, height: 16)
                    .foregroundStyle(.regularMaterial)
            }
            .padding(.bottom, 16)
            .frame(maxWidth: .infinity, alignment: .center)
            
            MakeSection {
                Spacer()
                    .frame(maxWidth: .infinity, alignment: .center)
                Spacer()
                    .frame(maxWidth: .infinity, alignment: .center)
            }
        }
    }
    
    @ViewBuilder func makeProfileImage() -> some View {
        VStack(spacing: 16) {
            AccountImage(accountID: application.accountID)
                .frame(width: 160, height: 160)
            PhotosPicker(selection: $changeAccountImage.photosPickerItem, matching: .images, photoLibrary: .shared()) {
                Text("Change profile picture")
                    .font(.callout)
            }
            .photosPickerItemCropper(pickerItem: $changeAccountImage.photosPickerItem) { data in
                application.updateAccountImage(data)
            }
        }
        .padding(.bottom, 16)
    }
    
    @ViewBuilder func makeInfoSection() -> some View {
        MakeSection {
            MakeTextFieldRow(placeholder: "Enter your name", text: $application.username)
            MakeCopyableTextRow(placeholder: "Login Email", value: application.email)
        }
    }
    
    
    /// Builds the toolbar items, including the dynamic "Save" button.
    @ToolbarContentBuilder func makeToolbar() -> some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button("Close", action: dismiss.callAsFunction)
        }
    }
}

#Preview {
    let application = AboutMe()
    ChangeAboutMeView()
        .environmentObject(application)
}
