//
//  BookingViewModel.swift
//  Find Taxi Cab
//
//  Created by Bhushan Kumar on 25/06/26.
//

enum BookingState: Equatable {
    case success(String)
    case failure(String)
}

import Foundation
import Alamofire

@MainActor
final class BookingViewModel: ObservableObject {

    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var bookingState: BookingState?

    // MARK: - Data

    @Published var availableVehicles: [VehicleModel] = []

    @Published var bookingId: String?

    /// Populated once the `book_pickcustomer` push fires — see `getBookingDataToClient()`.
    @Published var trackingDriverInfo: TrackingDriverInfo?

    /// Set by `restoreActiveTrip()` when the server reports a trip still running.
    /// Kept separate from `trackingDriverInfo` so a restore is never mistaken for
    /// a live `book_pickcustomer` push.
    @Published var restorableTrip: ClientActiveBooking?

    /// The same `client_last_book` record, but fetched for display on the Booking
    /// Page rather than to auto-resume. Held separately so opening that screen
    /// never triggers the launch-time resume navigation.
    @Published var lastBooking: ClientActiveBooking?
//
//    @Published var bookingStatus: String?
//
//    @Published var lastBooking: BookingDetailsModel?
//
//    @Published var bookingList: [BookingDetailsModel] = []
//
//    @Published var fareDetails: FareDetailsModel?
//
//    @Published var finalFare: MilesCalculationModel?
}

extension BookingViewModel {

    func getVehicleList(
        latFrom: String,
        longFrom: String,
        latTo: String,
        longTo: String,
        date: String,
        time: String,
        passengers: String,
        specialNeed: String
    ) {
        
        guard !isLoading else { return }
        
        isLoading = true
        errorMessage = nil
        
        Task {
            
            defer { isLoading = false }
            
            do {
                
                let response: VehicleListResponse = try await APIClient.shared.request(
                    CustomerAPI.vehicleList(
                        latFrom: latFrom,
                        longFrom: longFrom,
                        latTo: latTo,
                        longTo: longTo,
                        date: date,
                        time: time,
                        passengers: passengers,
                        specialNeed: specialNeed
                    ),
                    responseType: VehicleListResponse.self
                )
                
                if response.result == "success" {
                    
                    availableVehicles = response.data ?? []
                    
                } else {
                    
                    availableVehicles = []
                    let message = response.message ?? "No Cabs Available"
                    errorMessage = message
                    bookingState = .failure(message)
                }
                
            } catch {
                
                errorMessage = error.localizedDescription
                bookingState = .failure(error.localizedDescription)
                
                print("❌ VEHICLE LIST ERROR")
                print(error)
            }
        }
    }
}

extension BookingViewModel {

    func createBooking(
        pickupAddress: String,
        dropAddress: String,
        vehicleType: String,
        passengers: String,
        specialNeed: String,
        latFrom: String,
        longFrom: String,
        latTo: String,
        longTo: String,
        date: String,
        time: String
    ) {

        guard !isLoading else { return }

        isLoading = true
        errorMessage = nil

        Task {

            defer { isLoading = false }

            do {

                let response: CreateBookingResponse =
                try await APIClient.shared.request(
                    CustomerAPI.createBooking(
                        pickupAddress: pickupAddress,
                        dropAddress: dropAddress,
                        vehicleType: vehicleType,
                        passengers: passengers,
                        vehicleSeater: passengers,
                        specialNeed: specialNeed,
                        latFrom: latFrom,
                        longFrom: longFrom,
                        latTo: latTo,
                        longTo: longTo,
                        date: date,
                        time: time
                    ),
                    responseType: CreateBookingResponse.self
                )

                // A "success" without a booking id is not a usable booking —
                // every call that follows is keyed on it, and defaulting to 0
                // would send the rider into a trip that doesn't exist.
                if response.result.lowercased() == "success",
                   let newBookingId = response.bookingId {

                    print("✅ Booking ID:", newBookingId)

                    bookingId = "\(newBookingId)"
                    AuthManager.shared.bookingID = "\(newBookingId)"

                    bookingState = .success(response.message ?? "Booking Created Successfully")

                } else {

                    // On failure the server sends `error`, not `message` — e.g.
                    // "No Driver Present". `CreateBookingResponse` maps both.
                    let message = response.message ?? "Booking Failed"

                    bookingId = nil
                    errorMessage = message
                    bookingState = .failure(message)
                }

            } catch {

                errorMessage = error.localizedDescription
                bookingState = .failure(error.localizedDescription)

                print("❌ CREATE BOOKING ERROR")
                print(error)
            }
        }
    }
}
extension BookingViewModel {

