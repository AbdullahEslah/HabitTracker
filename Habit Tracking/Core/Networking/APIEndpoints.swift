//
//  Endpoints.swift
//  Smart Tracking Tasks
//
//  Created by Abdallah Eslah on 25/08/2025.
//

import Foundation

enum Auth :String{
    case login = "auth/login"
    case register = "users"
    case profile = "auth/profile"
}

class APIEndpoints {
    
    static let baseURL = "https://api.escuelajs.co/api/v1/"
    
    static func getURL(endpoint:Auth)-> String {
        return "\(baseURL)\(endpoint.rawValue)"
    }
    
}
