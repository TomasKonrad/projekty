import SwiftUI

extension LocationStatus {
    var label: String {
        switch self {
        case .active:   return "Přijat"
        case .pending:  return "Čeká"
        case .rejected: return "Zamítnut"
        }
    }

    var color: Color {
        switch self {
        case .active:   return .statusActive
        case .pending:  return .statusPending
        case .rejected: return .statusRejected
        }
    }

    var icon: String {
        switch self {
        case .active:   return "checkmark.circle.fill"
        case .pending:  return "clock.fill"
        case .rejected: return "xmark.circle.fill"
        }
    }

    static let textColor: Color = .statusText
}
