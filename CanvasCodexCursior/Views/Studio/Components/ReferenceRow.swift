import SwiftUI

struct ProjectReferenceRow: View {
    let reference: ReferenceImage
    
    var body: some View {
        HStack {
            Image(uiImage: reference.image)
                .resizable()
                .scaledToFill()
                .frame(width: 60, height: 60)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            
            VStack(alignment: .leading) {
                Text("Reference Image")
                    .font(.subheadline)
                Text("Added \(Date().formatted(date: .abbreviated, time: .omitted))")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
} 