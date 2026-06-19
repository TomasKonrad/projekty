import MapKit

// NSObject podtrida nutna pro MKAnnotation protokol
final class LocationAnnotation: NSObject, MKAnnotation {
    let coordinate: CLLocationCoordinate2D
    let location: RecyclingLocation

    init(location: RecyclingLocation) {
        self.coordinate = location.coordinate
        self.location = location
    }
}
