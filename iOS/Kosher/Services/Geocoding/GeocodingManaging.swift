import CoreLocation

protocol GeocodingManaging {
    // prevede souradnice na retezec ve formatu "Ulice, Ctvrt"
    func reverseGeocode(coordinate: CLLocationCoordinate2D) async throws -> String?
}
