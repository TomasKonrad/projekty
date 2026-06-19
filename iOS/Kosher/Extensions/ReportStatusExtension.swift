import SwiftUI

extension ReportStatus {
    var label: String {
        switch self {
        case .pending:   return "K řešení"
        case .resolved:  return "Vyřešeno"
        case .dismissed: return "Řeší se"
        }
    }

    var color: Color {
        switch self {
        case .pending:   return .statusRejected
        case .resolved:  return .statusActive
        case .dismissed: return .statusPending  
        }
    }
}
