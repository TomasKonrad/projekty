protocol ReportManaging {
    func fetchReports() async throws -> [Report]
    func fetchReports(for locationId: String) async throws -> [Report]
    func addReport(_ report: Report) async throws
    func updateStatus(reportId: String, status: ReportStatus) async throws
}
