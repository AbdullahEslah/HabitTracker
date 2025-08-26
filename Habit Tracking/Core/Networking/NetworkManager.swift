//
//  NetworkManager.swift
//  Smart Tracking Tasks
//
//  Created by Abdallah Eslah on 25/08/2025.
//

import Foundation

enum HTTPMethod: String {
    case get     = "GET"
    case post    = "POST"
    case put     = "PUT"
    case delete  = "DELETE"
}

class NetworkManager {
    static let shared = NetworkManager()
    private init() {}
    
    func request<Success: Decodable, Failure: Decodable>(
        urlString: String,
        method: HTTPMethod,
        headers: [String: String]? = nil,
        body: Encodable? = nil,
        successType: Success.Type,
        failureType: Failure.Type
    ) async -> Result<Success, Failure> {
        
        guard let url = URL(string: urlString) else {
            return .failure(try! JSONDecoder().decode(Failure.self, from: Data("""
                {"message":"Invalid URL"}
                """.utf8)))
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        headers?.forEach { request.setValue($1, forHTTPHeaderField: $0) }
        
        if let body = body {
            do {
                request.httpBody = try JSONEncoder().encode(body)
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            } catch {
                return .failure(try! JSONDecoder().decode(Failure.self, from: Data("""
                    {"message":"Failed to encode request body"}
                    """.utf8)))
            }
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                return .failure(try! JSONDecoder().decode(Failure.self, from: Data("""
                    {"message":"Invalid response"}
                    """.utf8)))
            }
            
            if (200...299).contains(httpResponse.statusCode) {
                // حالة نجاح لكن الرد فاضي
                if data.isEmpty {
                    if Success.self == Void.self {
                        return .success(() as! Success) // نجاح بدون محتوى
                    } else {
                        return .failure(try! JSONDecoder().decode(Failure.self, from: Data("""
                            {"message":"Response is empty"}
                            """.utf8)))
                    }
                }
                do {
                    let decoded = try JSONDecoder().decode(Success.self, from: data)
                    return .success(decoded)
                } catch {
                    return .failure(try! JSONDecoder().decode(Failure.self, from: Data("""
                        {"message":"Decoding error"}
                        """.utf8)))
                }
            } else {
                // محاولة قراءة الخطأ من السيرفر
                if data.isEmpty {
                    return .failure(try! JSONDecoder().decode(Failure.self, from: Data("""
                        {"message":"Server error with code \(httpResponse.statusCode)"}
                        """.utf8)))
                }
                do {
                    let decodedError = try JSONDecoder().decode(Failure.self, from: data)
                    return .failure(decodedError)
                } catch {
                    return .failure(try! JSONDecoder().decode(Failure.self, from: Data("""
                        {"message":"Server error with code \(httpResponse.statusCode)"}
                        """.utf8)))
                }
            }
            
        } catch {
            if let urlError = error as? URLError, urlError.code == .notConnectedToInternet {
                return .failure(try! JSONDecoder().decode(Failure.self, from: Data("""
                    {"message":"No internet connection"}
                    """.utf8)))
            }
            return .failure(try! JSONDecoder().decode(Failure.self, from: Data("""
                {"message":"Unknown error: \(error.localizedDescription)"}
                """.utf8)))
        }
    }
}
