import SwiftUI

struct CreateProjectSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var viewModel = ArtworkViewModel()
    @State private var projectData = ProjectFormData()
    @State private var showingImagePicker = false
    @State private var showingPaintSelector = false
    @State private var selectedColors: [PaintColor] = []
    @State private var selectedImage: UIImage?
    
    // New properties for initial update
    var initialUpdate: InitialUpdate?
    @State private var updateTitle = ""
    @State private var changes = ""
    @State private var todoNotes = ""
    @State private var isPublic = false
    
    var body: some View {
        NavigationStack {
            Form {
                // Basic Info Section
                Section("Project Details") {
                    AppTextField(
                        label: "Project Name",
                        placeholder: "Enter project name",
                        icon: "paintpalette",
                        text: $projectData.name
                    )
                    
                    Picker("Medium", selection: $projectData.medium) {
                        Text("Select Medium").tag("")
                        ForEach(CommonMediums.allCases, id: \.self) { medium in
                            Text(medium.rawValue).tag(medium.rawValue)
                        }
                    }
                    
                    DatePicker("Start Date", selection: $projectData.startDate, displayedComponents: .date)
                }
                
                // Reference & Inspiration Section
                Section("References & Inspiration") {
                    TextEditor(text: $projectData.inspiration)
                        .frame(minHeight: 100)
                        .overlay(
                            Group {
                                if projectData.inspiration.isEmpty {
                                    Text("Add notes about your inspiration, reference images, or ideas...")
                                        .foregroundColor(.secondary)
                                        .padding(.leading, 4)
                                        .padding(.top, 8)
                                        .allowsHitTesting(false)
                                }
                            },
                            alignment: .topLeading
                        )
                    
                    // References Grid
                    if !projectData.references.isEmpty {
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 80))], spacing: 8) {
                            ForEach(projectData.references) { reference in
                                Image(uiImage: reference.image)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 80, height: 80)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                            }
                        }
                    }
                    
                    // Reference Image Section
                    if let image = selectedImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 200)
                        
                        Button("Remove Image", role: .destructive) {
                            selectedImage = nil
                        }
                    } else {
                        Button {
                            showingImagePicker = true
                        } label: {
                            Label("Add Reference Image", systemImage: "photo")
                        }
                    }
                }
                
                // Project Planning Section
                Section("Project Planning") {
                    Picker("Estimated Time", selection: $projectData.timeEstimate) {
                        ForEach(TimeEstimate.allCases, id: \.self) { estimate in
                            Text(estimate.description).tag(estimate)
                        }
                    }
                    
                    Picker("Priority", selection: $projectData.priority) {
                        ForEach(ProjectPriority.allCases, id: \.self) { priority in
                            Text(priority.description).tag(priority)
                        }
                    }
                }
                
                // Color Palette Section
                Section("Color Palette") {
                    VStack(alignment: .leading, spacing: 8) {
                        AppText(text: "Selected Colors", style: .caption)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(selectedColors) { color in
                                    PaintColorChip(paint: color, isSelected: false)
                                }
                                
                                Button {
                                    showingPaintSelector = true
                                } label: {
                                    Image(systemName: "plus.circle.fill")
                                        .font(.title2)
                                        .foregroundStyle(AppTheme.Colors.primary)
                                }
                            }
                            .padding(.horizontal, 4)
                        }
                    }
                }
                
                // Add new Initial Update section if provided
                if let update = initialUpdate {
                    Section("Initial Update") {
                        Image(uiImage: update.image)
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 200)
                        
                        AppTextField(
                            label: "Update Title",
                            placeholder: "What did you accomplish?",
                            icon: "pencil",
                            text: $updateTitle
                        )
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Changes Made")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            TextEditor(text: $changes)
                                .frame(height: 100)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Todo Notes")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            TextEditor(text: $todoNotes)
                                .frame(height: 100)
                        }
                        
                        Toggle("Share to Public Feed", isOn: $isPublic)
                    }
                }
            }
            .navigationTitle("New Project")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") {
                        save()
                    }
                    .disabled(projectData.name.isEmpty)
                }
            }
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(selectedImage: $selectedImage)
            }
            .sheet(isPresented: $showingPaintSelector) {
                PaintSelectorView(selectedColors: $selectedColors)
            }
        }
    }
    
    private func save() {
        do {
            // Create the project first
            try viewModel.createProject(projectData, context: viewContext)
            
            // If we have an initial update, save it
            if let update = initialUpdate {
                try viewModel.saveWorkInProgress(
                    projectName: projectData.name,
                    updateTitle: updateTitle,
                    changes: changes,
                    todoNotes: todoNotes,
                    isPublic: isPublic,
                    image: update.image
                )
            }
            
            dismiss()
        } catch {
            // Handle error
        }
    }
}

