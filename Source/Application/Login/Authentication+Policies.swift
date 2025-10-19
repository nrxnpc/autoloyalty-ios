import Combine
import SwiftUI

// MARK: - Policies

extension Authentication {
    // MARK: - Password Policy

    static func hasMinimumLength(password: String) -> Bool {
        let minimumPasswordLength = 8
        return password.count >= minimumPasswordLength
    }
    
    static func containsUppercaseLetter(password: String) -> Bool {
        let uppercasePattern = ".*[A-Z]+.*"
        let uppercasePredicate = NSPredicate(format: "SELF MATCHES %@", uppercasePattern)
        return uppercasePredicate.evaluate(with: password)
    }
    
    static func containsNumber(password: String) -> Bool {
        let numberPattern = ".*[0-9]+.*"
        let numberPredicate = NSPredicate(format: "SELF MATCHES %@", numberPattern)
        return numberPredicate.evaluate(with: password)
    }
    
    static func containsSpecialCharacter(password: String) -> Bool {
        let specialCharacterPattern = ".*[!@#$%^&*(),.?\":{}|<>]+.*"
        let specialCharacterPredicate = NSPredicate(format: "SELF MATCHES %@", specialCharacterPattern)
        return specialCharacterPredicate.evaluate(with: password)
    }

    // MARK: - Email Policy
    
    static func contains(email: String) -> Bool {
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}")
        return emailPredicate.evaluate(with: email)
    }
}

// MARK: - Policies Validation

extension View {
    func validated(name namePublisher: Published<String>.Publisher) -> some View {
        modifier(ValidatedViewModifier(publisher: namePublisher, validation: .name))
    }
    
    func validated(email emailPublisher: Published<String>.Publisher) -> some View {
        modifier(ValidatedViewModifier(publisher: emailPublisher, validation: .email))
    }
    
    func validated(password passwordPublisher: Published<String>.Publisher, minimumRequirements: Bool = false) -> some View {
        modifier(ValidatedViewModifier(publisher: passwordPublisher, validation: .password(minimumRequirements)))
    }
}

private struct ValidatedViewModifier: ViewModifier {
    @StateObject private var validator: Validator
    
    fileprivate init(publisher: Published<String>.Publisher, validation: Validator.Validation) {
        _validator = .init(wrappedValue: .init(publisher: publisher, validation: validation))
    }
    
    // MARK: -
    
    func body(content: Content) -> some View {
        content
            .disabled(!validator.isValid)
            .animation(.smooth, value: validator.isValid)
    }
}

@MainActor
private final class Validator: ObservableObject {
    enum Validation {
        case name, email, password(Bool)
        @MainActor func check(value: String) -> Bool {
            switch self {
            case .name: return !value.isEmpty
            case .email: return Authentication.contains(email: value)
            case .password(let minimumRequirements):
                if minimumRequirements {
                    return !value.isEmpty
                } else {
                    return Authentication.hasMinimumLength(password: value) &&
                        Authentication.containsUppercaseLetter(password: value) &&
                        Authentication.containsNumber(password: value) &&
                        Authentication.containsSpecialCharacter(password: value)
                }
            }
        }
    }
    
    @Published var isValid: Bool = false
    private var cancellables = Set<AnyCancellable>()
    
    init(publisher: Published<String>.Publisher, validation: Validation) {
        publisher
            .debounce(for: .seconds(0.25), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .map(validation.check(value:))
            .sink { [weak self] in
                self?.isValid = $0
            }
            .store(in: &cancellables)
    }
}
