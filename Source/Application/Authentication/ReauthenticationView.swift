import Dependencies
import SwiftUI
import SwiftUIComponents

struct ReauthenticationView: View, ComponentBuilder {
    // MARK: - Dependencies
    
    @Dependency(\.scope) var scope
    
    // MARK: -
    
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var main: Main
    @EnvironmentObject var router: Main.Router
    
    // MARK: -
    
    @StateObject var input = Authentication.Input()
    @StateObject var application = Authentication()
    
    // MARK: - State
    
    @State private var loginErrorMessage: String?
    @FocusState var focused: Authentication.Input.Item?
    
    init() {
        input.email = scope.currentSessionInfo.email
    }
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(alignment: .center, spacing: 32) {
                    Spacer()
                    
                    VStack(alignment: .center, spacing: 32) {
                        makeIntro()
                        makeInputBody()
                        makeLoginSection()
                    }
                }
                .padding(.horizontal, 32)
                .padding(.top, 32)
                .frame(minHeight: geometry.size.height)
                .disabled(application.isUpdating)
            }
        }
        .toolbar(content: makeToolbar)
        .scrollDismissesKeyboard(.immediately)
        .frame(maxHeight: .infinity)
        .animation(.easeInOut, value: application.isUpdating)
        .animation(.easeInOut, value: loginErrorMessage)
        .animation(.smooth, value: focused)
    }
}

extension ReauthenticationView {
    // MARK: - View Factory
    
    @ViewBuilder func makeIntro() -> some View {
        VStack(alignment: .center, spacing: 8) {
            MakeTitle("Re-login required")
            MakeSubtitle("Your session has expired. To continue working, please enter your password")
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }
    
    @ViewBuilder func makeInputBody() -> some View {
        MakeSection {
            MakeTextFieldRow(placeholder: "Enter email", text: $input.email, inputType: .email)
                .focused($focused, equals: .email)
                .disabled(true)
            
            MakeTextFieldRow(placeholder: "Enter password", text: $input.password, inputType: .password)
                .focused($focused, equals: .password)
                .submitLabel(.go)
                .submitScope(input.password.isEmpty)
                .onSubmit {
                    guard Authentication.hasMinimumLength(password: input.password) else {
                        return
                    }
                    input.next(item: &focused)
                    login()
                }
        }
    }
    
    @ViewBuilder func makeLoginSection() -> some View {
        VStack(spacing: 0) {
            MakeButton("Login") {
                login()
            }
            .validated(email: input.$email)
            .validated(password: input.$password, minimumRequirements: true)
            
            if focused == nil {
                MakeSecondaryButton("Create new account") {
                    router.route(sheet: .createAccount(application))
                }
                
                
                // MakeSecondaryButton("Continue as a guest") {
                //     loginAsGuest()
                // }
            }
            
            NotificationMessageView(text: .init(loginErrorMessage ?? "")) {
                loginErrorMessage = nil
            }
            .opacity(focused != nil || loginErrorMessage == nil ? 0.0 : 1.0)
            .padding(.bottom, 8)
            
        }
        .foregroundStyle(.secondary)
    }
    
    @ToolbarContentBuilder func makeToolbar() -> some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button(action: dismiss.callAsFunction) {
                Image(systemName: "xmark")
            }
        }
    }
        
    // MARK: - Utility
    
    private func login() {
        Task { @MainActor in
            loginErrorMessage = nil
            do {
                try await application.login(with: input)
            } catch {
                loginErrorMessage = Authentication.UpdatingError.somethingWentWrong.message
                defer {
                    loginErrorMessage = nil
                }
                try await Task.sleep(for: .seconds(6))
            }
        }
    }
}

#Preview {
    ReauthenticationView()
}
