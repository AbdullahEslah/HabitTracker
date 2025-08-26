//
//  إNetworkERROR.swift
//  Smart Tracking Tasks
//
//  Created by Abdallah Eslah on 25/08/2025.
//

import Foundation
enum NetworkError: LocalizedError {
    case invalidURL
    case noData
    case decodingError
    case noInternet
    case requestFailed(String)
    case unknown(String)

    var errorDescription: String? {
        switch self {
        case .invalidURL: return "Invalid URL"
        case .noData: return "No data returned"
        case .decodingError: return "Failed to decode response"
        case .noInternet: return "No internet connection"
        case .requestFailed(let message): return message
        case .unknown(let message): return message
        }
    }
}

//  main error type include message
struct APIError: Decodable, Error {
    let message: String
}
