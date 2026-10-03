//
//  VehicleSeatIcon.swift
//  Find Taxi Cab
//
//  Created by Claude on 03/10/26.
//

/// Maps a vehicle's seat count to the asset added for it (`ic_seater_4`
/// through `ic_seater_7`, `suv`) — the Android reference app does the same
/// thing for its cab-selection list (`CabSelectionAdapter`), switching on
/// `seater` with no icon for anything past 7.
///
/// The vehicle list (`vehicle_list`) and booking history (`get_book_list`)
/// disagree on what they call this field — `seater` vs `vehicle_seater` —
/// but seat count is the one thing both actually give us to pick an icon.
enum VehicleSeatIcon {

    /// SUV is the fallback for anything that isn't exactly 4, 5, 6 or 7
    /// seats — including `nil` (older history rows predating
    /// `vehicle_seater`, or any response that simply omits it).
    static func imageName(forSeater seater: Int?) -> String {

        switch seater {
        case 4: return "ic_seater_4"
        case 5: return "ic_seater_5"
        case 6: return "ic_seater_6"
        case 7: return "ic_seater_7"
        default: return "suv"
        }
    }
}
