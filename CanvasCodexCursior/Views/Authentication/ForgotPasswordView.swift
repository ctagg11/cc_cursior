import SwiftUI
import FirebaseAuth

struct ForgotPasswordView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var email = ""
    @State private var showingSuccess = false
    @State private var showingError = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                AuthHeader(
                    title: "Reset Password",
                    subtitle: "Enter your email and we'll send you a reset link"
                )
                
                AuthTextField(
                    label: "Email",
                    placeholder: "Enter your email",
                    icon: "envelope",
                    text: $email
                )
                .textInputAutocapitalization(.never)
                .keyboardType(.emailAddress)
                .padding(.horizontal)
                
                AuthButton(
                    title: "Send Reset Link",
                    icon: "envelope",
                    action: handlePasswordReset
                )
                .padding(.horizontal)
                
                Spacer()
            }
            .padding()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .alert("Success", isPresented: $showingSuccess) {
                Button("OK") { dismiss() }
            } message: {
                Text("Check your email for password reset instructions.")
            }
            .alert("Error", isPresented: $showingError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    private func handlePasswordReset() {
        Task {
            do {
                try await Auth.auth().sendPasswordReset(withEmail: email)
                showingSuccess = true
            } catch {
                errorMessage = error.localizedDescription
                showingError = true
            }
        }
    }
} 