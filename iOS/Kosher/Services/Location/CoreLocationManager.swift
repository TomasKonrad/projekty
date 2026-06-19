import CoreLocation

class CoreLocationManager: NSObject, LocationManaging, CLLocationManagerDelegate {
   
    private var locationManager: CLLocationManager!
    private var currentLocation: CLLocationCoordinate2D? = nil
    
    override init() {
        super.init()
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let currentLocation = locations.first {
            self.currentLocation = currentLocation.coordinate
        }
    }
    
    func getCurrentLocation() -> CLLocationCoordinate2D? {
        return currentLocation
    }
}
