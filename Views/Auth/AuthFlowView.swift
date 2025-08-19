import SwiftUI

struct AuthFlowView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var showingLogin = false
    @State private var showingRegistration = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: AppConstants.Spacing.extraLarge) {
                // Logo и заголовок
                VStack(spacing: AppConstants.Spacing.medium) {
                    Image(systemName: AppConstants.Images.car)
                        .font(.system(size: 80))
                        .foregroundColor(AppConstants.Colors.primary)
                    
                    Text("NSP")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Программа лояльности\nдля автолюбителей")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                
                Spacer()
                
                // Кнопки входа и регистрации
                VStack(spacing: AppConstants.Spacing.medium) {
                    Button(action: { showingLogin = true }) {
                        Text("Войти")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(AppConstants.Colors.primary)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                    
                    Button(action: { showingRegistration = true }) {
                        Text("Регистрация")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.clear)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(AppConstants.Colors.primary, lineWidth: 2)
                            )
                            .foregroundColor(AppConstants.Colors.primary)
                    }
                    
                    // Демо доступы
                    DemoAccessButtons()
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .padding()
            .sheet(isPresented: $showingLogin) {
                LoginView()
            }
            .sheet(isPresented: $showingRegistration) {
                RegistrationView()
            }
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
                
                Button("Администратор") {
                    authViewModel.login(email: "admin@nsp.com", password: "123456")
                }
                .font(.caption)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.green.opacity(0.1))
                .foregroundColor(.green)
                .cornerRadius(8)
            }
        }
        .padding(.top)
    }
}

struct LoginView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var email = ""
    @State private var password = ""
    @FocusState private var isEmailFocused: Bool
    @FocusState private var isPasswordFocused: Bool
    
    var body: some View {
        NavigationStack {
            VStack(spacing: AppConstants.Spacing.large) {
                Text("Вход")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.top)
                
                VStack(spacing: AppConstants.Spacing.medium) {
                    TextField("Email", text: $email)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .autocapitalization(.none)
                        .keyboardType(.emailAddress)
                        .focused($isEmailFocused)
                    
                    SecureField("Пароль", text: $password)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .focused($isPasswordFocused)
                }
                .padding(.horizontal)
                
                if !authViewModel.errorMessage.isEmpty {
                    Text(authViewModel.errorMessage)
                        .font(.caption)
                        .foregroundColor(.red)
                        .padding(.horizontal)
                }
                
                Button(action: {
                    authViewModel.login(email: email, password: password)
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
                            Text("Войти")
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(canLogin ? AppConstants.Colors.primary : Color.gray)
                .foregroundColor(.white)
                .cornerRadius(12)
                .padding(.horizontal)
                .disabled(!canLogin || authViewModel.isLoading)
                
                Spacer()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Закрыть") {
                        dismiss()
                    }
                }
            }
            .onTapGesture {
                isEmailFocused = false
                isPasswordFocused = false
            }
        }
    }
    
    private var canLogin: Bool {
        !email.isEmpty && !password.isEmpty
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
