import SwiftUI

struct ComponentTagForm: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var viewContext
    
    let artwork: ArtworkEntity
    let type: ComponentType
    let location: CGPoint
    
    @StateObject private var viewModel = ArtworkViewModel()
    @State private var formData = ComponentTagFormData()
    @State private var showingError = false
    @State private var errorMessage = ""
    @State private var isAnimatingHeader = false
    
    var body: some View {
        NavigationStack {
            Form {
                // Header Section with Icon
                Section {
                    HStack {
                        Image(systemName: type.icon)
                            .font(.system(size: 30))
                            .foregroundStyle(.blue)
                            .frame(width: 60, height: 60)
                            .background(.blue.opacity(0.1))
                            .clipShape(Circle())
                            .rotation3DEffect(.degrees(isAnimatingHeader ? 360 : 0), axis: (x: 0, y: 1, z: 0))
                            .scaleEffect(isAnimatingHeader ? 1 : 0.8)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(type.title)
                                .font(.headline)
                            Text(type.description)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        .opacity(isAnimatingHeader ? 1 : 0)
                        .offset(x: isAnimatingHeader ? 0 : 20)
                    }
                    .listRowBackground(Color.clear)
                }
                
                // Main Details Section
                Section {
                    TextField(
                        type == .subject ? "What is this?" : "What technique/process?",
                        text: $formData.name
                    )
                    .textFieldStyle(.roundedBorder)
                }
                
                // Ratings Section
                Section("Ratings") {
                    VStack(alignment: .leading, spacing: 12) {
                        RatingRow(
                            title: formData.rating1Label,
                            rating: $formData.rating1
                        )
                        
                        RatingRow(
                            title: formData.rating2Label,
                            rating: $formData.rating2
                        )
                    }
                }
                
                // Notes Section
                Section(type == .process ? "Process Steps" : "Notes") {
                    if type == .process {
                        TextEditor(text: $formData.processSteps)
                            .frame(minHeight: 100)
                    }
                    
                    TextEditor(text: $formData.notes)
                        .frame(minHeight: 100)
                }
            }
            .navigationTitle("New \(type == .subject ? "Subject" : "Process") Tag")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        withAnimation {
                            dismiss()
                        }
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveTag()
                    }
                    .disabled(!formData.isValid)
                }
            }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
        .onAppear {
            withAnimation(.spring(duration: 0.6)) {
                isAnimatingHeader = true
            }
        }
        .alert("Error Saving Tag", isPresented: $showingError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
    }
    
    private func saveTag() {
        formData.type = type
        formData.locationX = location.x
        formData.locationY = location.y
        
        do {
            try viewModel.createComponentTag(formData, for: artwork)
            withAnimation {
                dismiss()
            }
        } catch {
            errorMessage = error.localizedDescription
            showingError = true
        }
    }
}

struct RatingRow: View {
    let title: String
    @Binding var rating: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            HStack(spacing: 12) {
                ForEach(1...5, id: \.self) { star in
                    Image(systemName: star <= rating ? "star.fill" : "star")
                        .font(.title2)
                        .foregroundStyle(star <= rating ? .yellow : .gray.opacity(0.3))
                        .scaleEffect(star <= rating ? 1.2 : 1.0)
                        .onTapGesture {
                            withAnimation(.interpolatingSpring(duration: 0.3)) {
                                rating = star
                            }
                        }
                        .symbolEffect(.bounce, value: rating)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    ComponentTagForm(
        artwork: ArtworkEntity(context: PersistenceController.shared.container.viewContext),
        type: .subject,
        location: CGPoint(x: 100, y: 100)
    )
} 