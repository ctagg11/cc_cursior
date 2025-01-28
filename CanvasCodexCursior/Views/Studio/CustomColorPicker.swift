import SwiftUI

struct CustomColorPicker: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedColors: [PaintColor]
    @State private var colorName = ""
    @State private var selectedColor = Color.red
    @State private var selectedType = PaintType.oil
    @State private var showingError = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Color Details") {
                    TextField("Color Name", text: $colorName)
                    
                    Picker("Paint Type", selection: $selectedType) {
                        ForEach(PaintType.allCases, id: \.self) { type in
                            Text(type.rawValue.capitalized).tag(type)
                        }
                    }
                    
                    ColorPicker("Select Color", selection: $selectedColor)
                }
                
                Section {
                    Button("Add Color") {
                        guard !colorName.isEmpty else {
                            showingError = true
                            return
                        }
                        
                        let customColor = PaintColor(
                            name: colorName,
                            brand: .custom,
                            color: selectedColor,
                            type: selectedType,
                            isCustom: true
                        )
                        
                        selectedColors.append(customColor)
                        dismiss()
                    }
                }
            }
            .navigationTitle("Add Custom Color")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .alert("Missing Color Name", isPresented: $showingError) {
                Button("OK") {}
            } message: {
                Text("Please enter a name for your custom color.")
            }
        }
    }
} 