import Foundation
import CoreLocation

@Observable
final class LocationDetailViewModel {
    var state = LocationDetailViewState()

    private var locationService: LocationManaging
    private var geocodingService: GeocodingManaging
    private var openingHoursService: OpeningHoursManaging
    private var recyclingService: RecyclingLocationManaging
    private var userService: UserManaging

    init() {
        locationService      = DIContainer.shared.resolve()
        geocodingService     = DIContainer.shared.resolve()
        openingHoursService  = DIContainer.shared.resolve()
        recyclingService     = DIContainer.shared.resolve()
        userService          = DIContainer.shared.resolve()
    }

    // pouze pro preview a testy — vsechny zavislosti predate explicitne, DI neni k dispozici
    init(locationService: LocationManaging,
         geocodingService: GeocodingManaging,
         openingHoursService: OpeningHoursManaging = OpeningHoursParser(),
         recyclingService: RecyclingLocationManaging = MockRecyclingLocationManager(),
         userService: UserManaging = MockUserManager()) {
        self.locationService     = locationService
        self.geocodingService    = geocodingService
        self.openingHoursService = openingHoursService
        self.recyclingService    = recyclingService
        self.userService         = userService
    }

    // zaznamena hlas a vrati aktualizovanou lokaci — nil pri chybe
    func vote(confirm: Bool, on location: RecyclingLocation, as user: AppUser) async -> RecyclingLocation? {
        state.isVoting = true
        defer { state.isVoting = false }
        do {
            let updated = try await recyclingService.vote(
                on: location.id,
                userId: user.id,
                confirm: confirm,
                isModerator: user.role == .moderator
            )
            state.hasVoted = true
            try? await userService.incrementVotesGiven(userId: user.id)
            return updated
        } catch {
            state.voteError = "Hlasování se nepodařilo. Zkuste to znovu."
            return nil
        }
    }

    func load(for location: RecyclingLocation) {
        // spustime geokodovani a vypocet vzdalenosti paralelne — Task dedi main actor kontext
        Task { await resolveDistance(to: location) }
        Task { await resolveAddress(for: location) }
        if let raw = location.openingHours {
            state.schedule   = openingHoursService.parse(raw)
            state.isOpenNow  = openingHoursService.isOpenNow(raw)
        }
    }

    // MARK: - Private

    private func resolveDistance(to location: RecyclingLocation) async {
        guard let userCoord = locationService.getCurrentLocation() else { return }
        let userLoc = CLLocation(latitude: userCoord.latitude, longitude: userCoord.longitude)
        let binLoc  = CLLocation(latitude: location.latitude,  longitude: location.longitude)
        state.distance = formatDistance(binLoc.distance(from: userLoc))
    }

    // reverzni geokodovani — souradnice na nazev ulice a ctvrti
    private func resolveAddress(for location: RecyclingLocation) async {
        let coordinate = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
        state.address = try? await geocodingService.reverseGeocode(coordinate: coordinate)
    }

    private func formatDistance(_ meters: Double) -> String {
        meters < 1000
            ? "\(Int(meters.rounded()))m"
            : String(format: "%.1fkm", meters / 1000)
    }
}
