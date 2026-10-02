//
//  MapMarkerIcon.swift
//  Find Taxi Cab
//
//  Created by Claude on 13/09/26.
//

import UIKit

/// Map pins drawn at runtime rather than loaded from the asset catalogue —
/// except `driver`, which is the `taxi1` asset itself (a top-down car, nose
/// pointing up), resized below so it reads as a marker rather than covering a
/// chunk of the map.
enum MapMarkerIcon {

    /// `GMSMarker` renders an icon at the image's own *point* size. `taxi1`
    /// only has a "1x" slot filled in its asset catalogue entry, so UIKit loads
    /// it as a 1x image — its 48×72 pixel size becomes 48×72 *points*, roughly
    /// the width of this screen's whole driver card. Redrawing it into a
    /// smaller canvas (preserving the transparency it already has) fixes that
    /// without touching the source asset.
    ///
    /// Rendered once — markers are created on first fix and then only moved,
    /// but the map can be rebuilt on a theme change, so caching keeps that free.
    static let driver: UIImage = {

        guard let source = UIImage(named: "taxi1") else {
            return circular(
                systemName: "car.fill",
                background: UIColor(AppColors.primaryYellow),
                foreground: .white
            )
        }

        let targetHeight: CGFloat = 46
        let scale = targetHeight / source.size.height
        let targetSize = CGSize(width: source.size.width * scale, height: targetHeight)

        let format = UIGraphicsImageRendererFormat.default()
        format.opaque = false

        return UIGraphicsImageRenderer(size: targetSize, format: format).image { _ in
            source.draw(in: CGRect(origin: .zero, size: targetSize))
        }
    }()

    static let pickup = circular(
        systemName: "mappin",
        background: UIColor(AppColors.greenAppColor),
        foreground: .white
    )

    static let userLocation = circular(
        systemName: "location.fill",
        background: UIColor(AppColors.appBlueColor),
        foreground: .white,
        diameter: 32
    )

    static let destination = circular(
        systemName: "flag.fill",
        background: UIColor(AppColors.secondaryColor),
        foreground: .white
    )

    /// A filled circle with a white ring, a soft drop shadow and an SF Symbol
    /// centred inside it.
    static func circular(
        systemName: String,
        background: UIColor,
        foreground: UIColor = .white,
        diameter: CGFloat = 40
    ) -> UIImage {

        // Padding on every side so the shadow isn't clipped by the image bounds.
        let shadowInset: CGFloat = 3
        let canvas = CGSize(
            width: diameter + shadowInset * 2,
            height: diameter + shadowInset * 2
        )

        let format = UIGraphicsImageRendererFormat.default()
        format.opaque = false

        return UIGraphicsImageRenderer(size: canvas, format: format).image { context in

            let cgContext = context.cgContext
            let circleRect = CGRect(
                x: shadowInset,
                y: shadowInset,
                width: diameter,
                height: diameter
            )

            cgContext.setShadow(
                offset: CGSize(width: 0, height: 1),
                blur: 3,
                color: UIColor.black.withAlphaComponent(0.35).cgColor
            )

            background.setFill()
            UIBezierPath(ovalIn: circleRect).fill()

            cgContext.setShadow(offset: .zero, blur: 0, color: nil)

            // White ring, so a yellow pin still reads against pale roads.
            UIColor.white.setStroke()
            let ring = UIBezierPath(ovalIn: circleRect.insetBy(dx: 1, dy: 1))
            ring.lineWidth = 2
            ring.stroke()

            let symbolConfig = UIImage.SymbolConfiguration(
                pointSize: diameter * 0.45,
                weight: .semibold
            )

            guard let symbol = UIImage(systemName: systemName, withConfiguration: symbolConfig)?
                .withTintColor(foreground, renderingMode: .alwaysOriginal) else {
                return
            }

            symbol.draw(
                in: CGRect(
                    x: circleRect.midX - symbol.size.width / 2,
                    y: circleRect.midY - symbol.size.height / 2,
                    width: symbol.size.width,
                    height: symbol.size.height
                )
            )
        }
    }
}
