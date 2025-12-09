import SwiftUI
import SwiftUIComponents

struct CreateAccountView: View, ComponentBuilder {
    // MARK: - Dependensies
    
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var router: Main.Router
    @EnvironmentObject internal var authentication: Authentication
    
    // MARK: - State
    
    enum Step { case enterEmail, confirmEmail }
    @State private var step: Step = .enterEmail
    
    @StateObject internal var input: Authentication.Input = .init()
    @FocusState var focused: Authentication.Input.Item?
    @State var checklistVisible = false
    @State var throwingErrorWithDescription: String?
    
    // MARK: -
    
    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                switch step {
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
    
    private func confirmEmail() {
        step = .confirmEmail
        
        // TODO: skip for now
        // Task { @MainActor in
        //     do {
        //         // try await authentication.sendVerificationCode(with: input.email)
        //         step = .confirmEmail
        //     } catch {
        //         throwingErrorWithDescription = "Something went wrong while creating your account. Please try again later."
        //     }
        // }
    }
    
    private func signUp() {
        Task { @MainActor in
            do {
                try await authentication.createAccount(with: input)
                router.reset()
            } catch {
                throwingErrorWithDescription = "Something went wrong while creating your account. Please try again later."
            }
        }
    }
}

// MARK: - View Builders

extension CreateAccountView {
    @ViewBuilder func makeEnterEmailStep() -> some View {
        make(title: "Create New Account")
        makeInputRegistrationFields()
        
        if checklistVisible {
            PasswordRequirementsView(password: $input.password)
                .transition(.opacity)
        }
        
        makeConfirmEmailButton()
        
        NotificationMessageView(text: .init(throwingErrorWithDescription ?? "")) {
            throwingErrorWithDescription = nil
        }
        .opacity(throwingErrorWithDescription == nil ? 0.0 : 1.0)
        .padding(.bottom, 8)
    }
    
    @ViewBuilder func makeConfirmEmail() -> some View {
        make(title: "Enter the code we sent to your email")
        makeInputConfirmationFields()
        makeSignUpButton()
        
        NotificationMessageView(text: .init(throwingErrorWithDescription ?? "")) {
            throwingErrorWithDescription = nil
        }
        .opacity(throwingErrorWithDescription == nil ? 0.0 : 1.0)
        .padding(.bottom, 8)
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
                .onSubmit {
                    confirmEmail()
                }
        }
    }
    
    @ViewBuilder func makeInputConfirmationFields() -> some View {
        MakeSection {
            makeInputField(code: $input.confirmationCode)
                .submitLabel(.done)
                .onSubmit {
                    signUp()
                }
        }
    }
    
    @ViewBuilder func makeConfirmEmailButton() -> some View {
        Button("Continue") {
            confirmEmail()
        }
        .buttonStyle(PrimaryButtonStyle())
        .validated(email: input.$email)
        .validated(password: input.$password, minimumRequirements: true)
    }
    
    @ViewBuilder func makeSignUpButton() -> some View {
        Button("Confirm") {
            signUp()
        }
        .buttonStyle(PrimaryButtonStyle())
        .validated(code: input.$confirmationCode)
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
