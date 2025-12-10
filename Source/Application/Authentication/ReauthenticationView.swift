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
    
    var body: some View {
        ScrollView {
            VStack(alignment: .center, spacing: 16) {
                makeIntro()
                makeInputBody()
                makeLoginSection()
            }
            .padding(.horizontal, 16)
            .disabled(application.isUpdating)
        }
        .toolbar(content: makeToolbar)
        .navigationTitle("Re-login required")
        .navigationBarTitleDisplayMode(.large)
        .scrollDismissesKeyboard(.immediately)
        .frame(maxHeight: .infinity)
        .animation(.easeInOut, value: application.isUpdating)
        .animation(.easeInOut, value: loginErrorMessage)
        .animation(.smooth, value: focused)
        .onAppear {
            input.email = scope.currentSessionInfo.email
        }
    }
}

extension ReauthenticationView {
    // MARK: - View Factory
    
    @ViewBuilder func makeIntro() -> some View {
        Text("Your session has expired. To continue working, please enter your password")
            .font(.body)
            .foregroundStyle(.secondary)
            .multilineTextAlignment(.leading)
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
