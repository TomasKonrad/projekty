import SwiftUI

struct AddressLabel: View {
    let location: RecyclingLocation
    @State private var address: String? = nil
    private let geocodingManager: GeocodingManaging

    init(location: RecyclingLocation, geocodingManager: GeocodingManaging = GeocodingManager()) {
        self.location = location
        self.geocodingManager = geocodingManager
    }

    var body: some View {
        Label(
            address ?? String(format: "%.4f, %.4f", location.latitude, location.longitude),
            systemImage: "mappin"
        )
        .font(.caption)
        .foregroundStyle(.secondary)
        .task {
            address = try? await geocodingManager.reverseGeocode(coordinate: location.coordinate)
        }
    }
}

#Preview {
    AddressLabel(location: .getSample(), geocodingManager: MockGeocodingManager())
        .padding()
}
