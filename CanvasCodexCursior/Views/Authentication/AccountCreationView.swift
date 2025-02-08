import SwiftUI

struct AccountCreationView: View {
    @Binding var email: String
    @Binding var password: String
    @State private var confirmPassword = ""
    @State private var showingError = false
    @State private var errorMessage = ""
    let onComplete: () -> Void
    
    var isValid: Bool {
        !email.isEmpty && 
        !password.isEmpty && 
        password == confirmPassword &&
        password.count >= 8 &&
        email.contains("@")
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Text("Create Your Account")
                    .font(.title2.bold())
                
                Text("Almost there! Set up your login credentials")
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                
                VStack(spacing: 16) {
                    // Email Field
                    AuthTextField(
                        label: "Email",
                        placeholder: "Enter your email",
                        icon: "envelope",
                        text: $email
                    )
                    .textInputAutocapitalization(.never)
                    .keyboardType(.emailAddress)
                    
                    // Password Field
                    AuthTextField(
                        label: "Password",
                        placeholder: "Create password",
                        icon: "lock",
                        isSecureField: true,
                        text: $password
                    )
                    
                    // Confirm Password Field
                    AuthTextField(
                        label: "Confirm Password",
                        placeholder: "Confirm password",
                        icon: "lock",
                        isSecureField: true,
                        text: $confirmPassword
                    )
                    
                    // Password Requirements
                    if !password.isEmpty {
                        VStack(alignment: .leading, spacing: 4) {
                            PasswordRequirement("At least 8 characters", 
                                             isMet: password.count >= 8)
                            PasswordRequirement("Passwords match", 
                                             isMet: !confirmPassword.isEmpty && password == confirmPassword)
                        }
                        .padding(.top, 4)
                    }
                }
                .padding(.horizontal)
                
                // Create Account Button
                AuthButton(
                    title: "Create Account",
                    icon: "person.badge.plus",
                    action: validateAndComplete
                )
                .disabled(!isValid)
                .padding(.horizontal)
                
                Spacer()
                    .frame(height: 40) // Add some bottom padding for keyboard
            }
            .padding()
        }
        .alert("Error", isPresented: $showingError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
    }
    
    private func validateAndComplete() {
        guard isValid else {
            errorMessage = "Please check all requirements"
            showingError = true
            return
        }
        onComplete()
    }
}

// Helper view for password requirements
struct PasswordRequirement: View {
    let text: String
    let isMet: Bool
    
    init(_ text: String, isMet: Bool) {
        self.text = text
        self.isMet = isMet
    }
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: isMet ? "checkmark.circle.fill" : "circle")
                .foregroundColor(isMet ? .green : .gray)
            
            Text(text)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
} 