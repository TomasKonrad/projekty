import MapKit
import SwiftUI

// view pro jednotlivy pin — nastavuje clustering identifier, barvu a ikonu dle kategorie
final class LocationAnnotationView: MKMarkerAnnotationView {
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        clusteringIdentifier = "bin" // vsechny piny sdileji stejny klic — MKMapView je shlukuje automaticky
        displayPriority = .defaultLow // pin se schova pod shluk, nikoli pod jiny pin
        canShowCallout = false
    }

    required init?(coder: NSCoder) { fatalError() }

    override func prepareForReuse() {
        super.prepareForReuse()
        // super() muze resetovat clusteringIdentifier — znovu nastavime aby shlukování fungovalo
        clusteringIdentifier = "bin"
    }

    // konfigurace po dequeue — cekajici biny maji oranzovou barvu a hodiny, aktivni barvu kategorie
    func configure(for location: RecyclingLocation) {
        if location.status == .pending {
            markerTintColor = UIColor.systemOrange
            glyphImage      = UIImage(systemName: "clock.fill")
        } else {
            markerTintColor = UIColor(location.category.mapColor)
            glyphImage      = UIImage(systemName: location.category.mapIcon)
        }
    }

    // zaloha pro pripad ze MapKit zavola prepareForDisplay bez prechodu pres viewFor(annotation:)
    override func prepareForDisplay() {
        super.prepareForDisplay()
        guard let loc = (annotation as? LocationAnnotation)?.location else { return }
        configure(for: loc)
    }
}
