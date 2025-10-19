import SwiftUI
import SwiftUIComponents

struct LoginView: View, ComponentBuilder {
    @EnvironmentObject var main: Main
    @EnvironmentObject var router: Main.Router
    @StateObject var input = Input()
    @StateObject var application = Authentication()
    
    @State private var loginErrorMessage: String?
    @FocusState var focused: Input.Item?
    
    var body: some View {
        MakeCompactPage {
            makeIntro()
            makeInputBody()
            makeInputFooter()
        } bottom: {
            makeLoginSection()
        }
        .disabled(application.isUpdating)
        .animation(.easeInOut, value: application.isUpdating)
        .animation(.easeInOut, value: loginErrorMessage)
        .animation(.smooth, value: focused)
    }
}

extension LoginView {
    // MARK: - Input
    
    @MainActor
    final class Input: ObservableObject {
        @Published var email: String = ""
        @Published var password: String = ""
        
        enum Item: Hashable {
            case email
            case password
        }
        
        func next(item: inout Item?) {
            guard let current = item else { return }
            switch current {
            case .email: item = .password
            case .password: item = nil
            }
        }
    }
    
    // MARK: - View Factory
    
    @ViewBuilder func makeIntro() -> some View {
        VStack(alignment: .center, spacing: 8) {
            MakeIcon(systemImage: "car", size: .large)
            if focused == nil {
                MakeTitle("Автолояльность")
                MakeSubtitle("Универсальная программа лояльности для автолюбителей")
            }
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }
    
    @ViewBuilder func makeInputBody() -> some View {
        MakeSection {
            MakeTextFieldRow(placeholder: "Введите email", text: $input.email, inputType: .email)
                .focused($focused, equals: .email)
                .submitLabel(.next)
                .onSubmit { input.next(item: &focused) }
            
            MakeTextFieldRow(placeholder: "Введите пароль", text: $input.password, inputType: .password)
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
    
    @ViewBuilder func makeInputFooter() -> some View {
        VStack {
            MakeSecondaryButton("Continue as a guest") {
                loginAsGuest()
            }
            .foregroundStyle(.secondary)
            .opacity(focused != nil ? 0.0 : 1.0)
        }
    }
    
    @ViewBuilder func makeLoginSection() -> some View {
        VStack(spacing: 0) {
            Spacer()
            
            NotificationMessageView(text: loginErrorMessage ?? "") {
                loginErrorMessage = nil
            }
            .opacity(focused != nil || loginErrorMessage == nil ? 0.0 : 1.0)
            .padding(.bottom, 8)
            
            MakeButton("Login") {
                login()
            }
            .validated(email: input.$email)
            .validated(password: input.$password, minimumRequirements: true)
            
            if focused == nil {
                MakeSecondaryButton("Create new account") {
                    router.route(sheet: .createAccount(application))
                }
            }
        }
        .foregroundStyle(.secondary)
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
