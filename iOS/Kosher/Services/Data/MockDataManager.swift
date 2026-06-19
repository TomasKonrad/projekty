final class MockDataManager: DataManaging {
    private var stored: [RecyclingLocation] = []

    func fetchLocations() async -> [RecyclingLocation] { stored }

    func fetchLocations(minLat: Double, maxLat: Double, minLon: Double, maxLon: Double) async -> [RecyclingLocation] {
        stored.filter {
            $0.latitude  >= minLat && $0.latitude  <= maxLat &&
            $0.longitude >= minLon && $0.longitude <= maxLon
        }
    }

    func upsertLocations(_ locations: [RecyclingLocation]) async {
        var map = Dictionary(uniqueKeysWithValues: stored.map { ($0.id, $0) })
        for loc in locations { map[loc.id] = loc }
        stored = Array(map.values)
    }

    func deleteLocations(withIds ids: Set<String>) async {
        stored.removeAll { ids.contains($0.id) }
    }
}
