import SwiftUI
import PhotosUI
import os.log

// MARK: - Models
enum PaletteGenerationMethod: String, CaseIterable {
    case colorPicker = "Start with Color"
    case image = "From Image"
    case description = "From Description"
    
    var icon: String {
        switch self {
        case .colorPicker: return "paintpalette.fill"
        case .image: return "photo.fill"
        case .description: return "text.bubble.fill"
        }
    }
}

enum HarmonyType: String, CaseIterable {
    case complementary = "Complementary"
    case analogous = "Analogous"
    case triadic = "Triadic"
    case splitComplementary = "Split-Complementary"
}

enum Mood: String, CaseIterable {
    case warm = "Warm"
    case cool = "Cool"
    case vibrant = "Vibrant"
    case muted = "Muted"
    case dark = "Dark"
    case light = "Light"
}

// MARK: - Color Palette Generator View
struct ColorPaletteGenerator: View {
    // Debug logging
    private let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier ?? "com.canvascodex.app",
        category: "ColorPaletteGenerator"
    )
    
    // State
    @State private var selectedMethod: PaletteGenerationMethod = .colorPicker
    @State private var selectedColor = Color.blue
    @State private var selectedHarmony: HarmonyType = .complementary
    @State private var selectedImage: PhotosPickerItem?
    @State private var imageData: Data?
    @State private var isDominantColors = true
    @State private var description = ""
    @State private var selectedMoods: Set<Mood> = []
    @State private var numberOfColors: Double = 5
    @State private var includeShades = false
    @State private var includeNeutrals = false
    
    // Add model and state for generated colors
    @StateObject private var model = ColorPaletteModel()
    @State private var generatedColors: [PaletteColor] = []
    @State private var showingPalette = false
    
    // Layout
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 3)
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Method Selection
                methodSelectionGrid
                
                // Method-specific Content
                methodContent
                
                // Universal Controls
                universalControls
                
                // Generated Palette (if available)
                if showingPalette && !generatedColors.isEmpty {
                    ColorPaletteView(colors: generatedColors)
                        .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
            .padding()
        }
        .onChange(of: selectedImage) { newValue in
            Task {
                if let imageData = try? await newValue?.loadTransferable(type: Data.self),
                   let uiImage = UIImage(data: imageData) {
                    generatedColors = model.extractColors(from: uiImage,
                                                        isDominant: isDominantColors,
                                                        count: Int(numberOfColors))
                    withAnimation {
                        showingPalette = true
                    }
                }
            }
        }
    }
    
    // MARK: - Method Selection Grid
    private var methodSelectionGrid: some View {
        LazyVGrid(columns: columns, spacing: 12) {
            ForEach(PaletteGenerationMethod.allCases, id: \.self) { method in
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedMethod = method
                    }
                } label: {
                    VStack(spacing: 8) {
                        Image(systemName: method.icon)
                            .font(.system(size: 24))
                            .foregroundColor(selectedMethod == method ? .purple : .secondary)
                        
                        Text(method.rawValue)
                            .font(.caption)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(selectedMethod == method ? Color.purple.opacity(0.1) : Color(.systemGray6))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(selectedMethod == method ? Color.purple : Color.clear, lineWidth: 2)
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }
    
    // MARK: - Method Content
    private var methodContent: some View {
        VStack(spacing: 20) {
            switch selectedMethod {
            case .colorPicker:
                colorPickerContent
            case .image:
                imageContent
            case .description:
                descriptionContent
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemGray6))
        )
    }
    
    // MARK: - Color Picker Content
    private var colorPickerContent: some View {
        VStack(spacing: 16) {
            Text("Choose Starting Color")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            ColorPicker("Base Color", selection: $selectedColor)
                .labelsHidden()
            
            Text("Color Harmony")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                ForEach(HarmonyType.allCases, id: \.self) { harmony in
                    Button {
                        selectedHarmony = harmony
                    } label: {
                        Text(harmony.rawValue)
                            .font(.subheadline)
                            .padding(.vertical, 8)
                            .frame(maxWidth: .infinity)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(selectedHarmony == harmony ? Color.purple.opacity(0.1) : Color(.systemGray5))
                            )
                            .foregroundColor(selectedHarmony == harmony ? .purple : .primary)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
    
    // MARK: - Image Content
    private var imageContent: some View {
        VStack(spacing: 16) {
            Text("Upload Image")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            PhotosPicker(selection: $selectedImage, matching: .images) {
                VStack(spacing: 12) {
                    Image(systemName: "photo.stack")
                        .font(.system(size: 32))
                        .foregroundColor(.secondary)
                    
                    Text("Select Photo")
                        .font(.subheadline)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(.systemGray5))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            
            Text("Extraction Method")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack(spacing: 12) {
                Button {
                    isDominantColors = true
                } label: {
                    Text("Dominant Colors")
                        .font(.subheadline)
                        .padding(.vertical, 8)
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(isDominantColors ? Color.purple.opacity(0.1) : Color(.systemGray5))
                        )
                        .foregroundColor(isDominantColors ? .purple : .primary)
                }
                
                Button {
                    isDominantColors = false
                } label: {
                    Text("Color Distribution")
                        .font(.subheadline)
                        .padding(.vertical, 8)
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(!isDominantColors ? Color.purple.opacity(0.1) : Color(.systemGray5))
                        )
                        .foregroundColor(!isDominantColors ? .purple : .primary)
                }
            }
            .buttonStyle(.plain)
        }
    }
    
    // MARK: - Description Content
    private var descriptionContent: some View {
        VStack(spacing: 16) {
            Text("Describe Your Vision")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            TextEditor(text: $description)
                .frame(height: 100)
                .padding(8)
                .background(Color(.systemBackground))
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color(.systemGray3), lineWidth: 1)
                )
            
            Text("Mood")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                ForEach(Mood.allCases, id: \.self) { mood in
                    Button {
                        if selectedMoods.contains(mood) {
                            selectedMoods.remove(mood)
                        } else {
                            selectedMoods.insert(mood)
                        }
                    } label: {
                        Text(mood.rawValue)
                            .font(.subheadline)
                            .padding(.vertical, 8)
                            .frame(maxWidth: .infinity)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(selectedMoods.contains(mood) ? Color.purple.opacity(0.1) : Color(.systemGray5))
                            )
                            .foregroundColor(selectedMoods.contains(mood) ? .purple : .primary)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
    
    // MARK: - Universal Controls
    private var universalControls: some View {
        VStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Number of Colors: \(Int(numberOfColors))")
                    .font(.subheadline)
                
                Slider(value: $numberOfColors, in: 3...8, step: 1)
                    .tint(.purple)
            }
            
            HStack(spacing: 12) {
                Button {
                    includeShades.toggle()
                } label: {
                    Text("Include Shades")
                        .font(.subheadline)
                        .padding(.vertical, 8)
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(includeShades ? Color.purple.opacity(0.1) : Color(.systemGray5))
                        )
                        .foregroundColor(includeShades ? .purple : .primary)
                }
                
                Button {
                    includeNeutrals.toggle()
                } label: {
                    Text("Add Neutrals")
                        .font(.subheadline)
                        .padding(.vertical, 8)
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(includeNeutrals ? Color.purple.opacity(0.1) : Color(.systemGray5))
                        )
                        .foregroundColor(includeNeutrals ? .purple : .primary)
                }
            }
            .buttonStyle(.plain)
            
            // Generate Button
            Button {
                generatePalette()
            } label: {
                Text("Generate Palette")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.purple)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
    }
    
    // MARK: - Helper Methods
    private func generatePalette() {
        withAnimation {
            switch selectedMethod {
            case .colorPicker:
                generatedColors = model.generateHarmony(from: selectedColor,
                                                      type: selectedHarmony,
                                                      count: Int(numberOfColors))
            case .image:
                // Colors will be generated via onChange handler for selectedImage
                break
            case .description:
                generatedColors = model.generateFromDescription(description,
                                                             moods: selectedMoods,
                                                             count: Int(numberOfColors))
            }
            
            // Add shades if requested
            if includeShades, let baseColor = generatedColors.first {
                generatedColors.append(contentsOf: model.generateShades(for: baseColor.color, count: 3))
            }
            
            // Add neutrals if requested
            if includeNeutrals {
                generatedColors.append(contentsOf: model.generateNeutrals(count: 3))
            }
            
            showingPalette = true
        }
        
        logger.debug("Generated palette with method: \(selectedMethod.rawValue), colors: \(generatedColors.count)")
    }
} 