    /// A driver has accepted and is en route — `book_pickcustomer`. `api/get_bookdatatoclient`
    /// with `{book_id}`, matching Android's `MainActivity.getBookingData()` exactly,
    /// which reads `driver_id`/`drivername`/`vehicle_no`/`driver_lat`/`driver_lng`/`contact_no`
    /// off the response before launching `TrackingActivity`.
    /// `POST /client_last_book` with `{cust_id}` — the rider-side counterpart of
    /// Android's `BookingPage`, which loads the last booking and offers a Continue
    /// button. Here it runs automatically so a rider who closed the app mid-trip
    /// lands straight back on live tracking.
    ///
    /// Stays silent (no `isLoading`, no `bookingState`) — it runs on launch beside
    /// other work and must not raise error toasts when there's simply no trip.
    func restoreActiveTrip() {

        Task {

            do {

                let response: ClientActiveBookingResponse = try await APIClient.shared.request(
                    CustomerAPI.lastBooking,
                    responseType: ClientActiveBookingResponse.self
                )

                guard let booking = response.lastBook, booking.isResumable else {
                    print("ℹ️ No resumable trip for this customer (status: \(response.lastBook?.assignStatus ?? "none")).")
                    return
                }

                print("🔄 Resumable trip found — id \(booking.bookingId ?? "nil"), status \(booking.assignStatus ?? "nil")")

                restorableTrip = booking

            } catch {
                print("❌ RESTORE ACTIVE TRIP ERROR:", error)
            }
        }
    }

    /// `POST /client_last_book` with `{cust_id}` — Android's
    /// `BookingPage.getBookingData()`.
    ///
    /// The same endpoint as `restoreActiveTrip()`, but this is the user-facing
    /// version: it shows the spinner and reports failures, because the rider
    /// opened this screen on purpose and an empty page with no explanation would
    /// leave them guessing.
    func loadLastBooking() {

        guard !isLoading else { return }

        isLoading = true
        errorMessage = nil

        Task {

            defer { isLoading = false }

            do {

                let response: ClientActiveBookingResponse = try await APIClient.shared.request(
                    CustomerAPI.lastBooking,
                    responseType: ClientActiveBookingResponse.self
                )

                if response.result?.lowercased() == "success",
                   let booking = response.lastBook {

                    print("📋 LAST BOOKING: id \(booking.bookingId ?? "nil"), status \(booking.assignStatus ?? "nil")")

                    lastBooking = booking

                } else {

                    // Android shows the server's message in a Toasty here.
                    let message = response.message ?? "No booking found"
                    print("ℹ️ LAST BOOKING:", message)

                    lastBooking = nil
                    errorMessage = message
                    bookingState = .failure(message)
                }

            } catch {

                print("❌ LAST BOOKING ERROR:", error)

                lastBooking = nil
                errorMessage = error.localizedDescription
                bookingState = .failure(error.localizedDescription)
            }
        }
    }

