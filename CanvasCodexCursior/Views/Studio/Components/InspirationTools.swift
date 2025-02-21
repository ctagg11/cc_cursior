import SwiftUI
import PhotosUI

// MARK: - Models
struct ArtworkReference: Identifiable {
    let id = UUID()
    let title: String
    let artist: String
    let image: Image
    var isSaved: Bool = false
}

struct ColorPalette: Identifiable {
    let id = UUID()
    let name: String
    let colors: [Color]
    var isSaved: Bool = false
}

// MARK: - Reference Works View
struct ReferenceWorksView: View {
    @State private var selectedOption: ReferenceOption?
    @State private var searchText = ""
    @State private var selectedImage: PhotosPickerItem?
    @State private var selectedImageData: Data?
    @State private var showingImagePicker = false
    
    enum ReferenceOption: String, CaseIterable {
        case upload = "Upload Reference"
        case describe = "Describe Subject"
        case browse = "Browse Categories"
        
        var icon: String {
            switch self {
            case .upload: return "square.and.arrow.up"
            case .describe: return "text.magnifyingglass"
            case .browse: return "square.grid.2x2"
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // Options Grid
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                ForEach(ReferenceOption.allCases, id: \.self) { option in
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selectedOption = option
                        }
                    } label: {
                        VStack(spacing: 8) {
                            Image(systemName: option.icon)
                                .font(.system(size: 24))
                                .foregroundColor(.purple)
                            
                            Text(option.rawValue)
                                .font(.caption)
                                .foregroundColor(.primary)
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                        .aspectRatio(1, contentMode: .fit)
                        .padding(12)
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(selectedOption == option ? Color.purple : Color.clear, lineWidth: 2)
                        )
                    }
                }
            }
            
            // Selected Option Content
            if let option = selectedOption {
                switch option {
                case .upload:
                    PhotosPicker(selection: $selectedImage, matching: .images) {
                        VStack {
                            Image(systemName: "photo.stack")
                                .font(.system(size: 32))
                            Text("Select Photo")
                                .font(.headline)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    
                case .describe:
                    VStack(spacing: 12) {
                        TextField("Describe what you're looking for...", text: $searchText)
                            .textFieldStyle(.roundedBorder)
                            .padding(.horizontal)
                        
                        Text("Try: landscape painting, abstract sculpture, portrait photography")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                case .browse:
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(["Paintings", "Sculptures", "Photography", "Digital Art"], id: \.self) { category in
                                Text(category)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(Color(.systemGray6))
                                    .clipShape(Capsule())
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
            
            // Results Grid
            ScrollView {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                    ForEach(0..<4) { _ in
                        ArtworkCard(
                            artwork: ArtworkReference(
                                title: "Sample Artwork",
                                artist: "Artist Name",
                                image: Image(systemName: "photo")
                            )
                        )
                    }
                }
                .padding()
            }
        }
    }
}

// MARK: - Color Palette View
struct InspirationPaletteView: View {
    @State private var selectedOption: PaletteOption?
    @State private var selectedImage: PhotosPickerItem?
    @State private var selectedMood: String?
    @State private var selectedBaseColor: Color = .blue
    
    enum PaletteOption: String, CaseIterable {
        case fromImage = "From Image"
        case fromMood = "From Mood"
        case fromColor = "From Color"
        
        var icon: String {
            switch self {
            case .fromImage: return "photo"
            case .fromMood: return "heart.fill"
            case .fromColor: return "paintpalette.fill"
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // Options Grid
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                ForEach(PaletteOption.allCases, id: \.self) { option in
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selectedOption = option
                        }
                    } label: {
                        VStack(spacing: 8) {
                            Image(systemName: option.icon)
                                .font(.system(size: 24))
                                .foregroundColor(.purple)
                            
                            Text(option.rawValue)
                                .font(.caption)
                                .foregroundColor(.primary)
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                        .aspectRatio(1, contentMode: .fit)
                        .padding(12)
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(selectedOption == option ? Color.purple : Color.clear, lineWidth: 2)
                        )
                    }
                }
            }
            
            // Selected Option Content
            if let option = selectedOption {
                switch option {
                case .fromImage:
                    PhotosPicker(selection: $selectedImage, matching: .images) {
                        VStack {
                            Image(systemName: "photo.stack")
                                .font(.system(size: 32))
                            Text("Select Photo")
                                .font(.headline)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    
                case .fromMood:
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(["Calm", "Energetic", "Romantic", "Professional"], id: \.self) { mood in
                                Text(mood)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(selectedMood == mood ? Color.purple.opacity(0.2) : Color(.systemGray6))
                                    .foregroundColor(selectedMood == mood ? .purple : .primary)
                                    .clipShape(Capsule())
                                    .onTapGesture {
                                        selectedMood = mood
                                    }
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                case .fromColor:
                    ColorPicker("Base Color", selection: $selectedBaseColor)
                        .padding()
                }
            }
            
            // Results Grid
            ScrollView {
                VStack(spacing: 16) {
                    ForEach(0..<3) { index in
                        PaletteCard(
                            palette: ColorPalette(
                                name: "Palette \(index + 1)",
                                colors: [.blue, .purple, .pink, .orange, .yellow]
                            )
                        )
                    }
                }
                .padding()
            }
        }
    }
}

// MARK: - Helper Views
struct ArtworkCard: View {
    let artwork: ArtworkReference
    @State private var isSaved = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            artwork.image
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(height: 120)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            
            Text(artwork.title)
                .font(.subheadline)
                .fontWeight(.medium)
            
            Text(artwork.artist)
                .font(.caption)
                .foregroundColor(.secondary)
            
            HStack {
                Button {
                    isSaved.toggle()
                } label: {
                    Image(systemName: isSaved ? "heart.fill" : "heart")
                        .foregroundColor(.purple)
                }
                
                Spacer()
                
                Button {
                    // Download action
                } label: {
                    Image(systemName: "arrow.down.circle")
                        .foregroundColor(.purple)
                }
            }
        }
        .padding(8)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: Color.black.opacity(0.1), radius: 4, y: 2)
    }
}

struct PaletteCard: View {
    let palette: ColorPalette
    @State private var isSaved = false
    
    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 4) {
                ForEach(palette.colors, id: \.self) { color in
                    RoundedRectangle(cornerRadius: 8)
                        .fill(color)
                        .frame(height: 60)
                }
            }
            
            HStack {
                Text(palette.name)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Button {
                    isSaved.toggle()
                } label: {
                    Image(systemName: isSaved ? "heart.fill" : "heart")
                        .foregroundColor(.purple)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: Color.black.opacity(0.1), radius: 4, y: 2)
    }
} 