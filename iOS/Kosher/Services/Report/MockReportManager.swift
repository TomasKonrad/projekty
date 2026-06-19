final class MockReportManager: ReportManaging {
    private var reports: [Report] = [
        .getSample()
    ]

    func fetchReports() async throws -> [Report] {
        reports
    }

    func fetchReports(for locationId: String) async throws -> [Report] {
        reports.filter { $0.locationId == locationId }
    }

    func addReport(_ report: Report) async throws {
        reports.append(report)
    }

    func updateStatus(reportId: String, status: ReportStatus) async throws {
        guard let index = reports.firstIndex(where: { $0.id == reportId }) else { return }
        reports[index].status = status
    }
}
