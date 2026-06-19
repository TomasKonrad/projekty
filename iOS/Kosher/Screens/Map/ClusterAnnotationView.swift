import MapKit

// view pro shluk pinu — rendruje zeleny kruh jako UIImage (bez subviews — spolehlivejsi s reuse systemem)
final class ClusterAnnotationView: MKAnnotationView {
    // cache kruzku dle poctu — pocty shluku jsou omezene, takze cache zije po celou dobu behu
    private static var imageCache: [Int: UIImage] = [:]

    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        displayPriority = .defaultHigh
    }

    required init?(coder: NSCoder) { fatalError() }

    // prepareForDisplay je spolehlivejsi nez didSet — vola se vzdy tesne pred zobrazenim
    override func prepareForDisplay() {
        super.prepareForDisplay()
        guard let cluster = annotation as? MKClusterAnnotation else { return }
        image = circleImage(count: cluster.memberAnnotations.count) // prerendrujeme obrazek s aktualnim poctem
    }

    // vykresli zeleny kruh s poctem pinu jako UIImage — frame se nastavuje automaticky dle image.size
    private func circleImage(count: Int) -> UIImage {
        if let cached = Self.imageCache[count] { return cached }
        let size = CGSize(width: 40, height: 40)
        let image = UIGraphicsImageRenderer(size: size).image { _ in
            UIColor.systemGreen.setFill()
            UIBezierPath(ovalIn: CGRect(origin: .zero, size: size)).fill()
            let text = "\(count)" as NSString
            let attrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 14),
                .foregroundColor: UIColor.white
            ]
            let ts = text.size(withAttributes: attrs)
            let rect = CGRect(x: (size.width - ts.width) / 2, y: (size.height - ts.height) / 2,
                              width: ts.width, height: ts.height)
            text.draw(in: rect, withAttributes: attrs)
        }
        Self.imageCache[count] = image
        return image
    }
}
