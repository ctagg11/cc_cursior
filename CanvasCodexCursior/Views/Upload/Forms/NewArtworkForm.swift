import SwiftUI

struct NewArtworkForm: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = ArtworkViewModel()
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \GalleryEntity.name, ascending: true)],
        animation: .default
    ) private var galleries: FetchedResults<GalleryEntity>
    
    let image: UIImage
    let onComplete: () -> Void  // This is important for navigation
    @State private var formData = ArtworkFormData()
    @State private var showingGalleryCreation = false
    @State private var showingDimensionPicker = false
    @State private var showingMediumPicker = false
    @State private var showingDatePicker = false
    @State private var selectedGallery = ""
    @State private var showingError = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Image Preview Section
                    FormSection(title: "Preview") {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 300)
                            .frame(maxWidth: .infinity)
                    }
                    
                    // Basic Info Section
                    FormSection(
                        title: "Artwork Details",
                        description: "Add basic information about your artwork"
                    ) {
                        VStack(spacing: 16) {
                            AppTextField(
                                label: "Title",
                                placeholder: "Enter artwork title",
                                text: $formData.name,
                                icon: "paintbrush"
                            )
                            
                            // Medium Picker
                            VStack(alignment: .leading, spacing: 8) {
                                AppText(text: "Medium", style: .caption)
                                
                                Picker("Medium", selection: $formData.medium) {
                                    Text("Select Medium").tag("")
                                    ForEach(CommonMediums.allCases, id: \.self) { medium in
                                        Text(medium.rawValue).tag(medium.rawValue)
                                    }
                                }
                                .pickerStyle(.menu)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.gray.opacity(0.05))
                                .cornerRadius(8)
                            }
                            
                            // Gallery Selection
                            VStack(alignment: .leading, spacing: 8) {
                                AppText(text: "Gallery", style: .caption)
                                
                                if galleries.isEmpty {
                                    AppButton(
                                        title: "Create First Gallery",
                                        style: .primary,
                                        action: { showingGalleryCreation = true }
                                    )
                                } else {
                                    VStack(spacing: 12) {
                                        Picker("Gallery", selection: $formData.galleryId) {
                                            Text("Select Gallery").tag("")
                                            ForEach(galleries) { gallery in
                                                Text(gallery.name ?? "").tag(gallery.id?.uuidString ?? "")
                                            }
                                        }
                                        .pickerStyle(.menu)
                                        .padding()
                                        .frame(maxWidth: .infinity)
                                        .background(Color.gray.opacity(0.05))
                                        .cornerRadius(8)
                                        
                                        AppButton(
                                            title: "Create New Gallery",
                                            style: .secondary,
                                            action: { showingGalleryCreation = true }
                                        )
                                    }
                                }
                            }
                        }
                    }
                    
                    // Dimensions Section
                    FormSection(
                        title: "Dimensions",
                        description: "Specify the size of your artwork"
                    ) {
                        VStack(spacing: 16) {
                            // Dimension Type Toggle
                            Picker("Dimension Type", selection: $formData.dimensionType) {
                                Text("2D").tag(DimensionType.twoDimensional)
                                Text("3D").tag(DimensionType.threeDimensional)
                            }
                            .pickerStyle(.segmented)
                            
                            // Dimension Fields
                            if formData.dimensionType == .twoDimensional {
                                HStack {
                                    DimensionField(value: $formData.width, unit: $formData.units, label: "Width")
                                    Text("×")
                                        .foregroundStyle(.secondary)
                                    DimensionField(value: $formData.height, unit: $formData.units, label: "Height")
                                }
                            } else {
                                VStack(spacing: 12) {
                                    HStack {
                                        DimensionField(value: $formData.width, unit: $formData.units, label: "Width")
                                        Text("×")
                                            .foregroundStyle(.secondary)
                                        DimensionField(value: $formData.height, unit: $formData.units, label: "Height")
                                    }
                                    HStack {
                                        Text("×")
                                            .foregroundStyle(.secondary)
                                        DimensionField(value: $formData.depth, unit: $formData.units, label: "Depth")
                                    }
                                }
                            }
                            
                            // Units Picker
                            Picker("Units", selection: $formData.units) {
                                ForEach(DimensionUnit.allCases, id: \.self) { unit in
                                    Text(unit.rawValue).tag(unit)
                                }
                            }
                            .pickerStyle(.segmented)
                        }
                    }
                    
                    // Dates Section
                    FormSection(
                        title: "Dates",
                        description: "When did you start and complete this artwork?"
                    ) {
                        VStack(spacing: 16) {
                            DatePicker("Start Date", selection: $formData.startDate, displayedComponents: .date)
                            DatePicker("Completion Date", selection: $formData.completionDate, displayedComponents: .date)
                        }
                    }
                }
                .padding(.vertical, 24)
            }
            .background(Color(UIColor.systemGroupedBackground))
            .navigationTitle("New Artwork")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundStyle(.secondary)
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveArtwork()
                    }
                    .font(.body.bold())
                    .foregroundStyle(.blue)
                    .disabled(!formData.isValid)
                }
            }
            .sheet(isPresented: $showingGalleryCreation) {
                CreateGallerySheet { newGallery in
                    formData.galleryId = newGallery.id?.uuidString ?? ""
                    viewModel.loadGalleries()
                }
            }
        }
        .preferredColorScheme(.light)
    }
    
    private func saveArtwork() {
        print("Starting save artwork...")
        do {
            try viewModel.createArtwork(formData, image: image)
            print("Artwork saved successfully")
            
            // Ensure we're on the main thread and add a completion handler
            DispatchQueue.main.async {
                print("Dismissing form...")
                dismiss()
                print("Calling onComplete...")
                onComplete()
            }
        } catch {
            print("Error saving artwork: \(error)")
            errorMessage = error.localizedDescription
            showingError = true
        }
    }
}

// Update DimensionField to match our style
struct DimensionField: View {
    @Binding var value: Double
    @Binding var unit: DimensionUnit
    let label: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            AppText(text: label, style: .caption)
            
            TextField(label, value: $value, format: .number.precision(.fractionLength(2)))
                .keyboardType(.decimalPad)
                .textFieldStyle(.plain)
                .multilineTextAlignment(.center)
                .padding()
                .frame(maxWidth: 80)
                .background(Color.gray.opacity(0.05))
                .cornerRadius(8)
                .onChange(of: value) { newValue in
                    if newValue.isNaN {
                        value = 0
                    }
                }
        }
    }
}

// Helper Enums
enum CommonMediums: String, CaseIterable {
    case oilPaint = "Oil Paint"
    case acrylic = "Acrylic"
    case watercolor = "Watercolor"
    case charcoal = "Charcoal"
    case pencil = "Pencil"
    case digitalArt = "Digital Art"
    case mixedMedia = "Mixed Media"
    // Add more as needed
} 