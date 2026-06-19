import Foundation

struct ScannedItem: Identifiable {
    var id = UUID()
    var objectName: String
    var category: WasteType
    // typ sberne lokace — urcuje kde hledat nejblizsi misto (kos, kontejner, sberny dvur)
    var spotCategory: LocationCategory
    var isRecyclable: Bool
    var instruction: String
    var confidence: Double
    var nearestLocation: RecyclingLocation?

    static func getSample() -> ScannedItem {
        ScannedItem(
            objectName: "Obal od sušenek",
            category: .plastic,
            spotCategory: .recyclingSpot,
            isRecyclable: true,
            instruction: "Vhoďte do žlutého kontejneru na plast.",
            confidence: 0.92,
            nearestLocation: RecyclingLocation.getSample()
        )
    }
}
