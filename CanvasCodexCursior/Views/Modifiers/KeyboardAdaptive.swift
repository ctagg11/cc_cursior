import SwiftUI
import Combine

struct KeyboardAdaptiveModifier: ViewModifier {
    @State private var keyboardHeight: CGFloat = 0
    
    func body(content: Content) -> some View {
        content
            .offset(y: -keyboardHeight)
            .onAppear {
                NotificationCenter.default.addObserver(
                    forName: UIResponder.keyboardWillShowNotification,
                    object: nil,
                    queue: .main
                ) { notification in
                    let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect
                    keyboardHeight = keyboardFrame?.height ?? 0
                }
                
                NotificationCenter.default.addObserver(
                    forName: UIResponder.keyboardWillHideNotification,
                    object: nil,
                    queue: .main
                ) { _ in
                    keyboardHeight = 0
                }
            }
            .onDisappear {
                NotificationCenter.default.removeObserver(self)
            }
            .animation(.easeOut(duration: 0.16), value: keyboardHeight)
    }
}

extension View {
    func keyboardAdaptive() -> some View {
        modifier(KeyboardAdaptiveModifier())
    }
} 