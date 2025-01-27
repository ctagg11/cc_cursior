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
            Form {
                // Image Preview Section
                Section {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 300)
                        .frame(maxWidth: .infinity)
                }
                
                // Basic Info Section
                Section("Artwork Details") {
                    TextField("Title", text: $formData.name)
                    
                    Picker("Medium", selection: $formData.medium) {
                        Text("Select Medium").tag("")
                        ForEach(CommonMediums.allCases, id: \.self) { medium in
                            Text(medium.rawValue).tag(medium.rawValue)
                        }
                    }
                    
                    // Gallery Selection
                    VStack(alignment: .leading) {
                        if galleries.isEmpty {
                            Button {
                                showingGalleryCreation = true
                            } label: {
                                Label("Create First Gallery", systemImage: "folder.badge.plus")
                            }
                        } else {
                            Picker("Gallery", selection: $formData.galleryId) {
                                Text("Select Gallery").tag("")
                                ForEach(galleries) { gallery in
                                    Text(gallery.name ?? "").tag(gallery.id?.uuidString ?? "")
                                }
                            }
                            
                            Button {
                                showingGalleryCreation = true
                            } label: {
                                HStack {
                                    Image(systemName: "plus.circle.fill")
                                    Text("Create New Gallery")
                                }
                                .font(.subheadline)
                                .foregroundStyle(.blue)
                            }
                            .padding(.top, 4)
                        }
                    }
                }
                
                // Dimensions Section
                Section {
                    DisclosureGroup(
                        isExpanded: $showingDimensionPicker,
                        content: {
                            VStack(spacing: 16) {
                                // Dimension Type Toggle
                                Picker("Dimension Type", selection: $formData.dimensionType) {
                                    Text("2D").tag(DimensionType.twoDimensional)
                                    Text("3D").tag(DimensionType.threeDimensional)
                                }
                                .pickerStyle(.segmented)
                                .padding(.vertical, 8)
                                
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
                        },
                        label: {
                            HStack {
                                Text("Dimensions")
                                Spacer()
                                if formData.hasDimensions {
                                    Text(formData.dimensionsDisplay)
                                        .foregroundStyle(.secondary)
                                } else {
                                    Text("Optional")
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                    )
                }
                
                // Dates Section
                Section {
                    DisclosureGroup(
                        isExpanded: $showingDatePicker,
                        content: {
                            DatePicker("Start Date", selection: $formData.startDate, displayedComponents: .date)
                            DatePicker("Completion Date", selection: $formData.completionDate, displayedComponents: .date)
                        },
                        label: {
                            HStack {
                                Text("Dates")
                                Spacer()
                                if formData.hasDateRange {
                                    Text(formData.dateRangeDisplay)
                                        .foregroundStyle(.secondary)
                                } else {
                                    Text("Optional")
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                    )
                }
            }
            .navigationTitle("New Artwork")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        print("Cancel pressed")
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        print("Save button pressed")
                        saveArtwork()
                    }
                    .disabled(!formData.isValid)
                }
            }
            .sheet(isPresented: $showingGalleryCreation) {
                CreateGallerySheet()
                    .onDisappear {
                        // If a gallery was just created and no gallery is selected,
                        // select the most recently created gallery
                        if formData.galleryId.isEmpty, let lastGallery = galleries.last {
                            formData.galleryId = lastGallery.id?.uuidString ?? ""
                        }
                    }
            }
        }
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

// Helper Views
struct DimensionField: View {
    @Binding var value: Double
    @Binding var unit: DimensionUnit
    let label: String
    
    var body: some View {
        TextField(label, value: $value, format: .number.precision(.fractionLength(2)))
            .keyboardType(.decimalPad)
            .textFieldStyle(.roundedBorder)
            .multilineTextAlignment(.center)
            .frame(maxWidth: 80)
            // Add validation to prevent NaN
            .onChange(of: value) { newValue in
                if newValue.isNaN {
                    value = 0
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