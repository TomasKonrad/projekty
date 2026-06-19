import Foundation

struct Report: Identifiable {
    var id: String
    var locationId: String
    var type: ReportType
    var reporterId: String
    var status: ReportStatus
    var date: Date

    static func getSample() -> Report {
        Report(
            id: "report_1",
            locationId: "sample_1",
            type: .doesntExist,
            reporterId: "user_1",
            status: .pending,
            date: Date()
        )
    }
}
