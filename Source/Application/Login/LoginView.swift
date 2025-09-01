import SwiftUI

struct LoginView: View {
    @EnvironmentObject private var authViewModel: AuthViewModel
    @State private var email = ""
    @State private var password = ""
    @State private var showingRoleSelector = false
    
    private let productionUsers = [
        ("customer@nsp.com", "Пользователь"),
        ("supplier@nsp.com", "Поставщик"),
        ("admin@nsp.com", "Администратор платформы")
    ]
    
    var body: some View {
        VStack(spacing: 30) {
            // Логотип
            VStack(spacing: 16) {
                Image(systemName: "car.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.blue)
                
                Text("Автолояльность")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Универсальная программа лояльности для автолюбителей")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            // Форма входа
            VStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Email")
                        .font(.headline)
                    
                    TextField("Введите email", text: $email)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Пароль")
                        .font(.headline)
                    
                    SecureField("Введите пароль", text: $password)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                if authViewModel.isLoading {
                    ProgressView("Вход в систему...")
                        .padding()
                } else {
                    Button("Войти") {
                        Task {
                            authViewModel.login(email: email, password: password)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .disabled(email.isEmpty || password.isEmpty)
                }
                
                if !authViewModel.errorMessage.isEmpty {
                    Text(authViewModel.errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                        .multilineTextAlignment(.center)
                }
                
                NavigationLink("Регистрация", destination: RegistrationView())
                    .font(.subheadline)
                    .foregroundColor(.blue)
            }
            
            Divider()
            
            // Быстрый вход для тестирования
            VStack(spacing: 16) {
                Text("Быстрый вход")
                    .font(.headline)
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                    ForEach(productionUsers, id: \.0) { userEmail, roleName in
                        Button(roleName) {
                            email = userEmail
                            password = "123456"
                            Task {
                                authViewModel.login(email: userEmail, password: "123456")
                            }
                        }
                        .font(.caption)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color.blue.opacity(0.1))
                        .foregroundColor(.blue)
                        .cornerRadius(8)
                    }
                }
            }
            
            Spacer()
        }
        .padding()
    }
}

#Preview {
    LoginView()
        .environmentObject(AuthViewModel())
}