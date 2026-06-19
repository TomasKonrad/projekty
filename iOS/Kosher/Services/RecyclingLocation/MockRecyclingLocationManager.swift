import MapKit

final class MockRecyclingLocationManager: RecyclingLocationManaging {
    func loadLocations() async -> [RecyclingLocation] {
        [.getSample(), .getSampleYard()]
    }

    func fetchLocations(byUser userId: String) async -> [RecyclingLocation] {
        [.getSample(), .getSampleYard()]
    }

    func loadLocations(in region: MKCoordinateRegion) async -> [RecyclingLocation] {
        [.getSample(), .getSampleYard()]
    }

    func fetchTiles(_ tiles: Set<TileKey>) async {}

    func deltaSync() async {}

    func createLocation(_ location: RecyclingLocation) async throws {}

    func deleteLocation(id: String) async throws {}

    func updateLocation(_ location: RecyclingLocation) async throws {}

    func vote(on locationId: String, userId: String, confirm: Bool, isModerator: Bool) async throws -> RecyclingLocation {
        var location = RecyclingLocation.getSample()
        location.status = confirm ? .active : .rejected
        return location
    }
}
