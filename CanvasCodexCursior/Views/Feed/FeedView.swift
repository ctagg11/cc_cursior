import SwiftUI

struct FeedView: View {
    var body: some View {
        NavigationStack {
            ContentUnavailableView(
                "Coming Soon",
                systemImage: "rectangle.stack.person.crop",
                description: Text("The social feed is under development. Here you'll be able to follow other artists and share your work.")
            )
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Feed")
                        .font(.headline)
                        .foregroundColor(.primary)
                }
            }
        }
    }
} 