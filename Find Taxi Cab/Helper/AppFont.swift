//
//  AppFont.swift
//  Find Taxi Cab
//
//  Created by Bhushan Kumar on 26/02/26.
//

import SwiftUI

enum AppFont {

    enum Weight {
        case light
        case regular
        case medium
        case semiBold
        case bold

        var name: String {
            switch self {
            case .light: return "Roboto-Light"
            case .regular: return "Roboto-Regular"
            case .medium: return "Roboto-Medium"
            case .semiBold: return "Roboto-SemiBold"
            case .bold: return "Roboto-Bold"
            }
        }
    }

    static func font(
        _ weight: Weight,
        size: CGFloat
    ) -> Font {
        Font.custom(weight.name, size: size)
    }
}
