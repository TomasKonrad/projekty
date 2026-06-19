import SwiftUI

@Observable
class AdminViewState {
    var reports: [Report] = []
    var users: [AppUser] = []
    var locations: [String: RecyclingLocation] = [:] // locationId jako klic
    var addresses: [String: String] = [:] // locationId -> ulice pro vyhledavani
    var isLoading = false
    var error: String?
    var selectedReportFilter: ReportStatus? = nil
    var selectedUserFilter: UserFilter = .all
    // prispevky vybraneho uzivatele — nacitane pri otevreni UserDetailView
    var selectedUserContributions: [RecyclingLocation] = []
    var isLoadingContributions = false
}
