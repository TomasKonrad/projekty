import MapKit

// Identifies one 0.1° × 0.1° tile in the world grid (~11 km per side)
struct TileKey: Hashable {
    let latIndex: Int  // floor(latitude / 0.1)
    let lonIndex: Int  // floor(longitude / 0.1)

    var storageKey: String { "\(latIndex)_\(lonIndex)" }

    // Lat/lon bounds used in Firestore range queries
    var minLat: Double { Double(latIndex) * 0.1 }
    var maxLat: Double { minLat + 0.1 }
    var minLon: Double { Double(lonIndex) * 0.1 }
    var maxLon: Double { minLon + 0.1 }

    init(latitude: Double, longitude: Double) {
        latIndex = Int(floor(latitude / 0.1))
        lonIndex = Int(floor(longitude / 0.1))
    }

    // Returns all tiles that intersect with the given map region
    static func tiles(covering region: MKCoordinateRegion) -> Set<TileKey> {
        let minLat = region.center.latitude  - region.span.latitudeDelta  / 2
        let maxLat = region.center.latitude  + region.span.latitudeDelta  / 2
        let minLon = region.center.longitude - region.span.longitudeDelta / 2
        let maxLon = region.center.longitude + region.span.longitudeDelta / 2

        var tiles = Set<TileKey>()
        var lat = floor(minLat / 0.1) * 0.1
        while lat <= maxLat {
            var lon = floor(minLon / 0.1) * 0.1
            while lon <= maxLon {
                tiles.insert(TileKey(latitude: lat, longitude: lon))
                lon += 0.1
            }
            lat += 0.1
        }
        return tiles
    }
}
