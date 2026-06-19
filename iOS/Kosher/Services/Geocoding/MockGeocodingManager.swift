import CoreLocation

final class MockGeocodingManager: GeocodingManaging {
    func reverseGeocode(coordinate: CLLocationCoordinate2D) async throws -> String? {
        "Střední, Brno-Královo Pole"
    }
}
