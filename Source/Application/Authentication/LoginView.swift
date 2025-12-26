import SwiftUI
import SwiftUIComponents

struct LoginView: View, ComponentBuilder {
    // MARK: -
    
    @Environment(Main.self) var main
    @Environment(Main.Router.self) var router
    
    // MARK: -
    
    @StateObject var input = Authentication.Input()
    @StateObject var application = Authentication()
    
    // MARK: - State
    
    @State private var loginErrorMessage: String?
    @FocusState var focused: Authentication.Input.Item?
    
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
                    
                    Spacer()
                    makePolicySection()
                }
                .padding(.horizontal, 32)
                .padding(.top, 32)
                .frame(minHeight: geometry.size.height)
                .disabled(application.isUpdating)
            }
        }
        .scrollDismissesKeyboard(.immediately)
        .frame(maxHeight: .infinity)
        .animation(.easeInOut, value: application.isUpdating)
        .animation(.easeInOut, value: loginErrorMessage)
        .animation(.smooth, value: focused)
    }
}

extension LoginView {
    // MARK: - View Factory
    
    @ViewBuilder func makeIntro() -> some View {
        VStack(alignment: .center, spacing: 8) {
            Image("logo")
                .resizable()
                .scaledToFit()
                .frame(width: 96, height: 96)
            
            if focused == nil {
                MakeTitle("Buy parts. Get rewards.")
                MakeSubtitle("Scan QR codes on auto parts to earn points and redeem rewards.")
            }
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }
    
    @ViewBuilder func makeInputBody() -> some View {
        MakeSection {
            MakeTextFieldRow(placeholder: "Enter email", text: $input.email, inputType: .email)
                .focused($focused, equals: .email)
                .submitLabel(.next)
                .onSubmit { input.next(item: &focused) }
            
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
    
    @ViewBuilder private func makePolicySection() -> some View {
        VStack(spacing: 16) {
            Text("By continuing, you agree to our\n[**Privacy Policy**](http://nsp-app.ru/#privacy) and [**Terms of Use**](http://nsp-app.ru/#terms)")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            
            HStack(alignment: .center, spacing: 4) {
                Image(systemName: "tag")
                Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown")
            }
            .font(.footnote)
            .foregroundStyle(.secondary)
            .padding(.vertical, 4)
            .padding(.horizontal, 6)
            .background {
                RoundedRectangle(cornerRadius: 6)
                    .foregroundStyle(.ultraThinMaterial)
            }
            .onTap {
                let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
                UIPasteboard.general.string = "App Version: \(version)"
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
    
    private func loginAsGuest() {
        Task { @MainActor in
            await main.continueAsGuest()
        }
    }
}

#Preview {
    LoginView()
}
