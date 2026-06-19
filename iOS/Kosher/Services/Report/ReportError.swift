import SwiftUI

enum ReportError: LocalizedError {
    case invalidData

    var errorDescription: String? {
        switch self {
        case .invalidData: return "Data reportu jsou neplatná."
        }
    }
}
