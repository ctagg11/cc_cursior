import SwiftUI

struct ZoomableImageView: View {
    let image: UIImage
    @Environment(\.dismiss) private var dismiss
    @State private var scale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var dragOffset: CGSize = .zero
    @GestureState private var gestureScale: CGFloat = 1.0
    
    private var imageOpacity: CGFloat {
        let height = abs(dragOffset.height)
        return max(0, min(1, 1 - (height / 1000)))
    }
    
    private var backgroundOpacity: CGFloat {
        let height = abs(dragOffset.height)
        return max(0, min(1, 1 - (height / 500)))
    }
    
    var body: some View {
        GeometryReader { geometry in
            let magnification = MagnificationGesture()
                .updating($gestureScale) { value, gestureScale, _ in
                    gestureScale = value
                }
                .onEnded { value in
                    let newScale = scale * value
                    scale = min(max(newScale, 1), 4)
                    if scale == 1 {
                        withAnimation(.spring()) {
                            offset = .zero
                        }
                    }
                }
            
            let drag = DragGesture()
                .onChanged { value in
                    if scale == 1 {
                        // When not zoomed, track vertical drag for dismiss gesture
                        dragOffset = CGSize(
                            width: 0,
                            height: value.translation.height
                        )
                    } else {
                        // When zoomed, allow panning
                        let newX = offset.width + value.translation.width
                        let newY = offset.height + value.translation.height
                        offset = CGSize(width: newX, height: newY)
                    }
                }
                .onEnded { value in
                    if scale == 1 {
                        // Dismiss if dragged down far enough
                        if abs(dragOffset.height) > 200 {
                            dismiss()
                        } else {
                            withAnimation(.spring()) {
                                dragOffset = .zero
                            }
                        }
                    }
                }
            
            let doubleTap = TapGesture(count: 2)
                .onEnded {
                    withAnimation(.spring()) {
                        if scale == 1 {
                            scale = 2
                        } else {
                            scale = 1
                            offset = .zero
                        }
                    }
                }
            
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .scaleEffect(scale * gestureScale)
                .offset(scale == 1 ? dragOffset : offset)
                .opacity(imageOpacity)
                .gesture(SimultaneousGesture(magnification, drag))
                .gesture(doubleTap)
                .animation(.spring(response: 0.3), value: scale)
                .frame(maxWidth: geometry.size.width, maxHeight: geometry.size.height)
        }
        .background(Color.black.opacity(backgroundOpacity))
        .ignoresSafeArea()
        .overlay(alignment: .topTrailing) {
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.title)
                    .foregroundStyle(.white)
                    .padding()
            }
            .opacity(dragOffset == .zero ? 1 : 0)
        }
    }
} 