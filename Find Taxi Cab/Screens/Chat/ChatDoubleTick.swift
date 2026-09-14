//
//  DoubleTick.swift
//  Find Taxi Cab Driver
//
//  Created by Bhushan Kumar on 04/07/26.
//

import SwiftUI

struct ChatDoubleTick: View {

    let isRead: Bool

    var body: some View {

        ZStack {

            Image(systemName: "checkmark")
                .offset(x: -3)

            Image(systemName: "checkmark")
                .offset(x: 2)
        }
        .font(.system(size: 10, weight: .semibold))
        .foregroundStyle(
            isRead
            ? AppColors.primaryYellow
            : Color.gray.opacity(0.5)
        )
    }
}
