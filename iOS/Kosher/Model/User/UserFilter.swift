enum UserFilter: String, CaseIterable, Identifiable {
    case all
    case active
    case banned

    var id: String { rawValue }

    var label: String {
        switch self {
        case .all:     return "Všichni"
        case .active:  return "Aktivní"
        case .banned:  return "Zablokovaní"
        }
    }
}
