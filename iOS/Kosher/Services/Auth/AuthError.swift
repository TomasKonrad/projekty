import SwiftUI

enum AuthError: LocalizedError {
    case missingRootViewController
    case missingToken
    case banned(reason: String)

    var errorDescription: String? {
        switch self {
        case .missingRootViewController:
            return "Nepodařilo se zobrazit přihlašovací dialog."
        case .missingToken:
            return "Nepodařilo se získat přihlašovací token."
        case .banned(let reason):
            return "Váš účet byl zablokován z důvodu: \(reason)"
        }
    }
}
