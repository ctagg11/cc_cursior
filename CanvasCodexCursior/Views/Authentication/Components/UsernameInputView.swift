import SwiftUI

struct UsernameInputView: View {
    @Binding var firstName: String
    @Binding var lastName: String
    @Binding var birthDate: Date
    var onNext: () -> Void
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Text("Create Your Profile")
                    .font(.title2.bold())
                
                Text("This will give you a place to store your artwork and help your friends find you")
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                
                VStack(spacing: 16) {
                    TextField("First Name", text: $firstName)
                        .textFieldStyle(.roundedBorder)
                    
                    TextField("Last Name", text: $lastName)
                        .textFieldStyle(.roundedBorder)
                    
                    DatePicker("Birth Date", selection: $birthDate, displayedComponents: .date)
                        .datePickerStyle(.compact)
                }
                .padding(.horizontal)
                
                Button {
                    if !firstName.isEmpty && !lastName.isEmpty {
                        onNext()
                    }
                } label: {
                    Text("Next")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(firstName.isEmpty || lastName.isEmpty ? Color.gray : Color.accentColor)
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .disabled(firstName.isEmpty || lastName.isEmpty)
                
                Spacer()
                    .frame(height: 40) // Add some bottom padding for keyboard
            }
            .padding()
        }
    }
}

#Preview {
    UsernameInputView(
        firstName: .constant(""),
        lastName: .constant(""),
        birthDate: .constant(Date()),
        onNext: {}
    )
} 