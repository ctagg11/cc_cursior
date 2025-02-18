import SwiftUI

struct ZoomableImageView: View {
    let image: Image
    @Environment(\.dismiss) private var dismiss
    @State private var scale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @GestureState private var gestureScale: CGFloat = 1.0
    @State private var lastOffset: CGSize = .zero
    
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
                            lastOffset = .zero
                        }
                    }
                }
            
            let drag = DragGesture()
                .onChanged { value in
                    guard scale > 1 else { return }
                    
                    let maxOffsetX = (geometry.size.width * (scale - 1)) / 2
                    let maxOffsetY = (geometry.size.height * (scale - 1)) / 2
                    
                    let proposedX = lastOffset.width + value.translation.width
                    let proposedY = lastOffset.height + value.translation.height
                    
                    let boundedX = min(maxOffsetX, max(-maxOffsetX, proposedX))
                    let boundedY = min(maxOffsetY, max(-maxOffsetY, proposedY))
                    
                    offset = CGSize(width: boundedX, height: boundedY)
                }
                .onEnded { value in
                    lastOffset = offset
                }
            
            let doubleTap = TapGesture(count: 2)
                .onEnded {
                    withAnimation(.spring()) {
                        if scale == 1 {
                            scale = 2
                            // Center the zoom on the tap location
                            offset = .zero
                            lastOffset = .zero
                        } else {
                            scale = 1
                            offset = .zero
                            lastOffset = .zero
                        }
                    }
                }
            
            image
                .resizable()
                .scaledToFit()
                .scaleEffect(scale * gestureScale)
                .offset(offset)
                .gesture(SimultaneousGesture(magnification, drag))
                .gesture(doubleTap)
                .animation(.spring(response: 0.3, dampingFraction: 0.8), value: offset)
                .animation(.spring(response: 0.3, dampingFraction: 0.8), value: scale)
                .frame(maxWidth: geometry.size.width, maxHeight: geometry.size.height)
                .interactiveDismissDisabled()
        }
        .background(Color.black)
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
        }
    }
}