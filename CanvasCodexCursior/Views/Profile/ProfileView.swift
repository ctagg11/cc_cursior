import SwiftUI
import FirebaseAuth
import CoreData
import PhotosUI

struct ProfileView: View {
    @EnvironmentObject private var authService: AuthenticationService
    @Environment(\.managedObjectContext) private var viewContext
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding: Bool = false
    @State private var showingSettings = false
    @State private var showingError = false
    @State private var errorMessage = ""
    @State private var showingResetConfirmation = false
    @State private var showingImagePicker = false
    @State private var selectedImage: PhotosPickerItem?
    @State private var profileImage: Image?
    @State private var showingAllArtwork = false
    
    // Fetch Requests for stats
    @FetchRequest(
        entity: ArtworkEntity.entity(),
        sortDescriptors: []
    ) private var artworks: FetchedResults<ArtworkEntity>
    
    @FetchRequest(
        entity: GalleryEntity.entity(),
        sortDescriptors: []
    ) private var galleries: FetchedResults<GalleryEntity>
    
    @FetchRequest(
        entity: ProjectEntity.entity(),
        sortDescriptors: []
    ) private var projects: FetchedResults<ProjectEntity>
    
    @FetchRequest(
        entity: ProjectUpdateEntity.entity(),
        sortDescriptors: []
    ) private var updates: FetchedResults<ProjectUpdateEntity>
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Profile Header with Photo
                    VStack(spacing: 16) {
                        PhotosPicker(selection: $selectedImage, matching: .images) {
                            if let profileImage {
                                profileImage
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 100, height: 100)
                                    .clipShape(Circle())
                                    .overlay(Circle().stroke(AppTheme.Colors.primary, lineWidth: 2))
                            } else {
                                Image(systemName: "person.circle.fill")
                                    .font(.system(size: 80))
                                    .foregroundStyle(AppTheme.Colors.primary)
                            }
                        }
                        .onChange(of: selectedImage) { oldValue, newValue in
                            Task {
                                await loadProfileImage()
                            }
                        }
                        
                        VStack(spacing: 4) {
                            Text(authService.user?.email ?? "Artist")
                                .font(.headline)
                            Text("Member since \(authService.user?.metadata.creationDate?.formatted(date: .abbreviated, time: .omitted) ?? "...")")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.vertical, 32)
                    
                    // Stats Section
                    FormSection(title: "Your Activity") {
                        StatsGrid(stats: [
                            ("Artworks", "\(artworks.count)"),
                            ("Galleries", "\(galleries.count)"),
                            ("Projects", "\(projects.count)"),
                            ("Updates", "\(updates.count)")
                        ])
                    }
                    
                    // All Artwork Button
                    Button {
                        showingAllArtwork = true
                    } label: {
                        HStack {
                            Image(systemName: "photo.stack")
                            Text("View All Artwork")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(AppTheme.Colors.primary)
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .padding(.horizontal)
                }
                .padding(.horizontal)
            }
            .background(Color(UIColor.systemGroupedBackground))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Profile")
                        .font(.headline)
                        .foregroundColor(.primary)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingSettings = true
                    } label: {
                        Image(systemName: "gear")
                    }
                }
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView(showingSettings: $showingSettings)
            }
            .navigationDestination(isPresented: $showingAllArtwork) {
                AllArtworkView()
            }
            .alert("Error", isPresented: $showingError) {
                Button("OK") {}
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    private func loadProfileImage() async {
        guard let selectedImage else { return }
        do {
            if let data = try await selectedImage.loadTransferable(type: Data.self),
               let uiImage = UIImage(data: data) {
                self.profileImage = Image(uiImage: uiImage)
                // TODO: Save profile image to storage
            }
        } catch {
            errorMessage = "Failed to load profile image"
            showingError = true
        }
    }
}

struct SettingsView: View {
    @EnvironmentObject private var authService: AuthenticationService
    @Binding var showingSettings: Bool
    @State private var showingResetPassword = false
    @State private var showingDeleteAccount = false
    
    var body: some View {
        NavigationStack {
            List {
                Section("Account") {
                    Button {
                        showingResetPassword = true
                    } label: {
                        Label("Reset Password", systemImage: "lock.rotation")
                    }
                    
                    Button {
                        showingDeleteAccount = true
                    } label: {
                        Label("Delete Account", systemImage: "person.crop.circle.badge.minus")
                            .foregroundStyle(.red)
                    }
                }
                
                Section("App Settings") {
                    NavigationLink {
                        Text("Notifications")
                    } label: {
                        Label("Notifications", systemImage: "bell")
                    }
                    
                    NavigationLink {
                        Text("Privacy")
                    } label: {
                        Label("Privacy", systemImage: "hand.raised")
                    }
                }
                
                Section {
                    Button(role: .destructive) {
                        try? authService.signOut()
                    } label: {
                        Label("Sign Out", systemImage: "rectangle.portrait.and.arrow.right")
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        showingSettings = false
                    }
                }
            }
        }
        .alert("Reset Password", isPresented: $showingResetPassword) {
            Button("Cancel", role: .cancel) {}
            Button("Send Reset Link") {
                if let email = authService.user?.email {
                    Task {
                        do {
                            try await Auth.auth().sendPasswordReset(withEmail: email)
                        } catch {
                            // Handle error
                        }
                    }
                }
            }
        } message: {
            Text("We'll send you an email with a link to reset your password.")
        }
        .alert("Delete Account", isPresented: $showingDeleteAccount) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                Task {
                    do {
                        try await authService.user?.delete()
                    } catch {
                        // Handle error
                    }
                }
            }
        } message: {
            Text("This action cannot be undone. All your data will be permanently deleted.")
        }
    }
}

struct StatsGrid: View {
    let stats: [(String, String)]
    
    var body: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 16) {
            ForEach(stats, id: \.0) { stat in
                VStack(spacing: 4) {
                    Text(stat.1)
                        .font(.title2.bold())
                    Text(stat.0)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(UIColor.secondarySystemGroupedBackground))
                .cornerRadius(12)
            }
        }
    }
}

// New View for displaying all artwork
struct AllArtworkView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        entity: ArtworkEntity.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \ArtworkEntity.createdAt, ascending: false)]
    ) private var artworks: FetchedResults<ArtworkEntity>
    
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(artworks) { artwork in
                    NavigationLink(destination: ArtworkDetailView(artwork: artwork)) {
                        if let fileName = artwork.imageFileName,
                           let uiImage = ImageManager.shared.loadImage(fileName: fileName, category: .artwork) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 100, height: 100)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        } else {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.gray.opacity(0.2))
                                .frame(width: 100, height: 100)
                                .overlay {
                                    Image(systemName: "photo")
                                        .foregroundStyle(.secondary)
                                }
                        }
                    }
                }
            }
            .padding()
        }
        .navigationTitle("All Artwork")
        .navigationBarTitleDisplayMode(.inline)
    }
} 