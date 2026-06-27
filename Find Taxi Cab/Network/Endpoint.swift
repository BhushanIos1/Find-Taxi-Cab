//
//  Endpoint.swift
//  Find Taxi Cab Driver
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

enum DriverAPI: Endpoint {
    
    case login(email: String,
               password: String,
               token: String)
    case register(
        name: String,
        email: String,
        phone: String,
        password: String,
        address: String
    )
    case forgotPassword(email: String)
    case changePassword(password: String)
    case updateProfile(
        driverName: String,
        contactNo: String,
        address: String,
        bankAccountNumber: String,
        driverPhoto: String?
    )
    case logout
    case changeStatus(status: String)
    case updateLocation(lat: String, lng: String)
    case updateFCMToken(token: String)
    case lastBooking
    case bookingList
    case updateBankDetails(parameters: Parameters)
    case paymentHistory
    case customerFeedback
    case checkAccountStatus
    case getDriverLatLng
    case getDriverStatus
    case getNearClients(lat: String, lng: String)
    case driverFeedback(bookingId: String, feedback: String, rate: String)
}

extension DriverAPI {
    
    var path: String {
        switch self {
        case .login: return "/driver_login"
        case .register: return "/register_driver"
        case .forgotPassword: return "/reset_pass"
        case .changePassword: return "/driver_change_pass"
        case .updateProfile: return "/update_driver_profile"
        case .logout: return "/logout_driver"
        case .changeStatus: return "/change_status"
        case .updateLocation: return "/driver_location"
        case .updateFCMToken: return "/update_drivertoken"
        case .lastBooking: return "/driver_last_book"
        case .bookingList: return "/driver_book_list"
        case .updateBankDetails: return "/driver_update_bank"
        case .paymentHistory: return "/payment_history_driver"
        case .customerFeedback: return "/customer_feedback_data"
        case .checkAccountStatus: return "/check_account_status"
        case .getDriverLatLng: return "/get_driverlatlng"
        case .getDriverStatus: return "/get_driver_status"
        case .getNearClients: return "/get_nearclient"
        case .driverFeedback: return "/driver_feedback"
        }
    }
    
    var parameters: Parameters? {
        
        let driverId = AuthManager.shared.driverId
        
        switch self {
            
        case .login(let email, let password, let token):
            return [
                "email": email,
                "password": password,
                "token": token,
                "device_type": "ios"
            ]
            
        case .register(_, let email, let phone, let password, _):
            return [
                "email": email,
                "contact_no": phone,
                "password": password
            ]
            
        case .forgotPassword(let email):
            return [
                "driver_id": email
            ]
            
        case .changePassword(let password):
            return [
                "driver_id": driverId,
                "password": password
            ]
            
        case .updateProfile(
            let driverName,
            let contactNo,
            let address,
            let bankAccountNumber,
            let driverPhoto
        ):
            return [
                "driver_id": driverId,
                "driverName": driverName,
                "contact_no": contactNo,
                "address": address,
                "bank_account_number": bankAccountNumber,
                "driver_photo": driverPhoto ?? ""
            ]
            
        case .logout:
            return ["driver_id": driverId]
            
        case .changeStatus(let status):
            return [
                "driver_id": driverId,
                "status": status
            ]
            
        case .updateLocation(let lat, let lng):
            return [
                "driver_id": driverId,
                "latitude": lat,
                "longitude": lng,
                "date": Date().apiDate,
                "time": Date().apiTime,
                "booking_id": ""
            ]
        case .updateFCMToken(let token):
            return [
                "driver_id": driverId,
                "token": token
            ]
            
        case .lastBooking:
            return [
                "driver_id": driverId
            ]
            
        case .bookingList:
            return ["driver_id": driverId]
            
        case .updateBankDetails(let parameters):
            var params = parameters
            params["driver_id"] = driverId
            return params
            
        case .paymentHistory:
            return [
                "driver_id": driverId
            ]
            
        case .customerFeedback:
            return [
                "driver_id": driverId
            ]
            
        case .checkAccountStatus:
            return [
                "id": driverId
            ]
            
        case .getDriverLatLng:
            return [
                "driver_id": driverId
            ]
            
        case .getDriverStatus:
            return [
                "driver_id": driverId
            ]
            
        case .getNearClients(let lat, let lng):
            return [
                "lat": lat,
                "long": lng
            ]
            
        case .driverFeedback(let bookingId, let feedback, let rate):
            return [
                "booking_id": bookingId,
                "feedback": feedback,
                "rate": rate
            ]
        }
    }
}
