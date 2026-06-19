import MapKit
import SwiftUI

// UIViewRepresentable obalujici MKMapView — umoznuje nativni shlukování pinu bez extra logiky
struct ClusteredMapView: UIViewRepresentable {
    let initialRegion: MKCoordinateRegion
    let targetCenter: CLLocationCoordinate2D?      // jednrazove centrovani po ziskani GPS — pak nil
    let navigateCenter: CLLocationCoordinate2D?    // navigace na konkretni lokaci ze skeneru
    let navigateVersion: Int                       // incrementuje se pri kazde navigaci aby updateUIView zareagoval
    let locations: [RecyclingLocation]
    let onSelect: (RecyclingLocation) -> Void      // volano pri tapnuti na jednotlivy pin
    let onCameraIdle: (MKCoordinateRegion) -> Void // volano po uklidneni kamery

    func makeCoordinator() -> Coordinator {
        Coordinator(onSelect: onSelect, onCameraIdle: onCameraIdle)
    }

    func makeUIView(context: Context) -> MKMapView {
        let map = MKMapView()
        map.delegate = context.coordinator
        map.showsUserLocation = true // modry puntik aktualni polohy uzivatele
        // registrace trid pro piny, kontejnery (vlastni kruh) a shluky
        map.register(LocationAnnotationView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
        map.register(RecyclingSpotAnnotationView.self, forAnnotationViewWithReuseIdentifier: RecyclingSpotAnnotationView.reuseId)
        map.register(ClusterAnnotationView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultClusterAnnotationViewReuseIdentifier)
        map.setRegion(initialRegion, animated: false)
        return map
    }

    func updateUIView(_ map: MKMapView, context: Context) {
        // jednrazove centrovani na GPS polohu uzivatele — provede se jednou po ziskani fixu
        if let center = targetCenter, !context.coordinator.hasCenteredOnUser {
            let region = MKCoordinateRegion(center: center, latitudinalMeters: 2000, longitudinalMeters: 2000)
            map.setRegion(region, animated: true)
            context.coordinator.hasCenteredOnUser = true
        }

        // navigace na lokaci ze skeneru — spusti se vzdy kdyz se verze zmeni
        if navigateVersion != context.coordinator.lastNavigateVersion, let center = navigateCenter {
            let region = MKCoordinateRegion(center: center, latitudinalMeters: 100, longitudinalMeters: 400)
            map.setRegion(region, animated: true)
            context.coordinator.lastNavigateVersion = navigateVersion
        }

        // diff — pridame nove, odstranim smazane, vymenime zmenene (stejne id, jiny updatedAt)
        let existing = map.annotations.compactMap { $0 as? LocationAnnotation }
        let existingById = Dictionary(uniqueKeysWithValues: existing.map { ($0.location.id, $0) })
        let incomingById = Dictionary(uniqueKeysWithValues: locations.map { ($0.id, $0) })

        let toRemove = existing.filter { ann in
            guard let incoming = incomingById[ann.location.id] else { return true }
            return ann.location.updatedAt != incoming.updatedAt
        }
        let toAdd = locations.filter { loc in
            guard let old = existingById[loc.id] else { return true }
            return old.location.updatedAt != loc.updatedAt
        }.map { LocationAnnotation(location: $0) }

        guard !toRemove.isEmpty || !toAdd.isEmpty else { return }
        if !toRemove.isEmpty { map.removeAnnotations(toRemove) }
        if !toAdd.isEmpty   { map.addAnnotations(toAdd) }
    }

    // MARK: - Coordinator

    final class Coordinator: NSObject, MKMapViewDelegate {
        let onSelect: (RecyclingLocation) -> Void
        let onCameraIdle: (MKCoordinateRegion) -> Void
        // priznak ze uz jsme centrovali na GPS — aby se centrovani neopakovalo pri kazdem updateUIView
        var hasCenteredOnUser = false
        // posledni zpracovana verze navigace ze skeneru — pri shode se navigace neprovede znovu
        var lastNavigateVersion: Int = 0

        init(onSelect: @escaping (RecyclingLocation) -> Void, onCameraIdle: @escaping (MKCoordinateRegion) -> Void) {
            self.onSelect = onSelect
            self.onCameraIdle = onCameraIdle
        }

        // explicitni dequeue — vrati spravnou tridu z register() vyse; vraceni nil by pouzilo systemovy default
        // configure(for:) se vola okamzite po dequeue — annotation je v tuto chvili zarucene nastaveno
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            if let loc = annotation as? LocationAnnotation {
                // cekajici biny pouzivaji vzdy LocationAnnotationView (oranzovy marker) bez ohledu na kategorii
                if loc.location.category == .recyclingSpot && loc.location.status != .pending {
                    let view = mapView.dequeueReusableAnnotationView(
                        withIdentifier: RecyclingSpotAnnotationView.reuseId, for: annotation
                    ) as? RecyclingSpotAnnotationView
                    view?.configure(for: loc.location)
                    return view
                }
                let view = mapView.dequeueReusableAnnotationView(
                    withIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier, for: annotation
                ) as? LocationAnnotationView
                view?.configure(for: loc.location)
                return view
            }
            if annotation is MKClusterAnnotation {
                return mapView.dequeueReusableAnnotationView(
                    withIdentifier: MKMapViewDefaultClusterAnnotationViewReuseIdentifier, for: annotation
                )
            }
            return nil
        }

        // kamera se uklidnila — oznamime viewmodelu aktualni oblast
        func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
            let region = mapView.region
            Task { @MainActor in self.onCameraIdle(region) }
        }

        func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
            mapView.deselectAnnotation(view.annotation, animated: false)
            if let annotation = view.annotation as? LocationAnnotation {
                // tapnuti na pin — otevreni detailu
                Task { @MainActor in self.onSelect(annotation.location) }
            } else if let cluster = view.annotation as? MKClusterAnnotation {
                // tapnuti na shluk — priblizeni tak, aby byly vsechny piny viditelne
                let rect = cluster.memberAnnotations.reduce(MKMapRect.null) {
                    $0.union(MKMapRect(origin: MKMapPoint($1.coordinate), size: MKMapSize()))
                }
                mapView.setVisibleMapRect(rect.insetBy(dx: -5000, dy: -5000), animated: true)
            }
        }
    }
}
