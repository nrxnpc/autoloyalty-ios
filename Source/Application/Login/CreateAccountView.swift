import SwiftUI
import SwiftUIComponents

struct CreateAccountView: View, ComponentBuilder {
    @EnvironmentObject var main: Main
    @StateObject var input = Input()
    @StateObject var application = Authentication()
    
    @State private var loginErrorMessage: String?
    @FocusState var focused: Input.Item?
    
    var body: some View {
        MakeList {
            makeInputBody()
            makeCreateSection()
        }
        .disabled(application.isUpdating)
        .animation(.easeInOut, value: application.isUpdating)
        .animation(.easeInOut, value: loginErrorMessage)
        .animation(.smooth, value: focused)
        .navigationTitle("Create New Account")
    }
}

extension CreateAccountView {
    // MARK: - Input
    
    @MainActor
    final class Input: ObservableObject {
        @Published var name: String = ""
        @Published var email: String = ""
        @Published var password: String = ""
        @Published var isCompany: Bool = false
        
        enum Item: Hashable {
            case name
            case email
            case password
        }
        
        func next(item: inout Item?) {
            guard let current = item else { return }
            switch current {
            case .name: item = .email
            case .email: item = .password
            case .password: item = nil
            }
        }
    }
    
    @ViewBuilder func makeInputBody() -> some View {
        MakeSection {
            MakeTextFieldRow(placeholder: "Введите имя", text: $input.name, inputType: .text)
                .focused($focused, equals: .name)
                .submitLabel(.next)
                .onSubmit { input.next(item: &focused) }
            
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
                }
            
            MakeToggleRow(title: "Это компания", isOn: $input.isCompany)
        }
    }
    
    @ViewBuilder func makeCreateSection() -> some View {
        VStack(spacing: 0) {
            Spacer()
            
            NotificationMessageView(text: loginErrorMessage ?? "") {
                loginErrorMessage = nil
            }
            .opacity(focused != nil || loginErrorMessage == nil ? 0.0 : 1.0)
            .padding(.bottom, 8)
            
            MakeButton("Create") {
                createNewAccount()
            }
            .validated(name: input.$name)
            .validated(email: input.$email)
            .validated(password: input.$password, minimumRequirements: true)
        }
        .foregroundStyle(.secondary)
    }
    
    private func createNewAccount() {
        Task { @MainActor in
            loginErrorMessage = nil
            do {
                try await application.createAccount(with: input)
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
    CreateAccountView()
}
