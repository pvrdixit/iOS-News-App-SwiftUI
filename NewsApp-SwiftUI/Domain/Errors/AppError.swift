//
//  AppError.swift
//  NewsApp-SwiftUI
//
//  Created by Vijay Raj Dixit on 13/03/26.
//

import Foundation

/// Domain-level error used to shield presentation from network and persistence details.
enum AppError: Error, Equatable, LocalizedError {
    case networkUnavailable
    case timedOut
    case serverError
    case invalidRequest
    case invalidResponse
    case decodingFailed
    case unconfiguredProvider(String)
    case storageFailure
    case unknown

    var errorDescription: String? {
        switch self {
        case .networkUnavailable:
            return "Network unavailable"
        case .timedOut:
            return "Request timed out"
        case .serverError:
            return "Server error"
        case .invalidRequest:
            return "Invalid request"
        case .invalidResponse:
            return "Invalid response"
        case .decodingFailed:
            return "Response decoding failed"
        case .unconfiguredProvider(let providerName):
            return "\(providerName) is not configured."
        case .storageFailure:
            return "Storage failure"
        case .unknown:
            return "Unknown error"
        }
    }
}
