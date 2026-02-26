//
//  NetworkDebugLogger.swift
//  NewsApp-SwiftUI-MVVM-Combine
//
//  Created by Vijay Raj Dixit on 29/01/26.
//



import Foundation

struct NetworkDebugLogger {
    static func debugDecodingError(_ error: DecodingError) {
        
        switch error {
        case .typeMismatch(let type, let context):
            Log.shared.error("Decoding failed: type mismatch",
                             category: .network,
                             metadata: [
                                "type": "\(type)",
                                "codingPath": codingPathString(context.codingPath),
                                "description": context.debugDescription
                             ])
            
        case .valueNotFound(let type, let context):
            Log.shared.error("Decoding failed: value not found",
                             category: .network,
                             metadata: [
                                "type": "\(type)",
                                "codingPath": codingPathString(context.codingPath),
                                "description": context.debugDescription
                             ])
            
        case .keyNotFound(let key, let context):
            Log.shared.error("Decoding failed: key not found",
                             category: .network,
                             metadata: [
                                "key": key.stringValue,
                                "codingPath": codingPathString(context.codingPath),
                                "description": context.debugDescription
                             ])
            
        case .dataCorrupted(let context):
            Log.shared.error("Decoding failed: data corrupted",
                             category: .network,
                             metadata: [
                                "codingPath": codingPathString(context.codingPath),
                                "description": context.debugDescription
                             ])
            
        @unknown default:
            Log.shared.error("Decoding failed: unknown error", category: .network)
        }
    }

    private static func codingPathString(_ codingPath: [CodingKey]) -> String {
        codingPath.map(\.stringValue).joined(separator: ".")
    }
}
