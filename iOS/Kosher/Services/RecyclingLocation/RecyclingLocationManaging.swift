import MapKit

protocol RecyclingLocationManaging {
    // Returns bins in the viewport from CoreData — no network call
    func loadLocations(in region: MKCoordinateRegion) async -> [RecyclingLocation]
    // Returns all locally stored bins — used for loading user contributions
    func loadLocations() async -> [RecyclingLocation]
    // Stahuje vsechny biny daneho uzivatele primo z Firestore — neni zavisle na lokalni cache
    func fetchLocations(byUser userId: String) async -> [RecyclingLocation]
    // Downloads each tile from Firestore in parallel, upserts into CoreData
    func fetchTiles(_ tiles: Set<TileKey>) async
    // First launch: seeds CoreData from bundle. Subsequent launches: pulls delta changes from Firestore.
    func deltaSync() async
    // Ulozi novou lokaci do Firestore a CoreData s pending statusem
    func createLocation(_ location: RecyclingLocation) async throws
    // Smaze lokaci z Firestore a CoreData
    func deleteLocation(id: String) async throws
    // Aktualizuje kategorii, typy a obrazek lokace ve Firestore a CoreData
    func updateLocation(_ location: RecyclingLocation) async throws
    // Zaznamena hlas uzivatele a vrati aktualizovanou lokaci s novym statusem
    func vote(on locationId: String, userId: String, confirm: Bool, isModerator: Bool) async throws -> RecyclingLocation
}
