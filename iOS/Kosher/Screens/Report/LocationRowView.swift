import SwiftUI

struct LocationRowView: View {
    let location: RecyclingLocation
    
    var body: some View {
        HStack(spacing: 12) {
            if let data = location.imageData, let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 60, height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            } else {
                Image(systemName: location.category.mapIcon)
                    .font(.system(size: 28))
                    .foregroundStyle(.secondary)
                    .frame(width: 60, height: 60)
                    .background(Color(.systemGray5))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(location.category.label)
                    .font(.headline)
                // adresa z reverse geocoding
                AddressLabel(location: location)
            }
            Spacer()
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    VStack(spacing: 12) {
        LocationRowView(location: .getSample())
        LocationRowView(location: .getSampleYard())
    }
    .padding()
    .background(Color(.systemGroupedBackground))
}
