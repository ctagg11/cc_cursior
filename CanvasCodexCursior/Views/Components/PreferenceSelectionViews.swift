import SwiftUI

struct PreferenceSelectionView<T: CaseIterable & RawRepresentable & Identifiable>: View where T.RawValue == String {
    let title: String
    let description: String
    @Binding var selection: T
    var onNext: (() -> Void)?
    
    var body: some View {
        VStack(spacing: 24) {
            Text(title)
                .font(.title2.bold())
            
            Text(description)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            VStack(spacing: 12) {
                ForEach(Array(T.allCases)) { option in
                    Button {
                        selection = option
                        if let onNext = onNext {
                            onNext()
                        }
                    } label: {
                        HStack {
                            Text(option.rawValue)
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            if selection == option {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.accentColor)
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(selection == option ? Color.accentColor.opacity(0.1) : Color.gray.opacity(0.1))
                        )
                    }
                }
            }
            .padding(.horizontal)
        }
        .padding()
    }
}

struct MultiSelectionView<T: CaseIterable & RawRepresentable & Identifiable>: View where T.RawValue == String {
    let title: String
    let description: String
    @Binding var selection: [T]
    var onNext: (() -> Void)?
    
    var body: some View {
        VStack(spacing: 24) {
            Text(title)
                .font(.title2.bold())
            
            Text(description)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            VStack(spacing: 12) {
                ForEach(Array(T.allCases)) { option in
                    Button {
                        if selection.contains(where: { $0.rawValue == option.rawValue }) {
                            selection.removeAll(where: { $0.rawValue == option.rawValue })
                        } else {
                            selection.append(option)
                        }
                    } label: {
                        HStack {
                            Text(option.rawValue)
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            if selection.contains(where: { $0.rawValue == option.rawValue }) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.accentColor)
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(selection.contains(where: { $0.rawValue == option.rawValue }) ? 
                                     Color.accentColor.opacity(0.1) : Color.gray.opacity(0.1))
                        )
                    }
                }
            }
            .padding(.horizontal)
            
            if let onNext = onNext {
                Button {
                    onNext()
                } label: {
                    Text("Next")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(selection.isEmpty ? Color.gray : Color.accentColor)
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .disabled(selection.isEmpty)
                .padding(.horizontal)
            }
        }
        .padding()
    }
} 