//
//  NetworkErrorMapper.swift
//  NewsApp-SwiftUI-MVVM-Combine
//
//  Created by Vijay Raj Dixit on 25/02/26.
//

import Foundation

enum ViewType {
    case newsView
    case newsDetailView
}

/// Map low-level errors to user-facing messages
enum NetworkErrorMapper {
    static func message(from error: Error, viewType: ViewType) -> String {
        let fallback = viewType == .newsView ? "Unable to load articles right now. Please try again." : "Unable to load this article right now. Please try again."
        
        guard let urlError = normalizedURLError(from: error) else {
            return fallback
        }

        switch urlError.code {
        case .notConnectedToInternet:
            return "No internet connection. Please check your network and try again."
        case .timedOut:
            return "The request timed out. Please try again."
        case .cannotFindHost, .cannotConnectToHost, .networkConnectionLost:
            return "Could not connect to the server. Please try again."
        default:
            return fallback
        }
    }

    static func normalizedURLError(from error: Error) -> URLError? {
        if let urlError = error as? URLError {
            return urlError
        }

        let nsError = error as NSError
        guard nsError.domain == NSURLErrorDomain else {
            return nil
        }

        // Construct a URLError using the NSError's code in the NSURLErrorDomain
        let code = URLError.Code(rawValue: nsError.code)
        return URLError(code)
    }
}
