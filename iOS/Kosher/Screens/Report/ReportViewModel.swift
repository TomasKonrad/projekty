import Foundation

@Observable
final class ReportViewModel {
    var state = ReportUIState()

    private var reportManager: ReportManaging
    private let location: RecyclingLocation
    private let reporterId: String

    init(location: RecyclingLocation, reporterId: String) {
        self.location = location
        self.reporterId = reporterId
        reportManager = DIContainer.shared.resolve()
    }

    // pouze pro preview a testy
    init(location: RecyclingLocation, reporterId: String, reportManager: ReportManaging) {
        self.location = location
        self.reporterId = reporterId
        self.reportManager = reportManager
    }

    func submit() async {
        guard let type = state.selectedType else { return }
        state.isLoading = true

        let report = Report(
            id: UUID().uuidString,
            locationId: location.id,
            type: type,
            reporterId: reporterId,
            status: .pending,
            date: Date()
        )

        do {
            try await reportManager.addReport(report)
            state.isSubmitted = true
        } catch {
            state.error = "Nepodařilo se odeslat report."
        }
        state.isLoading = false
    }
}
