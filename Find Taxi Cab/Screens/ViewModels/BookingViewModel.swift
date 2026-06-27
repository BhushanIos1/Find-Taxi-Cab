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

//    @Published var bookingDetails: BookingDetailsModel?
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

/*extension BookingViewModel {

    func createBooking(parameters: Parameters) {

        guard !isLoading else { return }

        isLoading = true

        Task {

            defer { isLoading = false }

            do {

                let response: CreateBookingResponse =
                try await APIClient.shared.request(
                    BookingAPI.addBooking(parameters: parameters),
                    responseType: CreateBookingResponse.self
                )

                if response.result == "success" {

                    bookingId = response.bookingId

                    bookingState = .success(
                        response.message ?? "Booking Created"
                    )

                } else {

                    let message = response.message ?? "Booking Failed"

                    bookingState = .failure(message)
                }

            } catch {

                bookingState = .failure(error.localizedDescription)
            }
        }
    }
}

extension BookingViewModel {

    func createBooking(parameters: Parameters) {

        guard !isLoading else { return }

        isLoading = true

        Task {

            defer { isLoading = false }

            do {

                let response: CreateBookingResponse =
                try await APIClient.shared.request(
                    BookingAPI.addBooking(parameters: parameters),
                    responseType: CreateBookingResponse.self
                )

                if response.result == "success" {

                    bookingId = response.bookingId

                    bookingState = .success(
                        response.message ?? "Booking Created"
                    )

                } else {

                    let message = response.message ?? "Booking Failed"

                    bookingState = .failure(message)
                }

            } catch {

                bookingState = .failure(error.localizedDescription)
            }
        }
    }
}

extension BookingViewModel {

    func getBookingData(
        driverId: String,
        bookingId: String
    ) {

        Task {

            do {

                let response: BookingDataResponse =
                try await APIClient.shared.request(
                    BookingAPI.getBookingData(
                        driverId: driverId,
                        bookingId: bookingId
                    ),
                    responseType: BookingDataResponse.self
                )

                bookingDetails = response.bookingData

            } catch {

                print(error)
            }
        }
    }
}

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
