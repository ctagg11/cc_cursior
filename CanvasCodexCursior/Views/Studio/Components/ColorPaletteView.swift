import SwiftUI

struct ColorPaletteView: View {
    let colors: [PaletteColor]
    
    var body: some View {
        VStack(spacing: 16) {
            // Color Grid
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(colors) { color in
                    ColorSwatchView(color: color)
                        .onTapGesture {
                            UIPasteboard.general.string = color.hex
                        }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 2)
    }
}

struct ColorSwatchView: View {
    let color: PaletteColor
    
    var body: some View {
        VStack(spacing: 8) {
            // Color Swatch
            RoundedRectangle(cornerRadius: 12)
                .fill(color.color)
                .frame(height: 100)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                )
            
            // Color Information
            VStack(alignment: .leading, spacing: 4) {
                Text(color.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(color.hex)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}