    func getBookingDataToClient(bookingId: String) {

        Task {

            do {

                let response: BookingDataToClientResponse = try await APIClient.shared.request(
                    CustomerAPI.getBookingDataToClient(bookingId: bookingId),
                    responseType: BookingDataToClientResponse.self
                )

                if response.result?.lowercased() == "success", let data = response.data {

                    print("🚕 DRIVER DATA: \(data.driverName ?? "nil") / \(data.vehicleNo ?? "nil")")
                    trackingDriverInfo = data

                } else {

                    print("ℹ️ GET BOOKING DATA TO CLIENT:", response.message ?? "no driver data yet")
                }

            } catch {

                print("❌ GET BOOKING DATA TO CLIENT ERROR:", error)
            }
        }
    }
}
    /*
extension BookingViewModel {

    func changeBookingStatus(
        bookingId: String,
        driverId: String,
        status: String,
        cancelMessage: String = ""
    ) {

        Task {

            do {

                let response: CommonResponse =
                try await APIClient.shared.request(
                    BookingAPI.changeBookingStatus(
                        bookingId: bookingId,
                        driverId: driverId,
                        status: status,
                        cancelMessage: cancelMessage
                    ),
                    responseType: CommonResponse.self
                )

                bookingState = .success(
                    response.message ?? "Status Updated"
                )

            } catch {

                bookingState = .failure(error.localizedDescription)
            }
        }
    }
}

extension BookingViewModel {

    func cancelBooking(
        bookingId: String
    ) {

        Task {

            do {

                let response: CommonResponse =
                try await APIClient.shared.request(
                    BookingAPI.cancelBooking(
                        bookingId: bookingId
                    ),
                    responseType: CommonResponse.self
                )

                bookingState = .success(
                    response.message ?? "Booking Cancelled"
                )

            } catch {

                bookingState = .failure(error.localizedDescription)
            }
        }
    }
}

extension BookingViewModel {

    func cancelBooking(
        bookingId: String
    ) {

        Task {

            do {

                let response: CommonResponse =
                try await APIClient.shared.request(
                    BookingAPI.cancelBooking(
                        bookingId: bookingId
                    ),
                    responseType: CommonResponse.self
                )

                bookingState = .success(
                    response.message ?? "Booking Cancelled"
                )

            } catch {

                bookingState = .failure(error.localizedDescription)
            }
        }
    }
}

extension BookingViewModel {

    func getBookingStatus(
        bookingId: String
    ) {

        Task {

            do {

                let response: BookingStatusResponse =
                try await APIClient.shared.request(
                    BookingAPI.getBookingStatus(
                        bookingId: bookingId
                    ),
                    responseType: BookingStatusResponse.self
                )

                bookingStatus =
                response.bookStatus?.assignStatus

            } catch {

                print(error)
            }
        }
    }
}

extension BookingViewModel {

    func getCustomerBookingData(
        bookingId: String
    ) {

        Task {

            do {

                let response: CustomerBookingResponse =
                try await APIClient.shared.request(
                    BookingAPI.getBookingDataForCustomer(
                        bookingId: bookingId
                    ),
                    responseType: CustomerBookingResponse.self
                )

                bookingDetails = response.data

            } catch {

                print(error)
            }
        }
    }
}

extension BookingViewModel {

    func getLastBooking() {

        Task {

            do {

                let response: CustomerLastBookingResponse =
                try await APIClient.shared.request(
                    BookingAPI.lastBooking,
                    responseType: CustomerLastBookingResponse.self
                )

                lastBooking = response.lastBook

            } catch {

                print(error)
            }
        }
    }
}

extension BookingViewModel {

    func getBookingList() {

        Task {

            do {

                let response: CustomerBookingListResponse =
                try await APIClient.shared.request(
                    BookingAPI.bookingList,
                    responseType: CustomerBookingListResponse.self
                )

                bookingList =
                response.bookingData ?? []

            } catch {

                print(error)
            }
        }
    }
}

extension BookingViewModel {

    func calculateFare(
        bookingId: String,
        price: String,
        tollCharge: String,
        customerRate: String,
        feedback: String
    ) {

        Task {

            do {

                let response: MilesCalculationResponse =
                try await APIClient.shared.request(
                    BookingAPI.milesCalculation(
                        bookingId: bookingId,
                        price: price,
                        tollCharge: tollCharge,
                        customerRate: customerRate,
                        feedback: feedback
                    ),
                    responseType: MilesCalculationResponse.self
                )

                finalFare = response.data

            } catch {

                print(error)
            }
        }
    }
}*/
