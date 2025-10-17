import SwiftUI
import SwiftUIComponents

struct LoginView: View, ComponentBuilder {
    @EnvironmentObject var mainApplication: Main
    @StateObject var input = Input()
    @StateObject var output = Authentication()
    
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
        .disabled(output.isUpdating)
        .animation(.easeInOut, value: output.isUpdating)
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
        MakeTextField(placeholder: "Введите email", text: $input.email, inputType: .email)
            .focused($focused, equals: .email)
            .submitLabel(.next)
            .onSubmit { input.next(item: &focused) }
        
        MakeTextField(placeholder: "Введите пароль", text: $input.password, inputType: .password)
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
    
    @ViewBuilder func makeInputFooter() -> some View {
        VStack(spacing: 8) {
            MakeSecondaryButton("Login as a guest") {
                loginAsGuest()
            }
            .foregroundStyle(.secondary)
            .opacity(focused != nil ? 0.0 : 1.0)
        }
    }
    
    @ViewBuilder func makeLoginSection() -> some View {
        VStack(spacing: 8) {
            ZStack {
                MakeSubtitle(.init(loginErrorMessage ?? ""))
                    .foregroundStyle(.red)
                    .opacity(loginErrorMessage == nil ? 0 : 1)
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .opacity(focused != nil ? 0.0 : 1.0)
            .padding(.bottom, 8)
            
            MakeButton("Login") {
                login()
            }
            .validated(email: input.$email)
            .validated(password: input.$password, minimumRequirements: true)
            
            if focused == nil {
                MakeSecondaryButton("Create new account") {
                    createNewAccount()
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
                try await output.login(with: input)
            } catch {
                loginErrorMessage = Authentication.UpdatingError.somethingWentWrong.message
                defer {
                    loginErrorMessage = nil
                }
                try await Task.sleep(for: .seconds(4))
            }
        }
    }
    
    private func loginAsGuest() {
        Task { @MainActor in
            await mainApplication.continueAsGuest()
        }
    }
    
    private func createNewAccount() {
        Task { @MainActor in
            do {
                try await output.login(with: input)
            } catch let error as Authentication.UpdatingError {
                loginErrorMessage = error.message
                defer {
                    loginErrorMessage = nil
                }
                try await Task.sleep(for: .seconds(4))
            }
        }
    }
}

#Preview {
    LoginView()
}
