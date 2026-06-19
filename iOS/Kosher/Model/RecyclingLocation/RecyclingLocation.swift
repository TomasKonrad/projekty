import CoreLocation

struct RecyclingLocation: Identifiable {
    var id: String
    var category: LocationCategory
    var types: [WasteType]
    var status: LocationStatus
    var votes: [String: Bool]
    var imageData: Data?
    var addedAt: Date?
    var latitude: Double
    var longitude: Double
    var updatedAt: Date
    var addedBy: String?

    // Collection yard only
    var isPublic: Bool?
    var hasFee: Bool?
    var operatorName: String?
    var phone: String?
    var openingHours: String?

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    static func getSample() -> RecyclingLocation {
        RecyclingLocation(
            id: "sample_1",
            category: .recyclingSpot,
            types: [.plastic, .glass, .paper],
            status: .active,
            votes: [:],
            imageData: nil,
            addedAt: nil,
            latitude: 49.1951,
            longitude: 16.6068,
            updatedAt: Date(),
            addedBy: nil
        )
    }

    static func getSampleYard() -> RecyclingLocation {
        RecyclingLocation(
            id: "sample_yard_1",
            category: .collectionYard,
            types: [.plastic, .glass, .paper, .metals, .eWaste, .furniture],
            status: .pending,
            votes: [:],
            imageData: nil,
            addedAt: nil,
            latitude: 49.2005,
            longitude: 16.5936,
            updatedAt: Date(),
            addedBy: nil,
            isPublic: true,
            hasFee: false,
            operatorName: "Sako Brno",
            phone: "+420 123 456 789",
            openingHours: "Mo-Fr 08:00-16:00; Sa 09:00-15:00; Su off"
        )
    }
}
