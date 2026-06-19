import Foundation
import MapKit
import CoreLocation

@Observable
class MapViewModel {
    var state: MapViewState = MapViewState()

    private var locationService: RecyclingLocationManaging
    private var userLocationService: LocationManaging
    private var authManager: AuthManaging
    private var notificationManager: PendingBinNotificationManaging
    // in-memory — resetuje se pri kazdem spusteni, tiles jsou vzdy overeny vuci Firestore
    private var visitedTiles: Set<String> = []
    private var debounceTask: Task<Void, Never>?
    private var refreshTask: Task<Void, Never>?
    private var proximityTask: Task<Void, Never>?
    // ulozena oblast kamery — pouzita kdyz kamera zahori behem seedovani
    private var pendingRegion: MKCoordinateRegion?
    private var isSeeding = false

    // prihlaseny uzivatel muze pridavat lokace
    var isLoggedIn: Bool { authManager.currentUser != nil }
    var currentUser: AppUser? { authManager.currentUser }

    init() {
        locationService      = DIContainer.shared.resolve()
        userLocationService  = DIContainer.shared.resolve()
        authManager          = DIContainer.shared.resolve()
        notificationManager  = DIContainer.shared.resolve()
    }

    // prvni launch: seed CoreData z bundle, dalsi launche: delta sync z Firestore
    func load() async {
        isSeeding = true
        state.loadingState = .loading
        await locationService.deltaSync()
        isSeeding = false
        state.loadingState = .loaded
        startRefreshTimer()
        // pozadej povoleni notifikaci a spust kontrolu blizkych binu
        notificationManager.requestPermission()
        startProximityTimer()

        // po deltaSync zkusime ziskat GPS polohu — cekame max 2 sekundy na fix
        for _ in 0..<10 {
            if let coord = userLocationService.getCurrentLocation() {
                state.targetCenter = coord
                break
            }
            try? await Task.sleep(for: .milliseconds(200))
        }

        // pokud kamera zahorila behem seedovani, zpracujeme ji ted
        if let region = pendingRegion {
            onCameraIdle(region: region)
        }
    }

    // volano po uklidneni kamery — okamzita CoreData query, pak Firestore tiles na pozadi
    func onCameraIdle(region: MKCoordinateRegion) {
        pendingRegion = region
        state.mapCenter = region.center // okamzita aktualizace pro picker souradnic
        state.isZoomedOut = region.span.latitudeDelta > 0.05
        guard !isSeeding else { return } // behem seedovani jen ulozime oblast, nezpracovavame
        guard !state.isZoomedOut else { return } // prilis daleko — piny nezobrazujeme ani nestahujeme

        debounceTask?.cancel()
        debounceTask = Task {
            try? await Task.sleep(for: .milliseconds(350))
            guard !Task.isCancelled else { return }

            // okamzita query z CoreData pro aktualni viewport — pridame jen nove piny
            let local = await locationService.loadLocations(in: region)
            await MainActor.run { self.accumulate(local) }

            // tiles ktere jsme jeste nevideli v teto session
            let newTiles = await MainActor.run {
                TileKey.tiles(covering: region).filter { !self.visitedTiles.contains($0.storageKey) }
            }
            guard !newTiles.isEmpty else { return }

            // stahni z Firestore a upsertuj do CoreData
            await locationService.fetchTiles(Set(newTiles))
            await MainActor.run { self.visitedTiles.formUnion(newTiles.map(\.storageKey)) }

            // znovu query po pristupu novych dat z Firestore — pridame jen nove piny
            let updated = await locationService.loadLocations(in: region)
            await MainActor.run { self.accumulate(updated) }
        }
    }

    // reset navstivenych tiles a znovu nacti viewport — pouziva se pri pull-to-refresh nebo navratu do popredi
    func refresh() {
        visitedTiles = []
        state.locations = [] // smaz vsechny piny ze mapy pred novym nactenim
        if let region = pendingRegion {
            onCameraIdle(region: region)
        }
    }

