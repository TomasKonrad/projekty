import SwiftUI

enum WasteType: String, CaseIterable, Identifiable {
    case mixed
    case plastic
    case glass
    case paper
    case bio
    case cartons
    case metals
    case clothes
    case eWaste = "e-waste"
    case furniture
    case wood
    case tyres
    case paint
    case hazardous
    case rubble
    case oil
    case drugs

    var id: String { rawValue }

    var label: String {
        switch self {
        case .mixed:      "Směsný odpad"
        case .plastic:    "Plast"
        case .glass:      "Sklo"
        case .paper:      "Papír"
        case .bio:        "Bio"
        case .cartons:    "Nápojové kartony"
        case .metals:     "Kovy"
        case .clothes:    "Textil"
        case .eWaste:     "Elektro"
        case .furniture:  "Nábytek"
        case .wood:       "Dřevo"
        case .tyres:      "Pneumatiky"
        case .paint:      "Barvy"
        case .hazardous:  "Nebezpečný odpad"
        case .rubble:     "Stavební odpad"
        case .oil:        "Oleje"
        case .drugs:      "Léky"
        }
    }

    // ikona systemu pouzita v skeneru pro vizualni odliseni kategorii
    var systemImage: String {
        switch self {
        case .mixed:     "trash"
        case .plastic:   "arrow.3.trianglepath"
        case .glass:     "wineglass"
        case .paper:     "doc.plaintext"
        case .bio:       "leaf"
        case .cartons:   "cup.and.saucer"
        case .metals:    "hammer"
        case .clothes:   "tshirt"
        case .eWaste:    "cpu"
        case .furniture: "sofa"
        case .wood:      "tree"
        case .tyres:     "car.circle"
        case .paint:     "paintpalette"
        case .hazardous: "exclamationmark.triangle"
        case .rubble:    "building.2"
        case .oil:       "drop"
        case .drugs:     "pills"
        }
    }

    // barvy odpovidaji standardnimu ceskemu barevnemu kodovani kontejneru
    var color: Color {
        switch self {
        case .mixed:     .black
        case .plastic:   .yellow
        case .glass:     .green
        case .paper:     .blue
        case .bio:       Color(red: 0.45, green: 0.25, blue: 0.05)
        case .cartons:   .orange
        case .metals:    Color(white: 0.55)
        case .clothes:   .purple
        case .eWaste:    .red
        case .furniture: Color(red: 0.55, green: 0.35, blue: 0.1)
        case .wood:      Color(red: 0.55, green: 0.35, blue: 0.1)
        case .tyres:     Color(white: 0.15)
        case .paint:     .cyan
        case .hazardous: Color(red: 1.0, green: 0.4, blue: 0.0)
        case .rubble:    Color(white: 0.45)
        case .oil:       Color(red: 0.35, green: 0.15, blue: 0.0)
        case .drugs:     .mint
        }
    }
}
