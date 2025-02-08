import SwiftUI
import FirebaseAuth
import CoreData

struct ProfileView: View {
    @EnvironmentObject private var authService: AuthenticationService
    @Environment(\.managedObjectContext) private var viewContext
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding: Bool = false
    @State private var showingSettings = false
    @State private var showingError = false
    @State private var errorMessage = ""
    @State private var showingResetConfirmation = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Profile Header
                    VStack(spacing: 16) {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 80))
                            .foregroundStyle(AppTheme.Colors.primary)
                        
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
                            ("Artworks", "0"),
                            ("Galleries", "0"),
                            ("Projects", "0"),
                            ("Updates", "0")
                        ])
                    }
                    
                    // Quick Actions
                    FormSection(title: "Quick Actions") {
                        VStack(spacing: 0) {
                            NavigationLink {
                                Text("Your Galleries")
                            } label: {
                                ListRow(
                                    title: "Your Galleries",
                                    subtitle: "View and manage your gallery collections",
                                    icon: "photo.stack"
                                )
                            }
                            
                            NavigationLink {
                                Text("Projects")
                            } label: {
                                ListRow(
                                    title: "Active Projects",
                                    subtitle: "Track your works in progress",
                                    icon: "paintpalette"
                                )
                            }
                        }
                    }
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
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingResetConfirmation = true
                    } label: {
                        Image(systemName: "arrow.counterclockwise.circle")
                    }
                }
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView(showingSettings: $showingSettings)
            }
            .alert("Error", isPresented: $showingError) {
                Button("OK") {}
            } message: {
                Text(errorMessage)
            }
            .alert("Reset App", isPresented: $showingResetConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Reset", role: .destructive) {
                    resetApp()
                }
            } message: {
                Text("This will reset the app to its initial state. You'll need to sign in again.")
            }
        }
    }
    
    private func resetApp() {
        // Reset onboarding
        hasSeenOnboarding = false
        
        // Sign out
        try? Auth.auth().signOut()
        
        // Clear Core Data
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = GalleryEntity.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        try? viewContext.execute(deleteRequest)
        
        // Save context
        try? viewContext.save()
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