import MapKit
import CoreLocation

final class GeocodingManager: GeocodingManaging {

    func reverseGeocode(coordinate: CLLocationCoordinate2D) async throws -> String? {
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        guard let request = MKReverseGeocodingRequest(location: location) else { return nil }

        let item = try await request.mapItems.first

        // placemark poskytuje strukturovana data o adrese
        let placemark = item?.placemark

        // thoroughfare = nazev ulice, locality = nazev mesta
        let streetName = placemark?.thoroughfare
        let city       = placemark?.locality

        let parts = [streetName, city].compactMap { $0 }
        return parts.isEmpty ? nil : parts.joined(separator: ", ")
    }
}
