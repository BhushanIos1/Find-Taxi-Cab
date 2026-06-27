//
//  CustomerModel.swift
//  Find Taxi Cab
//
//  Created by Bhushan Kumar on 12/04/26.
//

struct LoginResponse: Decodable {
    let result: String
    let customer_data: Customer?
    let error: String?
}

struct Customer: Decodable {
    
    let id: String
    let email: String?
    let password: String?
    let contactNo: String?
    let emergencyContactNo: String?
    let address: String?
    let postcode: String?
    let title: String?
    let driverName: String?
    let driverPhoto: String?
    
    let driverLicenceNo: String?
    let licensePhoto: String?
    let driverLicenceExpiryDate: String?
    let dbsLicenceExpiryDate: String?
    
    let hcPlateNumber: String?
    let hcPlateExpDate: String?
    let hcVehicleRegNo: String?
    
    let motExpDate: String?
    let vehInsExpDate: String?
    
    let badgeNumber: String?
    let badgePhoto: String?
    let badgeExpiryDate: String?
    
    let vehicleSeater: String?
    let vehicleNo: String?
    let vehicleMake: String?
    let vehicleModel: String?
    let vehicleAmenities: String?
    let wheelchair: String?
    
    let vehicleInsuranceCompany: String?
    let vehicleInsuranceExpiry: String?
    let vehicleInsurancePhoto: String?
    
    let percent: String?
    
    let driverLat: String?
    let driverLng: String?
    let currentLocation: String?
    
    let bankAccountName: String?
    let bankName: String?
    let bankAccountNumber: String?
    let bankAddress: String?
    let bankCode: String?
    
    let forgotToken: String?
    
    let totalEarned: String?
    let acceptedJobs: String?
    let rejectedJobs: String?
    
    let workStatus: String?
    let accountStatus: String?
    
    let addedAt: String?
    let statusDate: String?
    let statusTime: String?
    
    let token: String?
    let deviceType: String?
    let handAmount: String?
}

extension Customer {
    
    enum CodingKeys: String, CodingKey {
        
        case id
        case email
        case password
        case contactNo = "contact_no"
        case emergencyContactNo = "emergency_contact_no"
        case address
        case postcode
        case title
        case driverName
        case driverPhoto = "driver_photo"
        
        case driverLicenceNo
        case licensePhoto = "license_photo"
        case driverLicenceExpiryDate
        case dbsLicenceExpiryDate
        
        case hcPlateNumber = "hc_plate_number"
        case hcPlateExpDate = "hc_plate_exp_date"
        case hcVehicleRegNo = "hc_vehicle_reg_no"
        
        case motExpDate = "mot_exp_date"
        case vehInsExpDate = "veh_ins_exp_date"
        
        case badgeNumber
        case badgePhoto = "badge_photo"
        case badgeExpiryDate
        
        case vehicleSeater = "vehicle_seater"
        case vehicleNo = "vehicle_no"
        case vehicleMake = "vehicle_make"
        case vehicleModel = "vehicle_model"
        case vehicleAmenities = "vehicle_amenities"
        case wheelchair
        
        case vehicleInsuranceCompany = "vehicle_insuarance_company"
        case vehicleInsuranceExpiry = "vehicle_insuarance_expiry"
        case vehicleInsurancePhoto = "vehicle_insuarance_photo"
        
        case percent
        
        case driverLat = "driver_lat"
        case driverLng = "driver_lng"
        case currentLocation = "current_location"
        
        case bankAccountName = "bank_account_name"
        case bankName = "bank_name"
        case bankAccountNumber = "bank_account_number"
        case bankAddress = "bank_address"
        case bankCode = "bank_code"
        
        case forgotToken = "forgot_token"
        
        case totalEarned = "total_earned"
        case acceptedJobs = "accpted_jobs"
        case rejectedJobs = "rejected_jobs"
        
        case workStatus = "work_status"
        case accountStatus = "acctount_status"
        
        case addedAt = "added_at"
        case statusDate = "status_date"
        case statusTime = "status_time"
        
        case token
        case deviceType = "device_type"
        case handAmount = "hand_amount"
    }
}