    // kazdych 10 sekund zkontroluje zda je uzivatel blizko nejakeho cekajiciho binu
    private func startProximityTimer() {
        proximityTask?.cancel()
        proximityTask = Task {
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(10))
                guard !Task.isCancelled else { return }
                await MainActor.run { self.checkProximity() }
            }
        }
    }

    // zkontroluje vzdalenost od vsech cekajicich binu — aktualizuje banner a geofence regiony
    func checkProximity() {
        // hlasovani je dostupne jen pro prihlasene uzivatele
        guard isLoggedIn, let userCoord = userLocationService.getCurrentLocation() else {
            state.nearbyPendingBin = nil
            return
        }
        let userLoc = CLLocation(latitude: userCoord.latitude, longitude: userCoord.longitude)
        // vyloucime biny pridane samotnym uzivatelem — nema smysl hlasovat o vlastnich pridavcich
        let pending = state.locations.filter { $0.status == .pending && $0.addedBy != currentUser?.id }

        // seradit dle vzdalenosti — nejblizsi geofence regiony maji prioritu v limitu 20
        let sorted = pending.sorted {
            CLLocation(latitude: $0.latitude, longitude: $0.longitude).distance(from: userLoc) <
            CLLocation(latitude: $1.latitude, longitude: $1.longitude).distance(from: userLoc)
        }
        notificationManager.updateMonitoredBins(sorted)

        // odblokuj dismissnute biny od kterych se uzivatel vzdálil (>500m) — banner se muze znovu ukazat az se vrati
        state.dismissedProximityBinIds = state.dismissedProximityBinIds.filter { dismissedId in
            guard let bin = pending.first(where: { $0.id == dismissedId }) else { return false }
            return CLLocation(latitude: bin.latitude, longitude: bin.longitude).distance(from: userLoc) <= 500
        }

        // foreground banner — nejblizsi nedismissnuty bin do 300m, ktery neni otevreny v sheetu
        let nearby = sorted
            .filter { !state.dismissedProximityBinIds.contains($0.id) }
            .filter { $0.id != state.selectedLocation?.id }
            .first { CLLocation(latitude: $0.latitude, longitude: $0.longitude).distance(from: userLoc) <= 300 }
        state.nearbyPendingBin = nearby
    }

    // uzivatel zavrhl banner — uz ho nechceme znovu ukazovat pro tento bin
    func dismissProximityBanner() {
        guard let bin = state.nearbyPendingBin else { return }
        state.dismissedProximityBinIds.insert(bin.id)
        state.nearbyPendingBin = nil
    }

    // periodicky refresh aktualniho viewportu — nahrazuje piny cerstvymi daty, odstranluje smazane
    private func startRefreshTimer() {
        refreshTask?.cancel()
        refreshTask = Task {
            while !Task.isCancelled {
                // 3 minuty mezi refreshi — dostatecne casty pro aktualni data, neprehlcuje Firestore
                try? await Task.sleep(for: .seconds(180))
                guard !Task.isCancelled else { return }
                await refreshViewport()
            }
        }
    }

    private func refreshViewport() async {
        let region = await MainActor.run { pendingRegion }
        let blocked = await MainActor.run { state.isZoomedOut || isSeeding }
        guard let region, !blocked else { return }

        let tiles = TileKey.tiles(covering: region)
        // fetchTiles automaticky cisti CoreData od smazanych binu
        await locationService.fetchTiles(tiles)
        let fresh = await locationService.loadLocations(in: region)

        await MainActor.run {
            let minLat = region.center.latitude  - region.span.latitudeDelta  / 2
            let maxLat = region.center.latitude  + region.span.latitudeDelta  / 2
            let minLon = region.center.longitude - region.span.longitudeDelta / 2
            let maxLon = region.center.longitude + region.span.longitudeDelta / 2
            // nahrad piny ve viewportu cerstvymi — piny mimo viewport se nedotykame
            self.state.locations = self.state.locations.filter {
                $0.latitude < minLat || $0.latitude > maxLat ||
                $0.longitude < minLon || $0.longitude > maxLon
            } + fresh
            // oznac tiles jako navstivene aby debounce neprinasel duplicity
            self.visitedTiles.formUnion(tiles.map(\.storageKey))
        }
    }

    // prida jen piny ktere jeste nemame — tim se vyhneme blikani pinu pri zoomovani
    private func accumulate(_ incoming: [RecyclingLocation]) {
        let existingIds = Set(state.locations.map(\.id))
        let newOnes = incoming.filter { !existingIds.contains($0.id) }
        if !newOnes.isEmpty { state.locations += newOnes }
        pruneDistantLocations()
        // po pridani novych binu zkontroluj blizke cekajici
        checkProximity()
    }

    // odstrani lokace daleko mimo viewport a uvolni jejich tile klice — pri navratu se znovu nactou z CoreData
    private func pruneDistantLocations() {
        guard let region = pendingRegion, state.locations.count > 150 else { return }
        let buffer = 3.0
        let minLat = region.center.latitude  - region.span.latitudeDelta  * buffer
        let maxLat = region.center.latitude  + region.span.latitudeDelta  * buffer
        let minLon = region.center.longitude - region.span.longitudeDelta * buffer
        let maxLon = region.center.longitude + region.span.longitudeDelta * buffer

        let outside = state.locations.filter {
            $0.latitude < minLat || $0.latitude > maxLat ||
            $0.longitude < minLon || $0.longitude > maxLon
        }
        guard !outside.isEmpty else { return }

        state.locations = state.locations.filter {
            $0.latitude >= minLat && $0.latitude <= maxLat &&
            $0.longitude >= minLon && $0.longitude <= maxLon
        }
        // uvolnime tile klice — pri navratu uzivatele se piny znovu stahnou z CoreData
        let prunedKeys = Set(outside.map { TileKey(latitude: $0.latitude, longitude: $0.longitude).storageKey })
        visitedTiles.subtract(prunedKeys)
    }

    func select(_ location: RecyclingLocation?) {
        state.selectedLocation = location
        // skryj banner kdyz se otevira detail — nema smysl zobrazovat oba naraz
        if location != nil { state.nearbyPendingBin = nil }
    }

    // presune kameru na aktualni GPS polohu uzivatele
    func panToUserLocation() {
        guard let coord = userLocationService.getCurrentLocation() else { return }
        state.navigateCenter = coord
        state.navigateVersion += 1
    }

    // presune kameru na lokaci a otevre jeji detail — volano pri navigaci ze skeneru
    func navigateTo(_ location: RecyclingLocation) {
        if !state.locations.contains(where: { $0.id == location.id }) {
            state.locations.append(location)
        }
        state.navigateCenter = location.coordinate
        state.navigateVersion += 1
        state.selectedLocation = location
    }

    func deleteLocation(_ location: RecyclingLocation) {
        // okamzite odstraneni z mapy, pak smazeme z Firestore a CoreData
        state.locations.removeAll { $0.id == location.id }
        state.selectedLocation = nil
        Task {
            do {
                try await locationService.deleteLocation(id: location.id)
            } catch {
                // obnovime bin na mape pokud smazani selhalo
                state.locations.append(location)
                state.error = "Nepodařilo se smazat sběrné místo. Zkuste to znovu."
            }
        }
    }

    // aktualizuje pin na mape po uspesne uprave nebo hlasovani
    func replaceLocation(_ updated: RecyclingLocation) {
        if let idx = state.locations.firstIndex(where: { $0.id == updated.id }) {
            state.locations[idx] = updated
        }
        // aktualizuje otevreny sheet pokud zobrazuje tu samou lokaci
        if state.selectedLocation?.id == updated.id {
            state.selectedLocation = updated
        }
        // bin uz neni cekajici — zrus banner pokud ho zobrazujeme
        if updated.status != .pending, state.nearbyPendingBin?.id == updated.id {
            state.nearbyPendingBin = nil
        }
    }

    func toggleCategory(_ category: LocationCategory) {
        if state.selectedCategories.contains(category) {
            state.selectedCategories.remove(category)
        } else {
            state.selectedCategories.insert(category)
        }
    }

    func selectAllCategories() { state.selectedCategories = Set(LocationCategory.allCases) }
    func clearCategories()     { state.selectedCategories = [] }

    func toggleWasteType(_ type: WasteType) {
        if state.selectedWasteTypes.contains(type) {
            state.selectedWasteTypes.remove(type)
        } else {
            state.selectedWasteTypes.insert(type)
        }
    }

    func selectAllWasteTypes() { state.selectedWasteTypes = Set(WasteType.allCases) }
    func clearWasteTypes()     { state.selectedWasteTypes = [] }

    func toggleStatus(_ status: LocationStatus) {
        if state.selectedStatuses.contains(status) {
            state.selectedStatuses.remove(status)
        } else {
            state.selectedStatuses.insert(status)
        }
    }

    // aktivni + cekajici — vychozi stav filtru dostupnosti
    func selectAllStatuses() { state.selectedStatuses = [.active, .pending] }
    func clearStatuses()     { state.selectedStatuses = [] }
}
