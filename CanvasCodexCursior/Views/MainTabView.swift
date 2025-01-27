import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 3 // Start with Upload tab selected
    
    var body: some View {
        TabView(selection: $selectedTab) {
            GalleryView()
                .tabItem {
                    Label("Gallery", systemImage: "photo.stack")
                }
                .tag(1)
            
            StudioView()
                .tabItem {
                    Label("Studio", systemImage: "paintpalette")
                }
                .tag(2)
            
            UploadView(selectedTab: $selectedTab)
                .tabItem {
                    Label("Upload", systemImage: "plus.circle.fill")
                }
                .tag(3)
            
            FeedView()
                .tabItem {
                    Label("Feed", systemImage: "rectangle.stack.person.crop")
                }
                .tag(4)
            
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.crop.circle")
                }
                .tag(5)
        }
        .tint(.indigo) // Use a artistic, creative accent color
    }
} 