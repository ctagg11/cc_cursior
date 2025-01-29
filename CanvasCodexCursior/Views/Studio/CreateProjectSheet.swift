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
                    AppTextField(
                        label: "Inspiration",
                        placeholder: "What inspired this project?",
                        icon: "sparkles",
                        text: $projectData.inspiration
                    )
                    
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
                    Section("Reference Image") {
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
                                    PaintColorChip(paint: color)
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
            try viewModel.createProject(projectData, context: viewContext)
            dismiss()
        } catch {
            // Handle error
        }
    }
}

// Color chip view
struct PaintColorChip: View {
    let paint: PaintColor
    
    var body: some View {
        VStack(spacing: 4) {
            Circle()
                .fill(paint.color)
                .frame(width: 40, height: 40)
                .shadow(radius: 2)
            
            Text(paint.name)
                .font(.caption2)
                .lineLimit(1)
        }
    }
}

// Paint selector view
struct PaintSelectorView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedColors: [PaintColor]
    @State private var selectedBrand: PaintBrand = .winsorNewton
    @State private var selectedType: PaintType = .oil
    @State private var showingCustomColorPicker = false
    
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
                        LazyVGrid(columns: [
                            GridItem(.adaptive(minimum: 100))
                        ], spacing: 16) {
                            ForEach(PaintDatabase.shared.getColors(for: selectedBrand, type: selectedType)) { paint in
                                Button {
                                    if !selectedColors.contains(where: { $0.id == paint.id }) {
                                        selectedColors.append(paint)
                                    }
                                } label: {
                                    PaintColorChip(paint: paint)
                                }
                            }
                        }
                        .padding()
                    }
                }
                
                Section {
                    Button {
                        showingCustomColorPicker = true
                    } label: {
                        Label("Add Custom Color", systemImage: "plus.circle")
                    }
                }
            }
            .navigationTitle("Select Colors")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingCustomColorPicker) {
                CustomColorPicker(selectedColors: $selectedColors)
            }
        }
    }
}