// Simplified preview for faster loading
#Preview("Basic") {
    CreateProjectSheet()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}

// Sample data for previews
extension PersistenceController {
    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        // Add sample data here if needed
        return result
    }()
}

// Color chip view - for displaying individual colors
struct PaintColorChip: View {
    let paint: PaintColor
    let isSelected: Bool
    
    var body: some View {
        VStack(spacing: 4) {
            Circle()
                .fill(paint.color)
                .frame(width: 40, height: 40)
                .overlay(
                    Circle()
                        .strokeBorder(isSelected ? Color.white : Color.clear, lineWidth: 2)
                )
                .shadow(radius: isSelected ? 4 : 2)
            
            Text(paint.name)
                .font(.caption2)
                .lineLimit(1)
                .multilineTextAlignment(.center)
        }
        .frame(width: 80)
    }
}

// Paint selector view
struct PaintSelectorView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedColors: [PaintColor]
    @State private var selectedBrand: PaintBrand = .winsorNewton
    @State private var selectedType: PaintType = .oil
    @State private var showingCustomColorPicker = false
    @State private var tempSelectedColors: Set<UUID> = []
    
    var body: some View {
        NavigationStack {
            List {
                Picker("Brand", selection: $selectedBrand) {
                    ForEach(PaintBrand.allCases, id: \.self) { brand in
                        Text(brand.rawValue).tag(brand)
                    }
                }
                
                if selectedBrand != .custom {
                    Picker("Type", selection: $selectedType) {
                        ForEach(selectedBrand.types, id: \.self) { type in
                            Text(type.rawValue.capitalized).tag(type)
                        }
                    }
                    
                    Section("Available Colors") {
                        let colors = PaintDatabase.shared.getColors(for: selectedBrand, type: selectedType)
                        ScrollView {
                            LazyVGrid(columns: [
                                GridItem(.adaptive(minimum: 80), spacing: 16)
                            ], spacing: 16) {
                                ForEach(colors) { paint in
                                    Button {
                                        if tempSelectedColors.contains(paint.id) {
                                            tempSelectedColors.remove(paint.id)
                                        } else {
                                            tempSelectedColors.insert(paint.id)
                                        }
                                    } label: {
                                        PaintColorChip(
                                            paint: paint,
                                            isSelected: tempSelectedColors.contains(paint.id)
                                        )
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                    .id(paint.id)
                                }
                            }
                            .padding()
                        }
                    }
                }
            }
            .navigationTitle("Select Colors")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        let colors = PaintDatabase.shared.getColors(for: selectedBrand, type: selectedType)
                        selectedColors = colors.filter { tempSelectedColors.contains($0.id) }
                        dismiss()
                    }
                }
            }
            .onAppear {
                tempSelectedColors = Set(selectedColors.map { $0.id })
            }
        }
    }
}

#Preview {
    PaintSelectorView(selectedColors: .constant([]))
}

#Preview("Color Chip") {
    HStack {
        let paint = PaintDatabase.shared.getColors(for: .winsorNewton, type: .oil)[0]
        PaintColorChip(paint: paint, isSelected: false)
        PaintColorChip(paint: paint, isSelected: true)
    }
    .padding()
}

