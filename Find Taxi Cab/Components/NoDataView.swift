//
//  NoDataView.swift
//  Find Taxi Cab
//
//  Created by Claude on 13/09/26.
//

import SwiftUI

/// The one empty state for every list and detail screen.
///
/// Kept in one place so "nothing to show" reads the same everywhere, and so a
/// screen never has to decide between a blank page and its own wording.
///
/// `message` carries the server's own reason when there is one — a refused call
/// and a genuinely empty list both land here, and only the server can say which.
struct NoDataView: View {

    var icon: String = "tray"
    var title: String = "No Data Found"
    var message: String?

    var body: some View {

        VStack(spacing: 12) {

            Image(systemName: icon)
                .font(.system(size: 42))
                .foregroundStyle(AppColors.primaryYellow)

            Text(title)
                .font(AppFont.font(.medium, size: 18))

            if let message, !message.isEmpty {

                Text(message)
                    .font(AppFont.font(.regular, size: 15))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.horizontal, 40)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    NoDataView(
        icon: "clock.arrow.circlepath",
        message: "You haven't taken any trips yet."
    )
}
