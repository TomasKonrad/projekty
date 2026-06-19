import SwiftUI
import MapKit

struct ContributionRowView: View {
    let location: RecyclingLocation
    @State private var address: String?

    // GeocodingManager je cached singleton — bezpecne volat z View
    private let geocodingService: GeocodingManaging = DIContainer.shared.resolve()

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top, spacing: 12) {

                // miniatura fotky lokace
                Group {
                    if let data = location.imageData, let uiImage = UIImage(data: data) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                    } else {
                        Image(systemName: location.category.mapIcon)
                            .font(.system(size: 24))
                            .foregroundStyle(Color(.systemGray3))
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(Color(.systemGray5))
                    }
                }
                .frame(width: 80, height: 80)
                .clipShape(RoundedRectangle(cornerRadius: 14))

                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(location.category.label)
                            .font(.headline)
                        Spacer()
                        // stitek stavu — barva dle stavu lokace
                        Text(location.status.label)
                            .font(.caption.weight(.medium))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(location.status.color)
                            .foregroundStyle(LocationStatus.textColor)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }

                    if let address {
                        Label(address, systemImage: "mappin")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }

                    Spacer(minLength: 0)

                    if let addedAt = location.addedAt {
                        Text("Přidán \(addedAt.formatted(.relative(presentation: .named).locale(Locale(identifier: "cs_CZ"))))")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .frame(minHeight: 72)
            }
        }
        .padding()
        .background(Color(.systemBackground), in: RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.07), radius: 12, x: 0, y: 2)
        .task(id: location.id) {
            let coord = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
            address = try? await geocodingService.reverseGeocode(coordinate: coord)
        }
    }
}

#Preview {
    VStack(spacing: 12) {
        ContributionRowView(location: .getSample())
        ContributionRowView(location: .getSampleYard())
    }
    .padding()
    .background(Color(.systemGroupedBackground))
}
