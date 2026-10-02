//
//  Endpoint.swift
//  Find Taxi Cab
//
//  Created by Bhushan Kumar on 21/03/26.
//

import Alamofire

protocol Endpoint {
    var path: String { get }
    var parameters: Parameters? { get }

    /// A protocol requirement, not just an extension default — otherwise a
    /// per-case override is never reached. `APIClient` holds endpoints as
    /// `Endpoint`, and a member that only exists in the extension is dispatched
    /// statically to that extension, quietly ignoring the enum's own version.
    var baseURL: String { get }
}

extension Endpoint {
    
    /// Everything the backend serves lives under here.
    static var serverRoot: String {
        "http://view.findtaxicab.com/admin"
    }
    
    /// Most endpoints sit in `admin/api/`. The chat endpoints do not — they are
    /// served straight from `admin/`, and requesting them under `api/` returns a
    /// 404 HTML page rather than JSON.
    var baseURL: String {
        Self.serverRoot + "/api"
    }
    
    var method: HTTPMethod {
        return .post
    }
    
    var encoding: ParameterEncoding {
        return URLEncoding.httpBody
    }
}

enum CustomerAPI: Endpoint {
    
    /// Chat is the one group served from `admin/` rather than `admin/api/`.
    var baseURL: String {
        
        switch self {
            
        case .sendChatMessage, .chatMessages, .markChatRead:
            return Self.serverRoot
            
        default:
            return Self.serverRoot + "/api"
        }
    }
    
    /// Mirrors Android's `UploadProfileActivity.onSubmit()` field-for-field. The
    /// card trio is what `get_card_details` later reads back, so dropping any of
    /// it leaves the customer with no usable card on file.
    case register(
        name: String,
        email: String,
        phone: String,
        password: String,
        address: String,
        postalCode: String,
        cardHolderName: String,
        cardNumber: String,
        cardMonth: String,
        cardYear: String,
        profilePhoto: String?
    )
    
    case login(
        email: String,
        password: String,
        token: String
    )
    
    case logout
    
    case forgotPassword(email: String)
    
    case changePassword(password: String)
    
    case updateProfile(
        profilePhoto: String?
    )
    
    case updateCustomerProfile(
        name: String,
        address: String
    )
    
    case deleteCustomer
    
    case updateFCMToken(token: String)
    
    case updateLocation(
        lat: String,
        lng: String
    )
    
    case getCustomerStatus

    case getNearDrivers(
        lat: String,
        lng: String
    )

    /// Powers the live-tracking poll — Android's `TrackingActivity` calls this every
    /// 5000 ms via `Handler.postDelayed` while a trip is in progress, repositioning
    /// the driver marker each tick. No iOS screen calls this yet; the endpoint is
    /// wired up ahead of that screen existing.
    case getDriverLatLng(driverId: String)
    
    /// Mirrors Android's `AddCardActivity.updateCard()` — Settings ▸ Edit Credit
    /// Card. Same six fields, same form encoding.
    case editCardDetails(
        cardNumber: String,
        cardHolderName: String,
        cardMonth: String,
        cardYear: String,
        cvv: String
    )
    
    case getCardDetails

    /// `/do_payment` — settles a completed booking. Mirrors Android's
    /// `InvoiceFragment.doPayment()`: the rider's rating, comment and tip ride
    /// along with the card details in this single call, so paying is what submits
    /// the feedback too. No amount is sent — the server computes what to charge
    /// from `booking_id`.
    case doPayment(
        bookingId: String,
        card: String,
        month: String,
        year: String,
        cvc: String,
        code: String,
        feedback: String,
        rating: String,
        driverTip: String,
        amount: String
    )

    // MARK: - Chat
    //
    // These sit under `/chat/...` rather than alongside the `api/<name>` calls.
    // `baseURL` already ends in `/admin/api`, so the collection's
    // `{{base_url}}/chat/send_message` resolves correctly as long as `base_url`
    // is that same root.

    case sendChatMessage(bookingId: String, message: String)
    case chatMessages(bookingId: String, afterId: String)
    case markChatRead(bookingId: String)

    /// `/check_coupon` — validates a promo code. Android only surfaces the
    /// returned message; it does not alter the displayed total.
    case checkCoupon(code: String)
    
    case customerFeedback(
        bookingId: String,
        feedback: String,
        rate: String
    )
    
    case lastBooking
    
    case bookingList
    
    case vehicleList(
        latFrom: String,
        longFrom: String,
        latTo: String,
        longTo: String,
        date: String,
        time: String,
        passengers: String,
        specialNeed: String
    )
    
    case createBooking(
        pickupAddress: String,
        dropAddress: String,
        vehicleType: String,
        passengers: String,
        vehicleSeater: String,
        specialNeed: String,
        latFrom: String,
        longFrom: String,
        latTo: String,
        longTo: String,
        date: String,
        time: String
    )
    
