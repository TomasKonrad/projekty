import UserNotifications
import CoreLocation
import Foundation


final class PendingBinNotificationManager: NSObject, PendingBinNotificationManaging, CLLocationManagerDelegate {
    private let locationManager  = CLLocationManager()
    private let notifications    = UNUserNotificationCenter.current()
    private let maxRegions       = 20
    // polomer v metrech — spusti notifikaci kdyz uzivatel vstoupi do okruhu
    private let proximityRadius: CLLocationDistance = 300

    override init() {
        super.init()
        locationManager.delegate = self
    }

    // pozada o povoleni notifikaci a always-location pro geofetching na pozadi
    func requestPermission() {
        notifications.requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in }
        locationManager.requestAlwaysAuthorization()
    }

    // nahrad sledovane regiony novymi — serazeny dle vzdalenosti, max 20
    func updateMonitoredBins(_ bins: [RecyclingLocation]) {
        for region in locationManager.monitoredRegions {
            locationManager.stopMonitoring(for: region)
        }
        for bin in bins.prefix(maxRegions) {
            let region = CLCircularRegion(
                center: bin.coordinate,
                radius: proximityRadius,
                identifier: bin.id
            )
            region.notifyOnEntry = true
            region.notifyOnExit  = false
            locationManager.startMonitoring(for: region)
        }
    }

    // vstup do regionu — odesleme lokalni notifikaci s ID binu pro navigaci po tapnuti
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        let content        = UNMutableNotificationContent()
        content.title      = "Nedaleko tebe je neschvaleny kontejner"
        content.body       = "Pomoz komunite a hlasuj, zda kontejner skutecne existuje."
        content.userInfo   = ["binId": region.identifier]
        content.sound      = .default
        let request = UNNotificationRequest(
            identifier: "pending-bin-\(region.identifier)",
            content: content,
            trigger: nil
        )
        notifications.add(request, withCompletionHandler: nil)
    }
}

// prazdna implementace pro preview a testy
final class MockPendingBinNotificationManager: PendingBinNotificationManaging {
    func requestPermission() {}
    func updateMonitoredBins(_ bins: [RecyclingLocation]) {}
}
