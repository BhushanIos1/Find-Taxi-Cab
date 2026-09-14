//
//  APIResponse.swift
//  Find Taxi Cab
//
//  Created by Bhushan Kumar on 21/03/26.
//

struct APIResponse<T: Decodable>: Decodable {
    
    let result: String?
    let message: String?
    let data: T?
    let success: Int?
    
    var isSuccess: Bool {
        if result == "success" { return true }
        if success == 1 || success == 200 { return true }
        return false
    }
}

struct CommonResponse: Decodable {

    let result: String?
    let message: String?

    enum CodingKeys: String, CodingKey {
        case result, message, error
    }

    /// The backend reports success under `message` but failure under `error`.
    /// Android papers over that in `BaseActivity.getErrorMessage()` — same chain
    /// here, so a failed call surfaces what actually went wrong instead of nil.
    init(from decoder: Decoder) throws {

        let container = try decoder.container(keyedBy: CodingKeys.self)

        result = try container.decodeIfPresent(String.self, forKey: .result)

        message = try container.decodeIfPresent(String.self, forKey: .message)
            ?? container.decodeIfPresent(String.self, forKey: .error)
    }

    init(result: String?, message: String?) {
        self.result = result
        self.message = message
    }
}
