import SwiftUI

struct TagModeImageView: View {
    let image: UIImage
    let artwork: ArtworkEntity
    @Binding var isTagMode: Bool
    @State private var scale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var showingTagMenu: Bool = false
    @State private var tagLocation: CGPoint = .zero
    @State private var showingTagForm = false
    @State private var selectedType: ComponentType?
    @State private var isLongPressing = false
    
    // Gesture state
    @GestureState private var magnifyBy = CGFloat(1.0)
    @GestureState private var dragOffset = CGSize.zero
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Image with zoom and pan
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .scaleEffect(scale * magnifyBy)
                    .offset(x: offset.width + dragOffset.width, y: offset.height + dragOffset.height)
                    .overlay {
                        if isTagMode {
                            // Grid overlay
                            GridOverlay()
                                .opacity(0.3)
                            
                            // Dimming overlay
                            Color.black.opacity(0.1)
                        }
                    }
                    .gesture(
                        SimultaneousGesture(
                            MagnificationGesture()
                                .updating($magnifyBy) { value, state, _ in
                                    state = value
                                }
                                .onEnded { value in
                                    scale *= value
                                },
                            DragGesture()
                                .updating($dragOffset) { value, state, _ in
                                    state = value.translation
                                }
                                .onEnded { value in
                                    offset.width += value.translation.width
                                    offset.height += value.translation.height
                                }
                        )
                    )
                    .gesture(
                        LongPressGesture(minimumDuration: 0.5)
                            .sequenced(before: DragGesture(minimumDistance: 0))
                            .onEnded { value in
                                switch value {
                                case .second(true, let drag):
                                    if isTagMode {
                                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                        if let location = drag?.location {
                                            tagLocation = location
                                            showingTagMenu = true
                                        }
                                    }
                                default:
                                    break
                                }
                            }
                    )
                
                if showingTagMenu {
                    RadialTagMenu(
                        isPresented: $showingTagMenu,
                        location: tagLocation
                    ) { type in
                        selectedType = type
                        showingTagForm = true
                    }
                }
            }
        }
        .sheet(isPresented: $showingTagForm) {
            if let type = selectedType {
                ComponentTagForm(artwork: artwork, type: type, location: tagLocation)
            }
        }
    }
}

struct GridOverlay: View {
    var body: some View {
        GeometryReader { geometry in
            Path { path in
                // Vertical lines
                for i in 1...5 {
                    let x = geometry.size.width * CGFloat(i) / 6
                    path.move(to: CGPoint(x: x, y: 0))
                    path.addLine(to: CGPoint(x: x, y: geometry.size.height))
                }
                
                // Horizontal lines
                for i in 1...5 {
                    let y = geometry.size.height * CGFloat(i) / 6
                    path.move(to: CGPoint(x: 0, y: y))
                    path.addLine(to: CGPoint(x: geometry.size.width, y: y))
                }
            }
            .stroke(Color.white, lineWidth: 0.5)
        }
    }
} 