import Foundation
import FirebaseFirestore

final class FirebaseReportManager: ReportManaging {
    private let db = Firestore.firestore()
    private let collection = "reports"

    // všechny reporty bez filtru.
    func fetchReports() async throws -> [Report] {
        let snapshot = try await db
            .collection(collection)
            .getDocuments()
        return snapshot.documents.compactMap { doc in
            try? parse(from: doc.data(), id: doc.documentID)
        }
    }

    // reporty pro konkrétní lokaci
    func fetchReports(for locationId: String) async throws -> [Report] {
        let snapshot = try await db
            .collection(collection)
            .whereField("locationId", isEqualTo: locationId)
            .getDocuments()
        return snapshot.documents.compactMap { doc in
            try? parse(from: doc.data(), id: doc.documentID)
        }
    }

    // přidání reportu
    func addReport(_ report: Report) async throws {
        try await db
            .collection(collection)
            .document(report.id)
            .setData(dictionary(from: report))
    }

    // změna stavu reportu
    func updateStatus(reportId: String, status: ReportStatus) async throws {
        try await db
            .collection(collection)
            .document(reportId)
            .updateData(["status": status.rawValue])
    }

    // MARK: - Mapping

    // Datový typ Report na firebase strukturu
    private func dictionary(from report: Report) -> [String: Any] {
        [
            "locationId":  report.locationId,
            "type":        report.type.rawValue,
            "reporterId":  report.reporterId,
            "status":      report.status.rawValue,
            "date":        report.date.timeIntervalSince1970 * 1000
        ]
    }

    // Firebase struktura na datový typ Report
    private func parse(from data: [String: Any], id: String) throws -> Report {
        guard
            let locationId  = data["locationId"]  as? String,
            let typeRaw     = data["type"]         as? String,
            let type        = ReportType(rawValue: typeRaw),
            let reporterId  = data["reporterId"]   as? String,
            let statusRaw   = data["status"]       as? String,
            let status      = ReportStatus(rawValue: statusRaw)
        else { throw ReportError.invalidData }

        let dateMs = (data["date"] as? Double) ?? 0
        let date = Date(timeIntervalSince1970: dateMs / 1000)

        return Report(
            id: id,
            locationId: locationId,
            type: type,
            reporterId: reporterId,
            status: status,
            date: date
        )
    }
}
