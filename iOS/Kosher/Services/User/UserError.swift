import SwiftUI

enum UserError: LocalizedError {
    case notFound
    case invalidData

    var errorDescription: String? {
        switch self {
        case .notFound:     return "Uživatel nebyl nalezen."
        case .invalidData:  return "Data uživatele jsou neplatná."
        }
    }
}
