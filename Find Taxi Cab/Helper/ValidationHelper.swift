//
//  ValidationHelper.swift
//  Find Taxi Cab
//
//  Created by Bhushan Kumar on 28/02/26.
//

import Foundation

struct ValidationHelper {

    static func isValidEmail(_ email: String) -> Bool {

        let emailRegex =
        #"^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,64}$"#

        return NSPredicate(
            format: "SELF MATCHES %@",
            emailRegex
        ).evaluate(with: email)
    }
}
