//
//  MapMarkerIcon.swift
//  Find Taxi Cab
//
//  Created by Claude on 13/09/26.
//

import UIKit

/// Map pins drawn at runtime rather than loaded from the asset catalogue.
///
/// `GMSMarker` renders an icon at the image's own point size, so `taxi1.png`
/// (216×132 at 1×) covered a quarter of the screen — and being a JPEG-style
/// export with no alpha channel, it carried a white box around the car that no
/// amount of resizing would remove. Drawing the symbol gives a transparent,
/// correctly sized pin that stays crisp at any scale and reads on both the light
/// and dark map styles.
enum MapMarkerIcon {

    /// Rendered once each — markers are created on first fix and then only moved,
    /// but the map can be rebuilt on a theme change, so caching keeps that free.
    static let driver = circular(
        systemName: "car.fill",
        background: UIColor(AppColors.primaryYellow),
        foreground: .white
    )

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
