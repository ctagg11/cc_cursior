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
    @State private var referenceImage: UIImage?
    @State private var showingImagePicker = false
    @State private var showingDimensions = false
    @State private var hasStartDate = false
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
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
                                // Title Field
                                TextField("Enter artwork title", text: $formData.name)
                                    .textFieldStyle(.plain)
                                    .padding(12)
                                    .background(Color(uiColor: .systemBackground))
                                    .cornerRadius(8)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                                    )
                                
                                // Description Field (unchanged)
                                TextEditor(text: $formData.description)
                                    .frame(height: 100)
                                    .padding(12)
                                    .background(Color(uiColor: .systemBackground))
                                    .cornerRadius(8)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                                    )
                                    .overlay(
                                        Group {
                                            if formData.description.isEmpty {
                                                Text("Comment on your artwork - the process, results, or inspiration")
                                                    .foregroundStyle(.secondary)
                                                    .padding(.leading, 16)
                                                    .padding(.top, 20)
                                            }
                                        },
                                        alignment: .topLeading
                                    )
                                
                                // Medium Picker
                                HStack {
                                    Text("Medium")
                                        .foregroundStyle(.secondary)
                                    Spacer()
                                    Picker("", selection: $formData.medium) {
                                        Text("Select Medium").tag("")
                                        ForEach(CommonMediums.allCases, id: \.self) { medium in
                                            Text(medium.rawValue).tag(medium.rawValue)
                                        }
                                    }
                                    .pickerStyle(.menu)
                                    .frame(width: 180)
                                    .offset(x: 20)
                                }
                                .padding(12)
                                .background(Color(uiColor: .systemBackground))
                                .cornerRadius(8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                                )
                                
                                if galleries.isEmpty {
                                    AppButton(
                                        title: "Create First Gallery",
                                        style: .primary,
                                        action: { showingGalleryCreation = true }
                                    )
                                } else {
                                    // Gallery Picker
                                    HStack {
                                        Text("Gallery")
                                            .foregroundStyle(.secondary)
                                        Spacer()
                                        Picker("", selection: $formData.galleryId) {
                                            Text("Select Gallery").tag("")
                                            ForEach(galleries) { gallery in
                                                Text(gallery.name ?? "").tag(gallery.id?.uuidString ?? "")
                                            }
                                        }
                                        .pickerStyle(.menu)
                                        .frame(width: 180)
                                        .offset(x: 20)
                                    }
                                    .padding(12)
                                    .background(Color(uiColor: .systemBackground))
                                    .cornerRadius(8)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                                    )
                                    
                                    AppButton(
                                        title: "Create New Gallery",
                                        style: .secondary,
                                        action: { showingGalleryCreation = true }
                                    )
                                }
                            }
                        }
                        
                        // Reference Photo Section
                        FormSection(
                            title: "Reference Photo",
                            description: nil  // Removed description since it will be in the button
                        ) {
                            VStack {
                                if let referenceImage = referenceImage {
                                    VStack(spacing: 8) {
                                        Image(uiImage: referenceImage)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(maxHeight: 200)
                                            .cornerRadius(8)
                                        
                                        Button(role: .destructive) {
                                            self.referenceImage = nil
                                        } label: {
                                            Label("Remove Photo", systemImage: "trash")
                                        }
                                    }
                                } else {
                                    Button {
                                        showingImagePicker = true
                                    } label: {
                                        VStack(spacing: 12) {
                                            Image(systemName: "photo.on.rectangle.angled")
                                                .font(.system(size: 32))
                                                .foregroundStyle(.secondary)
                                            Text("Add reference image for your artwork")
                                                .font(.body)
                                                .foregroundStyle(.secondary)
                                        }
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 160)
                                        .background(Color(uiColor: .systemBackground))
                                    }
                                    .buttonStyle(.plain)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(style: StrokeStyle(
                                                lineWidth: 1,
                                                dash: [6],
                                                dashPhase: 0
                                            ))
                                            .foregroundStyle(Color.gray.opacity(0.3))
                                    )
                                    .cornerRadius(8)
                                }
                            }
                        }
                        
                        // Artwork Dimensions Section
                        FormSection(
                            title: "Artwork Dimensions",
                            description: nil
                        ) {
                            VStack(spacing: 16) {
                                // Collapsible Header
                                Button {
                                    withAnimation {
                                        showingDimensions.toggle()
                                    }
                                } label: {
                                    HStack {
                                        Text("Dimensions")
                                            .foregroundStyle(.secondary)
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                            .foregroundStyle(.secondary)
                                            .rotationEffect(.degrees(showingDimensions ? 90 : 0))
                                    }
                                }
                            }
                            
                            if showingDimensions {
                                // Dimension Type Toggle
                                Picker("Dimension Type", selection: $formData.dimensionType) {
                                    Text("2D").tag(DimensionType.twoDimensional)
                                    Text("3D").tag(DimensionType.threeDimensional)
                                }
                                .pickerStyle(.segmented)
                                
                                // Updated Dimension Fields
                                if formData.dimensionType == .twoDimensional {
                                    HStack {
                                        DimensionField(
                                            value: $formData.width,
                                            unit: $formData.units,
                                            label: "Width",
                                            placeholder: "0.00"
                                        )
                                        Text("×")
                                            .foregroundStyle(.secondary)
                                        DimensionField(
                                            value: $formData.height,
                                            unit: $formData.units,
                                            label: "Height",
                                            placeholder: "0.00"
                                        )
                                    }
                                } else {
                                    VStack(spacing: 12) {
                                        HStack {
                                            DimensionField(
                                                value: $formData.width,
                                                unit: $formData.units,
                                                label: "Width",
                                                placeholder: "0.00"
                                            )
                                            Text("×")
                                                .foregroundStyle(.secondary)
                                            DimensionField(
                                                value: $formData.height,
                                                unit: $formData.units,
                                                label: "Height",
                                                placeholder: "0.00"
                                            )
                                        }
                                        HStack {
                                            Text("×")
                                                .foregroundStyle(.secondary)
                                            DimensionField(
                                                value: $formData.depth,
                                                unit: $formData.units,
                                                label: "Depth",
                                                placeholder: "0.00"
                                            )
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
                        .padding()
                        .background(Color(uiColor: .systemBackground))
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                        )
                    }
                    
                    // Dates Section
                    FormSection(
                        title: "Completion",
                        description: nil
                    ) {
                        VStack(spacing: 16) {
                            // Completion Date (Primary)
                            DatePicker("Completed on", selection: $formData.completionDate, displayedComponents: .date)
                                .datePickerStyle(.compact)
                            
                            // Optional Start Date
                            VStack(alignment: .leading, spacing: 8) {
                                Toggle(isOn: $hasStartDate) {
                                    Text("Add start date")
                                        .foregroundStyle(.secondary)
                                }
                                
                                if hasStartDate {
                                    DatePicker("Started on", selection: $formData.startDate, displayedComponents: .date)
                                        .datePickerStyle(.compact)
                                }
                            }
                        }
                        .padding()
                        .background(Color.gray.opacity(0.05))
                        .cornerRadius(8)
                    }
                    .padding(.bottom, 16)  // Add extra spacing

                    // Mute Post Section (at the bottom, before the save button)
                    FormSection(
                        title: "Mute Post",  // Changed from "Visibility"
                        description: nil
                    ) {
                        VStack(alignment: .leading, spacing: 8) {
                            Toggle(isOn: $formData.isMuted) {
                                VStack(alignment: .leading, spacing: 4) {

                                    Text("Don't publish to Home or Gallery feeds")
                                        .font(.body)
                                    Text("This artwork will still be visible on your profile")
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                        .padding()
                        .background(Color(uiColor: .systemBackground))
                        .cornerRadius(8)
                    }
                }
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
            }
            
            // Floating Save Button
            VStack(spacing: 0) {
                Button {
                    saveArtwork()
                } label: {
                    Text("Save Artwork")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(!formData.isValid ? Color.gray : Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .disabled(!formData.isValid)
                .padding(.horizontal)
                .padding(.vertical, 2)
            }
            .background(.thinMaterial)
            .safeAreaInset(edge: .bottom) { Color.clear.frame(height: 0) }
            
            .sheet(isPresented: $showingGalleryCreation) {
                CreateGallerySheet { newGallery in
                    formData.galleryId = newGallery.id?.uuidString ?? ""
                    viewModel.loadGalleries()
                }
            }
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(selectedImage: $referenceImage)
            }
            .alert("Error Saving", isPresented: $showingError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
        }
        .preferredColorScheme(.light)
        .ignoresSafeArea(.keyboard) // This helps with keyboard behavior
        .simultaneousGesture(DragGesture().onChanged { _ in
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                         to: nil, from: nil, for: nil)
        })
    }
    
    private func saveArtwork() {
        print("Starting save artwork...")
        print("Form data valid: \(formData.isValid)")
        print("Name: \(formData.name)")
        print("Gallery ID: \(formData.galleryId)")
        print("Dimensions: \(formData.dimensions)")
        
        do {
            // Convert reference image to Data before saving
            if let referenceImage = referenceImage {
                formData.referenceImageData = referenceImage.jpegData(compressionQuality: 0.8)
            }
            
            try viewModel.createArtwork(formData, image: image, referenceImage: referenceImage)
            print("Artwork saved successfully")
            
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

// Update the DimensionField struct for better placeholder behavior
struct DimensionField: View {
    @Binding var value: Double
    @Binding var unit: DimensionUnit
    let label: String
    let placeholder: String
    
    @FocusState private var isFocused: Bool
    @State private var text: String = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            AppText(text: label, style: .caption)
            
            TextField(placeholder, text: $text)
                .focused($isFocused)
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.center)
                .textFieldStyle(.plain)
                .foregroundStyle(text.isEmpty ? .secondary : .primary)
                .onChange(of: isFocused) { wasFocused, isFocused in
                    if isFocused && value == 0 {
                        text = ""
                    }
                }
                .onChange(of: text) { oldValue, newValue in
                    if let number = Double(newValue) {
                        value = number
                    } else if newValue.isEmpty {
                        value = 0
                    }
                }
                .onAppear {
                    text = value == 0 ? "" : String(format: "%.2f", value)
                }
                .padding()
                .frame(maxWidth: 80)
                .background(Color.gray.opacity(0.05))
                .cornerRadius(8)
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