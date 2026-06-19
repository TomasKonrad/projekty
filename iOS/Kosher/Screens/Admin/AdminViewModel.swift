import Foundation
import CoreLocation

@Observable
final class AdminViewModel {
    var state = AdminViewState()

    private var reportManager: ReportManaging
    // banovani, seznam vsech uzivatelu atd.
    private var userManager: UserManaging
    // potrebujeme zjistit current user, aby se nemohl zablokovat sam sebe
    private var authManager: AuthManaging
    // nacteni binu konkretniho uzivatele pro UserDetailView
    private var locationManager: RecyclingLocationManaging
    // reverzni geokodovani — ulice pro vyhledavani reportu
    private var geocodingManager: GeocodingManaging

    init() {
        reportManager    = DIContainer.shared.resolve()
        userManager      = DIContainer.shared.resolve()
        authManager      = DIContainer.shared.resolve()
        locationManager  = DIContainer.shared.resolve()
        geocodingManager = DIContainer.shared.resolve()
    }

    // pouze pro preview a testy
    init(reportManager: ReportManaging,
         userManager: UserManaging,
         authManager: AuthManaging,
         locationManager: RecyclingLocationManaging = MockRecyclingLocationManager(),
         geocodingManager: GeocodingManaging = MockGeocodingManager()) {
        self.reportManager    = reportManager
        self.userManager      = userManager
        self.authManager      = authManager
        self.locationManager  = locationManager
        self.geocodingManager = geocodingManager
    }

    // MARK: - Load

    func loadReports() async {
        state.isLoading = true

        do {
            state.reports = try await reportManager.fetchReports()
            // počká se na načtení všech existujících reportů
            await loadLocationsForReports()
        } catch {
            state.error = "Nepodařilo se načíst reporty."
        }

        state.isLoading = false
    }

    func loadUsers() async {
        state.isLoading = true

        do {
            state.users = try await userManager.fetchAllUsers()
        } catch {
            state.error = "Nepodařilo se načíst uživatele."
        }

        state.isLoading = false
    }

    // MARK: - Reports

    // načtení lokace pro reporty
    private func loadLocationsForReports() async {
        let allLocations = await locationManager.loadLocations()
        // použití set -> vyhledává id podle pozice v paměti, neprochází celé pole
        let reportedLocationIds = Set(state.reports.map{$0.locationId})

        var result: [String: RecyclingLocation] = [:]
        for location in allLocations {
            if reportedLocationIds.contains(location.id) {
                result[location.id] = location
            }
        }
        state.locations = result

        // paralelni geokodovani — ulice pro vyhledavani
        await withTaskGroup(of: (String, String?).self) { group in
            for (id, location) in result {
                group.addTask {
                    let address = try? await self.geocodingManager.reverseGeocode(coordinate: location.coordinate)
                    return (id, address)
                }
            }
            for await (id, address) in group {
                if let address { state.addresses[id] = address }
            }
        }
    }
    
    // pokud je selectedReportFilter nil, vrati vsechny reporty, jinak filtruje podle statusu
    var filteredReports: [Report] {
        guard let filter = state.selectedReportFilter else { return state.reports }
        return state.reports.filter { $0.status == filter }
    }

    func updateReportStatus(reportId: String, status: ReportStatus) async {
        do {
            try await reportManager.updateStatus(reportId: reportId, status: status)
            if let index = state.reports.firstIndex(where: { $0.id == reportId }) {
                state.reports[index].status = status
            }
        } catch {
            state.error = "Nepodařilo se aktualizovat report."
        }
    }

    // MARK: - Users
    
    var currentUserId: String? {
            authManager.currentUser?.id
        }

    var filteredUsers: [AppUser] {
        switch state.selectedUserFilter {
        case .all:    return state.users
        case .active: return state.users.filter { !$0.isBanned }
        case .banned: return state.users.filter {  $0.isBanned }
        }
    }

    // nacte biny pridane danym uzivatelem — dotaz primo do Firestore, neni zavisle na lokalni cache
    func loadContributions(for userId: String) async {
        state.selectedUserContributions = []
        state.isLoadingContributions = true
        state.selectedUserContributions = await locationManager.fetchLocations(byUser: userId)
        state.isLoadingContributions = false
    }

    func banUser(id: String, reason: String) async {
        guard id != currentUserId else {
            state.error = "Nemůžeš zablokovat sám sebe."
            return
        }
        
        do {
            try await userManager.banUser(id: id, reason: reason)
            if let index = state.users.firstIndex(where: { $0.id == id }) {
                state.users[index].isBanned = true
                state.users[index].banReason = reason
            }
        } catch {
            state.error = "Nepodařilo se zablokovat uživatele."
        }
    }

    func unbanUser(id: String) async {
        do {
            try await userManager.unbanUser(id: id)
            if let index = state.users.firstIndex(where: { $0.id == id }) {
                state.users[index].isBanned = false
                state.users[index].banReason = nil
            }
        } catch {
            state.error = "Nepodařilo se odblokovat uživatele."
        }
    }
}
