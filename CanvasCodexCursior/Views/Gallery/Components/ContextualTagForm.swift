import SwiftUI

struct ContextualTagForm: View {
    @Binding var isPresented: Bool
    let location: CGPoint
    let artwork: ArtworkEntity
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var viewModel = ArtworkViewModel()
    
    @State private var formData = ComponentTagFormData()
    @State private var selectedType: ComponentType = .subject
    
    // Calculate if form should appear above or below touch point
    private var shouldShowAbove: Bool {
        location.y > UIScreen.main.bounds.height / 2
    }
    
    var body: some View {
        ZStack {
            // Full screen clear overlay to detect taps outside
            Color.clear
                .contentShape(Rectangle())
                .onTapGesture {
                    withAnimation(.easeOut(duration: 0.2)) {
                        isPresented = false
                    }
                }
            
            VStack(spacing: 0) {
                if shouldShowAbove {
                    formContent
                    connector
                } else {
                    connector
                    formContent
                }
            }
            .position(x: clampedX, y: clampedY)
            .keyboardAdaptive()
        }
        .transition(.opacity.combined(with: .scale))
    }
    
    private var connector: some View {
        Rectangle()
            .fill(.ultraThinMaterial)
            .frame(width: 2, height: 20)
    }
    
    private var formContent: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Type Selector
            HStack(spacing: 12) {
                ForEach(ComponentType.allCases) { type in
                    Button {
                        withAnimation(.spring(duration: 0.3)) {
                            selectedType = type
                            formData.type = type
                        }
                    } label: {
                        VStack(spacing: 4) {
                            Image(systemName: type.icon)
                                .font(.system(size: 16))
                            Text(type.title)
                                .font(.caption2)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 6)
                        .background(type == selectedType ? Color.blue.opacity(0.3) : Color.clear)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                    .buttonStyle(.plain)
                }
            }
            
            Divider()
            
            // Name Input
            TextField("Name", text: $formData.name)
                .textFieldStyle(.roundedBorder)
                .font(.subheadline)
            
            // Ratings
            VStack(alignment: .leading, spacing: 8) {
                RatingSlider(
                    rating: $formData.rating1,
                    label: formData.rating1Label
                )
                RatingSlider(
                    rating: $formData.rating2,
                    label: formData.rating2Label
                )
            }
            
            // Save Buttons
            HStack(spacing: 8) {
                Button("Add Another") {
                    saveTag()
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 6)
                .background(formData.isValid ? Color.blue.opacity(0.7) : Color.gray)
                .foregroundColor(.white)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .font(.subheadline)
                
                Button("Save") {
                    saveTag()
                    isPresented = false
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 6)
                .background(formData.isValid ? Color.blue : Color.gray)
                .foregroundColor(.white)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .font(.subheadline)
            }
            .disabled(!formData.isValid)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .frame(width: 300)
    }
    
    private func saveTag() {
        formData.locationX = location.x
        formData.locationY = location.y
        
        do {
            try viewModel.createComponentTag(formData, for: artwork)
        } catch {
            print("Error saving tag: \(error)")
        }
    }
    
    // Add these computed properties to keep form on screen
    private var clampedX: CGFloat {
        let halfWidth: CGFloat = 150 // Half of form width
        return min(max(location.x, halfWidth), UIScreen.main.bounds.width - halfWidth)
    }
    
    private var clampedY: CGFloat {
        let formHeight: CGFloat = 400 // Approximate form height
        let yOffset = shouldShowAbove ? -formHeight/2 - 20 : formHeight/2 + 20
        let targetY = location.y + yOffset
        // Keep form in top 2/3 of screen to avoid keyboard
        return min(max(targetY, formHeight/2), UIScreen.main.bounds.height * 0.6)
    }
}

struct StarRatingInput: View {
    @Binding var rating: Int
    let label: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.subheadline)
            HStack {
                ForEach(1...5, id: \.self) { star in
                    Image(systemName: star <= rating ? "star.fill" : "star")
                        .foregroundStyle(star <= rating ? .yellow : .gray.opacity(0.3))
                        .onTapGesture {
                            withAnimation(.bouncy(duration: 0.2)) {
                                rating = star
                            }
                        }
                }
            }
        }
    }
}

struct RatingSlider: View {
    @Binding var rating: Int
    let label: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
            
            HStack {
                Text("1")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                
                Slider(
                    value: Binding(
                        get: { Double(rating) },
                        set: { rating = Int(round($0)) }
                    ),
                    in: 1...5,
                    step: 1
                )
                .tint(.blue)
                
                Text("5")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
    }
}
