//
//  APIRequest.swift
//  NewsApp-SwiftUI-MVVM-Combine
//
//  Created by Vijay Raj Dixit on 29/01/26.
//

import Foundation

enum HTTPMethod: String {
    case get     = "GET"
    case post    = "POST"
    case put     = "PUT"
    case delete  = "DELETE"
}

struct APIRequest {
    let url: URL
    let method: HTTPMethod
    var headers: [String: String] = [:]
    var body: Data? = nil

    func urlRequest() -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.allHTTPHeaderFields = headers
        request.httpBody = body
        return request
    }
}
