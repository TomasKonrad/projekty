import SwiftUI

enum LocationCategory: String, CaseIterable, Identifiable {
    case wasteBasket = "waste_basket"
    case recyclingSpot = "recycling_spot"
    case collectionYard = "collection_yard"

    var id: String { rawValue }

    var label: String {
        switch self {
        case .wasteBasket:    "Odpadkový koš"
        case .recyclingSpot:  "Kontejner"
        case .collectionYard: "Sběrný dvůr"
        }
    }

    var mapIcon: String {
        switch self {
        case .wasteBasket:    "trash"
        case .recyclingSpot:  "arrow.3.trianglepath"
        case .collectionYard: "building.2.fill"
        }
    }

    var mapColor: Color {
        switch self {
        case .wasteBasket:    .gray
        case .recyclingSpot:  .green
        case .collectionYard: .blue
        }
    }

    // pro pouziti ve vete "Jsi poblíž nepotvrzeného ..."
    var proximityLabel: String {
        switch self {
        case .wasteBasket:    "odpadkového koše"
        case .recyclingSpot:  "kontejneru"
        case .collectionYard: "sběrného dvoru"
        }
    }

    // nadpis v detailu — jiny nez label v headeru
    var detailTitle: String {
        switch self {
        case .wasteBasket:    "Odpadkový koš"
        case .recyclingSpot:  "Tříděný odpad"
        case .collectionYard: "Sběrný dvůr"
        }
    }
}