    case cancelBooking(bookingId: String, reason: String)
    
    case getBookingStatus(bookingId: String)
    
    case getBookingDataToClient(bookingId: String)
    
    case calculateFare(
        bookingId: String,
        price: String,
        tollCharge: String,
        customerRate: String,
        feedback: String
    )
    
    case getFareDetails(bookingId: String)
    
    case aboutUs
    case promotions
    case help
}

extension CustomerAPI {
    
    var path: String {
        
        switch self {
            
        case .register:
            return "/register_user"
            
        case .login:
            return "/user_login"
            
        case .logout:
            return "/user_logout"
            
        case .forgotPassword:
            return "/reset_pass_customer"
            
        case .changePassword:
            return "/customer_change_pass"
            
        case .updateProfile:
            return "/update_user_profile"
            
        case .updateCustomerProfile:
            return "/update_customer_profile"
            
        case .deleteCustomer:
            return "/delete_customer"
            
        case .updateFCMToken:
            return "/update_clienttoken"
            
        case .updateLocation:
            return "/client_location"
            
        case .getCustomerStatus:
            return "/get_customer_status"
            
        case .getNearDrivers:
            return "/get_neardriver"

        case .getDriverLatLng:
            return "/get_driverlatlng"
            
        case .editCardDetails:
            return "/edit_card_detaile"
            
        case .getCardDetails:
            return "/get_card_details"

        case .doPayment:
            return "/do_payment"

        case .sendChatMessage:
            return "/chat/send_message"

        case .chatMessages:
            return "/chat/get_messages"

        case .markChatRead:
            return "/chat/mark_read"

        case .checkCoupon:
            return "/check_coupon"
            
        case .customerFeedback:
            // Matches Android's TrackingActivity.submitFeedback() → leaveFeedback(),
            // which posts to api/driver_feedback, not api/customer_feedback.
            return "/driver_feedback"
            
        case .lastBooking:
            return "/client_last_book"
            
        case .bookingList:
            return "/get_book_list"
            
        case .vehicleList:
            return "/vehicle_list"
            
        case .createBooking:
            return "/add_booking"
            
        case .cancelBooking:
            return "/cancel_book_client"
            
        case .getBookingStatus:
            return "/get_book_status"
            
        case .getBookingDataToClient:
            return "/get_bookdatatoclient"
            
        case .calculateFare:
            return "/miles_cal"
            
        case .getFareDetails:
            return "/get_fair"
            
        case .aboutUs:
            return "/aboutus_user"

        case .promotions:
            return "/promotion_user"

        case .help:
            return "/help_user"
        }
    }
}

extension CustomerAPI {
    
