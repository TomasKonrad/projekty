import MapKit

@Observable
class MapViewState {
    enum LoadingState {
        case idle, loading, loaded
        case error(String)
    }

    var loadingState: LoadingState = .idle
    var error: String? = nil
    var locations: [RecyclingLocation] = []
    var selectedLocation: RecyclingLocation? = nil
    var selectedCategories: Set<LocationCategory> = Set(LocationCategory.allCases)
    var selectedWasteTypes: Set<WasteType> = Set(WasteType.allCases) // vse vybrano = zadny filtr
    var selectedStatuses: Set<LocationStatus> = [.active, .pending]  // odmitnuté skryvame

    // pocatecni pohled na Brno
    let initialRegion: MKCoordinateRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 49.209, longitude: 16.614),
        latitudinalMeters: 50000,
        longitudinalMeters: 50000
    )

    // prah pro skryti pinu — latitudeDelta > 1.0 odpovida cca 110 km vyskovemu rozsahu viewportu
    var isZoomedOut: Bool = false
    // souradnice pro jednrazove centrovani mapy — nastavi se po ziskani GPS, ClusteredMapView ho spotrebuje
    var targetCenter: CLLocationCoordinate2D? = nil
    // aktualni stred mapy — aktualizuje se pri kazdem pohybu kamery, pouziva se pri pridavani lokace
    var mapCenter: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 49.209, longitude: 16.614)
    // navigace na konkretni lokaci ze skeneru — verze zajisti ze ClusteredMapView vzdy zareaguje
    var navigateCenter: CLLocationCoordinate2D? = nil
    var navigateVersion: Int = 0

    // foreground proximity banner — cekajici bin do 300m od uzivatele
    var nearbyPendingBin: RecyclingLocation? = nil
    // biny ktere uzivatel zavrhl — banner se pro ne uz neukaze
    var dismissedProximityBinIds: Set<String> = []

    // filtrovane lokace — prazdne kdyz je kamera prilis daleko
    var filteredLocations: [RecyclingLocation] {
        guard !isZoomedOut else { return [] }
        return locations.filter { loc in
            guard selectedCategories.contains(loc.category) else { return false }
            guard selectedStatuses.contains(loc.status) else { return false }
            // lokace bez typu (napr. kos) projde vzdy; jinak alespon jeden typ musi byt vybran
            if !loc.types.isEmpty && Set(loc.types).isDisjoint(with: selectedWasteTypes) { return false }
            return true
        }
    }
}
