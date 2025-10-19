import SwiftUI

struct AuthFlowView: View {
    var body: some View {
        NavigationView {
            LoginView()
        }
    }
}

struct DemoAccessButtons: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        VStack(spacing: AppConstants.Spacing.small) {
            Text("Демо доступы:")
                .font(.caption)
                .foregroundColor(.secondary)
            
            VStack(spacing: 8) {
                HStack(spacing: 12) {
                    Button("Пользователь") {
                        authViewModel.login(email: "user@nsp.com", password: "123456")
                    }
                    .font(.caption)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.blue.opacity(0.1))
                    .foregroundColor(.blue)
                    .cornerRadius(8)
                    
                    Button("Поставщик") {
                        authViewModel.login(email: "supplier@nsp.com", password: "123456")
                    }
                    .font(.caption)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.orange.opacity(0.1))
                    .foregroundColor(.orange)
                    .cornerRadius(8)
                    
                    Button("Админ") {
                        authViewModel.login(email: "admin@nsp.com", password: "123456")
                    }
                    .font(.caption)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.green.opacity(0.1))
                    .foregroundColor(.green)
                    .cornerRadius(8)
                }
                
                NavigationLink("Регистрация", destination: RegistrationView())
                    .font(.caption)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.purple.opacity(0.1))
                    .foregroundColor(.purple)
                    .cornerRadius(8)
            }
        }
        .padding(.top)
    }
}



struct RegistrationView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var email = ""
    @State private var phone = ""
    @State private var password = ""
    @State private var userType = User.UserType.individual
    @FocusState private var focusedField: Field?
    
    enum Field {
        case name, email, phone, password
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: AppConstants.Spacing.large) {
                    Text("Регистрация")
                        .font(.title)
                        .fontWeight(.bold)
                        .padding(.top)
                    
                    Picker("Тип пользователя", selection: $userType) {
                        Text("Физическое лицо").tag(User.UserType.individual)
                        Text("Юридическое лицо").tag(User.UserType.business)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal)
                    
                    VStack(spacing: AppConstants.Spacing.medium) {
                        TextField("Имя", text: $name)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .focused($focusedField, equals: .name)
                        
                        TextField("Email", text: $email)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .autocapitalization(.none)
                            .keyboardType(.emailAddress)
                            .focused($focusedField, equals: .email)
                        
                        TextField("Телефон", text: $phone)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.phonePad)
                            .focused($focusedField, equals: .phone)
                        
                        SecureField("Пароль", text: $password)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .focused($focusedField, equals: .password)
                    }
                    .padding(.horizontal)
                    
                    if !authViewModel.errorMessage.isEmpty {
                        Text(authViewModel.errorMessage)
                            .font(.caption)
                            .foregroundColor(.red)
                            .padding(.horizontal)
                    }
                    
                    Button(action: {
                        authViewModel.register(
                            name: name,
                            email: email,
                            phone: phone,
                            password: password,
                            userType: userType
                        )
                        if authViewModel.isAuthenticated {
                            dismiss()
                        }
                    }) {
                        HStack {
                            if authViewModel.isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(0.8)
                            } else {
                                Text("Зарегистрироваться")
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(canRegister ? AppConstants.Colors.primary : Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .padding(.horizontal)
                    .disabled(!canRegister || authViewModel.isLoading)
                    
                    Spacer(minLength: AppConstants.Spacing.large)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Закрыть") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Далее") {
                        moveToNextField()
                    }
                    .opacity(focusedField != nil ? 1 : 0)
                }
            }
            .onTapGesture {
                focusedField = nil
            }
        }
    }
    
    private var canRegister: Bool {
        !name.isEmpty &&
        !email.isEmpty &&
        email.isValidEmail &&
        !phone.isEmpty &&
        !password.isEmpty &&
        password.count >= 6
    }
    
    private func moveToNextField() {
        switch focusedField {
        case .name:
            focusedField = .email
        case .email:
            focusedField = .phone
        case .phone:
            focusedField = .password
        case .password:
            focusedField = nil
        case .none:
            break
        }
    }
}

#Preview {
    AuthFlowView()
        .environmentObject(AuthViewModel())
}