    var parameters: Parameters? {
        
        let custId = AuthManager.shared.customerId
        
        switch self {
            
        case .register(
            let name,
            let email,
            let phone,
            let password,
            let address,
            let postalCode,
            let cardHolderName,
            let cardNumber,
            let cardMonth,
            let cardYear,
            let profilePhoto
        ):
            return [
                "profile_photo": profilePhoto ?? "",
                "cust_name": name,
                "email": email,
                "phoneno": phone,
                "address": address,
                "password": password,
                "postalcode": postalCode,
                "card_holder_name": cardHolderName,
                "card_number": cardNumber,
                "card_month": cardMonth,
                "card_year": cardYear,
                // Not in the Android map, but the backend has been receiving it
                // from this client since launch — left in place so push routing
                // keeps working the way it does today.
                "device_type": "ios"
            ]
            
        case .login(
            let email,
            let password,
            let token
        ):
            return [
                "email": email,
                "password": password,
                "token": token,
                "device_type": "ios"
            ]
            
        case .logout:
            return [
                "custid": custId
            ]
            
        case .forgotPassword(let email):
            return [
                "email": email
            ]
            
        case .changePassword(let password):
            return [
                "custid": custId,
                "password": password
            ]
            
        case .updateProfile(let profilePhoto):
            return [
                "custid": custId,
                "profile_photo": profilePhoto ?? ""
            ]
            
        case .updateCustomerProfile(
            let name,
            let address
        ):
            return [
                "custid": custId,
                "cust_name": name,
                "address": address
            ]
            
        case .deleteCustomer:
            return [
                "custid": custId
            ]
            
        case .updateFCMToken(let token):
            return [
                "client_id": custId,
                "token": token
            ]
            
        case .updateLocation(
            let lat,
            let lng
        ):
            return [
                "client_id": custId,
                "latitude": lat,
                "longitude": lng
            ]
            
        case .getCustomerStatus:
            return [
                "cust_id": custId
            ]
            
        case .getNearDrivers(
            let lat,
            let lng
        ):
            return [
                "lat": lat,
                "long": lng
            ]

        case .getDriverLatLng(let driverId):
            // Matches Android's TrackingActivity.getCurrentDriverLocation():
            // param.put("driver_id", driver_id)
            return [
                "driver_id": driverId
            ]
            
        case .editCardDetails(
            let cardNumber,
            let cardHolderName,
            let cardMonth,
            let cardYear,
            let cvv
        ):
            return [
                "custid": custId,
                "card_number": cardNumber,
                "card_holder_name": cardHolderName,
                "card_month": cardMonth,
                "card_year": cardYear,
                "cvv": cvv
            ]
            
        case .getCardDetails:
            return [
                "custid": custId
            ]

        case .doPayment(
            let bookingId,
            let card,
            let month,
            let year,
            let cvc,
            let code,
            let feedback,
            let rating,
            let driverTip,
            let amount
        ):
            // The first ten are key-for-key with Android's doPayment(): note
            // `custid` (not cust_id) and `cvc` (not cvv).
            //
            // `amount` is the exception — Android sends no amount at all and lets
            // the server derive the charge from `booking_id`, which is how a trip
            // with `base_fair = 0` reached Stripe as a £0 charge and was refused.
            // This is the total the customer was actually shown, booking fee
            // included.
            return [
                "custid": custId,
                "booking_id": bookingId,
                "card": card,
                "month": month,
                "year": year,
                "cvc": cvc,
                "code": code,
                "feedback": feedback,
                "rating": rating,
                "driver_tip": driverTip,
                "amount": amount
            ]

        case .sendChatMessage(let bookingId, let message):
            return [
                "booking_id": bookingId,
                "sender_type": "customer",
                "sender_id": custId,
                "message": message
            ]

        case .chatMessages(let bookingId, let afterId):
            return [
                "booking_id": bookingId,
                "after_id": afterId
            ]

        case .markChatRead(let bookingId):
            // `reader_type` is who is *doing* the reading — this marks the
            // driver's messages as seen.
            return [
                "booking_id": bookingId,
                "reader_type": "customer"
            ]

        case .checkCoupon(let code):
            return [
                "code": code
            ]

        case .customerFeedback(
            let bookingId,
            let feedback,
            let rate
        ):
            return [
                "booking_id": bookingId,
                "feedback": feedback,
                "rate": rate
            ]
            
        case .lastBooking:
            return [
                "cust_id": custId
            ]
            
        case .bookingList:
            return [
                "client_id": custId
            ]
            
        case .vehicleList(
            let latFrom,
            let longFrom,
            let latTo,
            let longTo,
            let date,
            let time,
            let passengers,
            let specialNeed
        ):
            return [
                "user_id": custId,
                "latfrom": latFrom,
                "longifrom": longFrom,
                "latto": latTo,
                "longto": longTo,
                "date": date,
                "time": time,
                "passengers": passengers,
                "special_need": specialNeed
            ]
            
        case .createBooking(
            let pickupAddress,
            let dropAddress,
            let vehicleType,
            let passengers,
            let vehicleSeater,
            let specialNeed,
            let latFrom,
            let longFrom,
            let latTo,
            let longTo,
            let date,
            let time
        ):
            var params: Parameters = [
                "customer_id": custId,
                "pickupaddress": pickupAddress,
                "dropaddress": dropAddress,
                "vehicle_type": vehicleType,
                "passengers": passengers,
                "vehicle_seater": vehicleSeater,
                "special_need": specialNeed,
                "latfrom": latFrom,
                "longifrom": longFrom,
                "latto": latTo,
                "longto": longTo
            ]

            // Android's addBooking() only includes date/time at all when the rider
            // checked "advance" booking — immediate bookings omit the keys entirely
            // rather than sending them empty.
            if !date.isEmpty { params["date"] = date }
            if !time.isEmpty { params["time"] = time }

            return params
            
        case .cancelBooking(let bookingId, let reason):
            // Android's own rider app never sends a reason here — this is a new
            // requirement layered on top of its call, not a port of one. Key
            // name follows the driver app's cancel call (`change_book_status`
            // takes `cancel_message`), which is the only precedent this backend
            // has for "a cancellation reason" anywhere in either app.
            return [
                "booking_id": bookingId,
                "assign_status": "cancel",
                "cancel_message": reason
            ]
            
        case .getBookingStatus(let bookingId):
            return [
                "booking_id": bookingId
            ]
            
        case .getBookingDataToClient(let bookingId):
            return [
                "book_id": bookingId
            ]
            
        case .calculateFare(
            let bookingId,
            let price,
            let tollCharge,
            let customerRate,
            let feedback
        ):
            return [
                "book_id": bookingId,
                "price": price,
                "toll_charge": tollCharge,
                "customer_rate": customerRate,
                "feedback": feedback
            ]
            
        case .getFareDetails(let bookingId):
            return [
                "booking_id": bookingId
            ]
            
        case .aboutUs:
            return nil

        case .promotions:
            return nil

        case .help:
            return nil
        }
    }
}
