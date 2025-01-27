import SwiftUI

struct ProfileView: View {
    var body: some View {
        NavigationStack {
            ContentUnavailableView(
                "Coming Soon",
                systemImage: "person.crop.circle",
                description: Text("The Profile feature is under development. Here you'll be able to manage your artist profile and view all your artwork.")
            )
            .navigationTitle("Profile")
        }
    }
} 