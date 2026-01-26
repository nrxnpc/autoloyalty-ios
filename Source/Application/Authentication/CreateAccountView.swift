import SwiftUI
import SwiftUIComponents

struct CreateAccountView: View, ComponentBuilder {
    // MARK: - Dependensies
    
    @Environment(\.dismiss) var dismiss
    @Environment(Main.Router.self) var router
    @EnvironmentObject internal var authentication: Authentication
    
    // MARK: - State
    
    enum Step { case enterName, enterEmail, confirmEmail }
    @State private var step: Step = .enterName
    
    @StateObject internal var input: Authentication.Input = .init()
    @FocusState var focused: Authentication.Input.Item?
    @State var checklistVisible = false
    @State var throwingErrorWithDescription: LocalizedStringKey?
    
    // MARK: -
    
    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                switch step {
                case .enterName:
                    makeEnterNameStep()
                        .transition(.scale.combined(with: .opacity))
                case .enterEmail:
                    makeEnterEmailStep()
                        .transition(.scale.combined(with: .opacity))
                case .confirmEmail:
                    makeConfirmEmail()
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .padding(.horizontal, 32)
            .animation(.smooth, value: step)
            .animation(.smooth, value: checklistVisible)
            .animation(.smooth, value: throwingErrorWithDescription)
            .blocked(by: $authentication.isUpdating)
        }
        .scrollDismissesKeyboard(.immediately)
        .toolbar(content: makeToolbar)
        .onChange(of: focused) {
            checklistVisible = focused == .password
        }
    }
    
    private func createAccount() {
        Task { @MainActor in
            do {
                try await authentication.createAccount(with: input)
                step = .confirmEmail
            } catch {
                throwingErrorWithDescription = "Something went wrong while creating your account. Please try again later"
            }
        }
    }
    
    private func confirmAccount() {
        Task { @MainActor in
            do {
                try await authentication.confirmCreateAccount(with: input)
                router.reset()
            } catch {
                throwingErrorWithDescription = "Invalid or expired verification code. Please try again"
            }
        }
    }
}

// MARK: - View Builders

extension CreateAccountView {
    @ViewBuilder func makeEnterNameStep() -> some View {
        make(title: "Let’s get to know you")
        makeInputNameFields()
        makeEnterEmailButton()
    }
    
    @ViewBuilder func makeEnterEmailStep() -> some View {
        make(title: "Hi, \(input.name)!")
        makeInputRegistrationFields()
        
        if checklistVisible {
            PasswordRequirementsView(password: $input.password)
                .transition(.opacity)
        }
        
        makeConfirmEmailButton()
        makeBackToEnterNameButton()
        
        NotificationMessageView(text: throwingErrorWithDescription) {
            self.throwingErrorWithDescription = nil
        }
        .opacity(self.throwingErrorWithDescription == nil ? 0.0 : 1.0)
        .padding(.bottom, 8)
    }
    
    @ViewBuilder func makeConfirmEmail() -> some View {
        make(title: "Enter the code we sent to your email")
        makeInputConfirmationFields()
        makeSignUpButton()
        makeBackToEnterEmailButton()
        
        NotificationMessageView(text: throwingErrorWithDescription) {
            self.throwingErrorWithDescription = nil
        }
        .opacity(self.throwingErrorWithDescription == nil ? 0.0 : 1.0)
        .padding(.bottom, 8)
    }
    
    @ViewBuilder func makeInputNameFields() -> some View {
        MakeSection {
            makeInputField(name: $input.name)
                .submitLabel(.continue)
                .onSubmit { step = .enterEmail }
        }
    }
    
    @ViewBuilder func makeInputRegistrationFields() -> some View {
        MakeSection {
            makeInputField(email: $input.email)
                .focused($focused, equals: .email)
                .submitLabel(.next)
                .onSubmit { input.next(item: &focused) }
            
            makeInputField(password: $input.password)
                .focused($focused, equals: .password)
                .submitLabel(.done)
        }
    }
    
    @ViewBuilder func makeInputConfirmationFields() -> some View {
        MakeSection {
            makeInputField(code: $input.confirmationCode)
                .submitLabel(.done)
                .onSubmit {
                    confirmAccount()
                }
        }
    }
    
    @ViewBuilder func makeEnterEmailButton() -> some View {
        Button("Continue") {
            step = .enterEmail
        }
        .buttonStyle(PrimaryButtonStyle())
        .validated(name: input.$name)
    }
    
    @ViewBuilder func makeConfirmEmailButton() -> some View {
        Button("Continue") {
            createAccount()
        }
        .buttonStyle(PrimaryButtonStyle())
        .validated(email: input.$email)
        .validated(password: input.$password, minimumRequirements: true)
    }
    
    @ViewBuilder func makeSignUpButton() -> some View {
        Button("Confirm") {
            confirmAccount()
        }
        .buttonStyle(PrimaryButtonStyle())
        .validated(code: input.$confirmationCode)
    }
    
    @ViewBuilder func makeBackToEnterNameButton() -> some View {
        Button("Back") {
            step = .enterName
        }
        .foregroundStyle(.secondary)
    }
    
    @ViewBuilder func makeBackToEnterEmailButton() -> some View {
        Button("Back") {
            step = .enterEmail
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
}

extension CreateAccountView {
    @MainActor @ViewBuilder func make(title: LocalizedStringKey) -> some View {
        Text(title)
            .font(.title).fontWeight(.medium)
    }
    
    @MainActor @ViewBuilder func make(subtitle: LocalizedStringKey) -> some View {
        Text(subtitle)
            .font(.body)
            .foregroundStyle(.secondary)
    }
    
    @MainActor @ViewBuilder func makeInputField(name text: Binding<String>) -> some View {
        MakeTextFieldRow(placeholder: "What is your name?", text: text, inputType: .email)
            .disabled(authentication.isUpdating)
    }
    
    @MainActor @ViewBuilder func makeInputField(email text: Binding<String>) -> some View {
        MakeTextFieldRow(placeholder: "Enter email", text: text, inputType: .email)
            .disabled(authentication.isUpdating)
    }
    
    @MainActor @ViewBuilder func makeInputField(password text: Binding<String>, placeholder: LocalizedStringKey = "Password") -> some View {
        MakeTextFieldRow(placeholder: "Enter password", text: text, inputType: .password)
            .disabled(authentication.isUpdating)
    }
    
    @MainActor @ViewBuilder func makeInputField(code text: Binding<String>) -> some View {
        MakeTextFieldRow(placeholder: "Enter confirmation code", text: text, inputType: .text)
    }
}

struct AsyncView: ViewModifier {
    @Binding var updating: Bool
    func body(content: Content) -> some View {
        content
            .opacity(updating ? 0.5 : 1)
            .animation(.default, value: updating)
            .disabled(updating)
    }
}

extension View {
    func blocked(by updating: Binding<Bool>) -> some View {
        modifier(AsyncView(updating: updating))
    }
}

#Preview {
    let authentication = Authentication()
    CreateAccountView()
        .environmentObject(authentication)
}
