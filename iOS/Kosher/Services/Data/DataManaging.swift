protocol DataManaging {
    func fetchLocations() async -> [RecyclingLocation]
    // Returns only bins within the given bounding box — fast NSPredicate query
    func fetchLocations(minLat: Double, maxLat: Double, minLon: Double, maxLon: Double) async -> [RecyclingLocation]
    // Delete-by-id then insert — preserves records outside this batch
    func upsertLocations(_ locations: [RecyclingLocation]) async
    // Smaze zaznamy podle ID — pouziva se pro cisteni smazanych binu po refreshi tiles
    func deleteLocations(withIds ids: Set<String>) async
}
