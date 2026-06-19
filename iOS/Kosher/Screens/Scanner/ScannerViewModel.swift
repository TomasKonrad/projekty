import UIKit
import CoreLocation

@Observable
class ScannerViewModel {
    var state: ScannerViewState = ScannerViewState()

    private let scannerService:      ScannerManaging
    private let locationService:     RecyclingLocationManaging
    private let userLocationService: LocationManaging
    private let coordinator:         AppCoordinator

    init() {
        scannerService      = DIContainer.shared.resolve()
        locationService     = DIContainer.shared.resolve()
        userLocationService = DIContainer.shared.resolve()
        coordinator         = DIContainer.shared.resolve()
    }

    // spusti analyzu — nastavi stav a zavola AI sluzbu
    func analyze(image: UIImage) async {
        state.selectedImage = image
        state.loadingState = .analyzing
        do {
            let items = try await scannerService.analyze(image: image)
            // prvni pismeno nazvu velke — AI vraci nazvy s malym zacatkem
            state.results = items.map {
                var i = $0
                i.objectName = i.objectName.prefix(1).uppercased() + i.objectName.dropFirst()
                return i
            }
            state.loadingState = .done
            // hledame nejblizsi biny paralelne — UI se zobrazi ihned, biny se doplni kdyz jsou nalezeny
            Task { await resolveNearestLocations() }
        } catch {
            state.loadingState = .failed("Analýza selhala. Zkuste to znovu.")
        }
    }

    // nastavi pending lokaci — ContentView zavře skener a zobrazi ji na mape
    func showOnMap(location: RecyclingLocation) {
        coordinator.pendingMapLocation = location
    }

    // vrati skener do vychoziho stavu — pripraven na dalsi fotografii
    func reset() {
        state.selectedImage = nil
        state.results = []
        state.loadingState = .idle
    }

    // MARK: - Private

    private func resolveNearestLocations() async {
        guard let userCoord = userLocationService.getCurrentLocation() else { return }
        let all = await locationService.loadLocations()
        let userLoc = CLLocation(latitude: userCoord.latitude, longitude: userCoord.longitude)

        for i in state.results.indices {
            let wasteType    = state.results[i].category
            let spotCategory = state.results[i].spotCategory
            // sberny dvory prijimaji vsechny typy odpadu — nehledame podle kategorie
            // pro ostatni typy filtrujeme presne podle kategorie a typu odpadu
            let matching = all.filter {
                $0.status == .active && $0.category == spotCategory &&
                (spotCategory == .collectionYard || $0.types.isEmpty || $0.types.contains(wasteType))
            }
            state.results[i].nearestLocation = matching.min(by: {
                CLLocation(latitude: $0.latitude, longitude: $0.longitude).distance(from: userLoc) <
                CLLocation(latitude: $1.latitude, longitude: $1.longitude).distance(from: userLoc)
            })
        }
    }
}
