//
//  NetworkDebugLogger.swift
//  NewsApp-SwiftUI-MVVM-Combine
//
//  Created by Vijay Raj Dixit on 29/01/26.
//



import Foundation

struct NetworkDebugLogger {
    static func printResponseData(_ data: Data?) {
#if DEBUG
        guard let data = data else {
            print("No data")
            return
        }
        
        // Try JSON
        if let object = try? JSONSerialization.jsonObject(with: data),
           let prettyData = try? JSONSerialization.data(withJSONObject: object, options: .prettyPrinted),
           let json = String(data: prettyData, encoding: .utf8) {
            print("RESPONSE BODY (JSON)")
            print(json)
        } else {
            // Fallback: plain text
            print("RESPONSE BODY (RAW)")
            print(String(decoding: data, as: UTF8.self))
        }
#endif // DEBUG
    }
    
    static func printDecodingError(_ error: DecodingError) {
#if DEBUG
        print("Decoding failed")
        
        switch error {
            
        case .typeMismatch(let type, let context):
            print("Type mismatch for type:", type)
            print("CodingPath:", context.codingPath)
            print("Description:", context.debugDescription)
            
        case .valueNotFound(let type, let context):
            print("Value not found for type:", type)
            print("CodingPath:", context.codingPath)
            print("Description:", context.debugDescription)
            
        case .keyNotFound(let key, let context):
            print("Key not found:", key.stringValue)
            print("CodingPath:", context.codingPath)
            print("Description:", context.debugDescription)
            
        case .dataCorrupted(let context):
            print("Data corrupted")
            print("CodingPath:", context.codingPath)
            print("Description:", context.debugDescription)
            
        @unknown default:
            print("Unknown decoding error")
        }
#endif // DEBUG
    }
}
