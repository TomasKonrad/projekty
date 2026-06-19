import MapKit
import SwiftUI

// view pro kontejner — teardrop pin s barevnymi vysecy dle druhu odpadu a ikonou kontejneru
final class RecyclingSpotAnnotationView: MKAnnotationView {
    static let reuseId = "recyclingSpot"
    private static let pinSize = CGSize(width: 36, height: 42)
    // klic = serazene rawValues typu oddele carkou — vzdy stejny pro stejnou kombinaci druhu odpadu
    private static var imageCache: [String: UIImage] = [:]

    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        clusteringIdentifier = "bin"
        displayPriority = .defaultLow
        centerOffset = CGPoint(x: 0, y: -Self.pinSize.height / 2)
    }

    required init?(coder: NSCoder) { fatalError() }

    override func prepareForReuse() {
        super.prepareForReuse()
        image = nil
    }

    // konfigurace po dequeue — annotation je zarucene nastaveno v tento okamzik
    func configure(for location: RecyclingLocation) {
        image = pinImage(types: location.types)
    }

    // zaloha pro pripad ze MapKit zavola prepareForDisplay bez prechodu pres viewFor(annotation:)
    override func prepareForDisplay() {
        super.prepareForDisplay()
        guard let loc = (annotation as? LocationAnnotation)?.location else { return }
        configure(for: loc)
    }

    private func pinImage(types: [WasteType]) -> UIImage {
        let cacheKey = types.map(\.rawValue).sorted().joined(separator: ",")
        if let cached = Self.imageCache[cacheKey] { return cached }
        let image = renderPinImage(types: types.sorted { $0.rawValue < $1.rawValue })
        Self.imageCache[cacheKey] = image
        return image
    }

    private func renderPinImage(types: [WasteType]) -> UIImage {
        let w: CGFloat     = 36
        let h: CGFloat     = 42
        let headR: CGFloat = 13           // polomer barevneho kruhu
        let border: CGFloat = 3           // sirka bileho okraje
        let cx             = w / 2
        let cy: CGFloat    = 17           // stred kruhu
        let outerR         = headR + border

        // vnitrni kruh (barevne vysece) a vnejsi kruh (bily okraj)
        let innerRect = CGRect(x: cx - headR,  y: cy - headR,  width: headR * 2,  height: headR * 2)
        let outerRect = CGRect(x: cx - outerR, y: cy - outerR, width: outerR * 2, height: outerR * 2)

        // bily stem — extremne tenky sipkovity tvar pod kruhem
        let stemTopY:   CGFloat = cy + outerR - 1
        let stemHalfW:  CGFloat = 3
        let stem = UIBezierPath()
        stem.move(to: CGPoint(x: cx, y: h - 1))
        stem.addCurve(to: CGPoint(x: cx - stemHalfW, y: stemTopY),
                      controlPoint1: CGPoint(x: cx - 0.5, y: h - 7),
                      controlPoint2: CGPoint(x: cx - stemHalfW, y: stemTopY + 2))
        stem.addLine(to: CGPoint(x: cx + stemHalfW, y: stemTopY))
        stem.addCurve(to: CGPoint(x: cx, y: h - 1),
                      controlPoint1: CGPoint(x: cx + stemHalfW, y: stemTopY + 2),
                      controlPoint2: CGPoint(x: cx + 0.5, y: h - 7))
        stem.close()

        return UIGraphicsImageRenderer(size: CGSize(width: w, height: h)).image { rCtx in
            let c = rCtx.cgContext

            // 1. Bily podklad: plny 360° kruh + stem — fill (ne stroke) garantuje kompletni okraj.
            //    Barevny kruh (innerRect) sedi uvnitr bileho kruhu (outerRect), bile misto = okraj.
            let bg = UIBezierPath(ovalIn: outerRect)
            bg.append(stem)
            c.saveGState()
            c.setShadow(offset: CGSize(width: 0, height: 3), blur: 6,
                        color: UIColor.black.withAlphaComponent(0.28).cgColor)
            UIColor.white.setFill()
            bg.fill()
            c.restoreGState()

            // 2. Barevne vysece uvnitr vnitrniho kruhu
            c.saveGState()
            UIBezierPath(ovalIn: innerRect).addClip()
            let slices = types.isEmpty ? [WasteType.mixed] : types
            let step   = 2 * CGFloat.pi / CGFloat(slices.count)
            for (i, t) in slices.enumerated() {
                let seg = UIBezierPath()
                seg.move(to: CGPoint(x: cx, y: cy))
                seg.addArc(withCenter: CGPoint(x: cx, y: cy), radius: headR,
                           startAngle: CGFloat(i) * step - .pi / 2,
                           endAngle:   CGFloat(i + 1) * step - .pi / 2,
                           clockwise: true)
                seg.close()
                UIColor(t.color).setFill()
                seg.fill()
            }
            c.restoreGState()

            // 3. Gradient overlay — svetly vlevo-nahore, tmavy vpravo-dole
            let rgb = CGColorSpaceCreateDeviceRGB()
            c.saveGState()
            UIBezierPath(ovalIn: innerRect).addClip()
            let gradColors = [UIColor.white.withAlphaComponent(0.30).cgColor,
                              UIColor.white.withAlphaComponent(0.0).cgColor,
                              UIColor.black.withAlphaComponent(0.0).cgColor,
                              UIColor.black.withAlphaComponent(0.20).cgColor] as CFArray
            if let grad = CGGradient(colorsSpace: rgb, colors: gradColors, locations: [0, 0.4, 0.6, 1.0]) {
                c.drawLinearGradient(grad,
                                     start: CGPoint(x: cx - headR * 0.55, y: cy - headR),
                                     end:   CGPoint(x: cx + headR * 0.45, y: cy + headR),
                                     options: [])
            }
            c.restoreGState()

            // 4. Ikona se sinem aby vystoupila z barevnych vyseci
            c.saveGState()
            c.setShadow(offset: CGSize(width: 0, height: 1), blur: 2.5,
                        color: UIColor.black.withAlphaComponent(0.6).cgColor)
            let cfg = UIImage.SymbolConfiguration(pointSize: 12, weight: .semibold)
            if let icon = UIImage(systemName: "arrow.3.trianglepath", withConfiguration: cfg)?
                            .withTintColor(.white, renderingMode: .alwaysOriginal) {
                let iz = icon.size
                icon.draw(in: CGRect(x: cx - iz.width / 2, y: cy - iz.height / 2,
                                     width: iz.width, height: iz.height))
            }
            c.restoreGState()
        }
    }
}
