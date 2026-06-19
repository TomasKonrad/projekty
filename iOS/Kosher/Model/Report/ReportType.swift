enum ReportType: String, CaseIterable, Identifiable {
    case doesntExist = "doesnt_exist"
    case damaged
    case wrongType = "wrong_type"
    case badPhoto = "bad_photo"
    case wrongCategory = "wrong_category"

    var id: String { rawValue }

    var label: String {
        switch self {
        case .doesntExist:    "Místo neexistuje"
        case .damaged:        "Místo je poškozené"
        case .wrongType:      "Špatný typ odpadu"
        case .badPhoto:       "Špatná fotka"
        case .wrongCategory:  "Špatná kategorie"
        }
    }
}
