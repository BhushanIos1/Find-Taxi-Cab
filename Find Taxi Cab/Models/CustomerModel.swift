//
//  CustomerModel.swift
//  Find Taxi Cab
//
//  Created by Bhushan Kumar on 12/04/26.
//

struct LoginResponse: Decodable {
    
    let result: String
    let message: String?
    let customerData: Customer?
    
    enum CodingKeys: String, CodingKey {
        case result
        case message
        case customerData = "customer_data"
    }
}

struct Customer: Decodable {
    
    let custId: String
    let email: String?
    let password: String?
    
    let phoneNo: String?
    let emergencyContact: String?
    
    let custName: String?
    let address: String?
    let city: String?
    let postalCode: String?
    
    let profilePhoto: String?
    
    let cardNumber: String?
    let cardHolderName: String?
    let cardMonth: String?
    let cardYear: String?
    let cvv: String?
    
    let customerLat: String?
    let customerLng: String?
    
    let accountStatus: String?
    let status: String?
    
    let accountCreated: String?
    let addedOn: String?
    
    let companyId: String?
    
    let forgotToken: String?
    
    let token: String?
    let deviceType: String?
}

extension Customer {
    
    enum CodingKeys: String, CodingKey {
        
        case custId = "custid"
        
        case email
        case password
        
        case phoneNo = "phoneno"
        case emergencyContact = "emerngency_contact"
        
        case custName = "cust_name"
        case address
        case city
        
        case postalCode = "postalcode"
        
        case profilePhoto = "profile_photo"
        
        case cardNumber = "card_number"
        case cardHolderName = "card_holder_name"
        case cardMonth = "card_month"
        case cardYear = "card_year"
        case cvv
        
        case customerLat = "customer_lat"
        case customerLng = "customer_lng"
        
        case accountStatus = "acctount_status"
        case status
        
        case accountCreated = "account_created"
        case addedOn = "added_on"
        
        case companyId = "company_id"
        
        case forgotToken = "forgot_token"
        
        case token
        case deviceType = "device_type"
    }
}
