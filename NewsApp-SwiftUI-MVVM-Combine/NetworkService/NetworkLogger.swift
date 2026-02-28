//
//  NetworkLogger.swift
//  NewsApp-SwiftUI-MVVM-Combine
//
//  Created by Vijay Raj Dixit on 28/02/26.
//


import Foundation

enum NetworkLogger {

    static func logDecodingError(_ error: DecodingError, logger: LoggerService) {
        logger.error("Decoding failed", category: .network, metadata: decodingMetadata(error))
    }
    
    private static func decodingMetadata(_ error: DecodingError) -> [String: String] {
        switch error {
        case .typeMismatch(let type, let context):
            return [
                "kind": "typeMismatch",
                "type": "\(type)",
                "codingPath": codingPath(context.codingPath),
                "description": context.debugDescription
            ]

        case .valueNotFound(let type, let context):
            return [
                "kind": "valueNotFound",
                "type": "\(type)",
                "codingPath": codingPath(context.codingPath),
                "description": context.debugDescription
            ]

        case .keyNotFound(let key, let context):
            return [
                "kind": "keyNotFound",
                "key": key.stringValue,
                "codingPath": codingPath(context.codingPath),
                "description": context.debugDescription
            ]

        case .dataCorrupted(let context):
            return [
                "kind": "dataCorrupted",
                "codingPath": codingPath(context.codingPath),
                "description": context.debugDescription
            ]

        @unknown default:
            return ["kind": "unknown"]
        }
    }

    private static func codingPath(_ path: [CodingKey]) -> String {
        path.map(\.stringValue).joined(separator: ".")
    }
}
