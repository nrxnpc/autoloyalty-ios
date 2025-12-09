import Combine
import SwiftUI

fileprivate let strongPassworsOnly = false

struct PasswordRequirementsView: View {
    @Binding var password: String
    
    @State private(set) var hasMinimumLength = false
    @State private(set) var containsUppercaseLetter = false
    @State private(set) var containsNumber = false
    @State private(set) var containsSpecialCharacter = false
    
    var body: some View {
        makePasswordRequirementsList()
            .onChange(of: password) {
                updateChecklist()
            }
    }
    
    @MainActor
    func updateChecklist() {
        hasMinimumLength = Authentication.hasMinimumLength(password: password)
        if strongPassworsOnly {
             containsUppercaseLetter = Authentication.containsUppercaseLetter(password: password)
             containsNumber = Authentication.containsNumber(password: password)
             containsSpecialCharacter = Authentication.containsSpecialCharacter(password: password)
        }
    }
}

extension PasswordRequirementsView {
    @ViewBuilder func makePasswordRequirementsList() -> some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Make sure your password includes:")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                    .padding(.bottom)
                
                makeRequirementStatusRow(
                    text: "Minimum of 8 characters",
                    satisfies: hasMinimumLength)
                
                if strongPassworsOnly {
                    makeRequirementStatusRow(
                        text: "At least one uppercase letter",
                        satisfies: containsUppercaseLetter)
                    
                    makeRequirementStatusRow(
                        text: "At least one number",
                        satisfies: containsNumber)
                    
                    makeRequirementStatusRow(
                        text: "At least one special character",
                        satisfies: containsSpecialCharacter)
                }
            }
            .animation(.smooth, value: [hasMinimumLength, containsUppercaseLetter, containsNumber, containsSpecialCharacter])
            .padding()
            
            Spacer()
        }
    }
    
    @ViewBuilder func makeRequirementStatusRow(text: String, satisfies: Bool) -> some View {
        HStack {
            if satisfies {
                Image(systemName: "checkmark.circle")
                    .foregroundStyle(.green)
                    .transition(.scale.animation(.easeOut))
            } else {
                Image(systemName: "xmark.circle")
                    .foregroundStyle(.gray)
                    .transition(.scale.animation(.easeOut))
            }
            
            Text(text)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    PasswordRequirementsView(password: .constant(""))
}
