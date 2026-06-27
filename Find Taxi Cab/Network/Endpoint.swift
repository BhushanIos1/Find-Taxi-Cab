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
}

extension Endpoint {
    
    var baseURL: String {
        return "http://view.findtaxicab.com/admin/api"
    }
    
    var method: HTTPMethod {
        return .post
    }
    
    var encoding: ParameterEncoding {
        return URLEncoding.httpBody
    }
}

enum CustomerAPI: Endpoint {
    
    case register(
        email: String,
        phone: String,
        password: String,
        cardNumber: String,
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
    
    case editCardDetails(parameters: Parameters)
    
    case getCardDetails
    
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
        specialNeed: String,
        latFrom: String,
        longFrom: String,
        latTo: String,
        longTo: String,
        date: String?,
        time: String?
    )
    
    case getBookingData(bookingId: String)
    
    case cancelBooking(bookingId: String)
    
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
            
        case .editCardDetails:
            return "/edit_card_detaile"
            
        case .getCardDetails:
            return "/get_card_details"
            
        case .customerFeedback:
            return "/customer_feedback"
            
        case .lastBooking:
            return "/client_last_book"
            
        case .bookingList:
            return "/get_book_list"
            
        case .vehicleList:
            return "/vehicle_list"
            
        case .createBooking:
            return "/add_booking"
            
        case .getBookingData:
            return "/get_bookdata"
            
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
            let email,
            let phone,
            let password,
            let cardNumber,
            let profilePhoto
        ):
            return [
                "email": email,
                "phoneno": phone,
                "password": password,
                "card_number": cardNumber,
                "profile_photo": profilePhoto ?? ""
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
            
        case .editCardDetails(let parameters):
            
            var params = parameters
            params["custid"] = custId
            return params
            
        case .getCardDetails:
            return [
                "custid": custId
            ]
            
        case .customerFeedback(
            let bookingId,
            let feedback,
            let rate
        ):
            return [
                "booking_id": bookingId,
                "feedback": feedback,
                "customer_rate": rate
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
            let specialNeed,
            let latFrom,
            let longFrom,
            let latTo,
            let longTo,
            let date,
            let time
        ):
            return [
                "customer_id": custId,
                "pickupaddress": pickupAddress,
                "dropaddress": dropAddress,
                "vehicle_type": vehicleType,
                "passengers": passengers,
                "special_need": specialNeed,
                "latfrom": latFrom,
                "longifrom": longFrom,
                "latto": latTo,
                "longto": longTo,
                "date": date ?? "",
                "time": time ?? ""
            ]
            
        case .getBookingData(let bookingId):
            return [
                "id": custId,
                "booking_id": bookingId
            ]
            
        case .cancelBooking(let bookingId):
            return [
                "booking_id": bookingId,
                "assign_status": "cancel"
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
