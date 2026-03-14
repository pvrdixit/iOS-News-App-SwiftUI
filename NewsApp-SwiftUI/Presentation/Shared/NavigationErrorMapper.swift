//
//  NavigationErrorMapper.swift
//  NewsApp-SwiftUI-MVVM-Combine
//
//  Created by Vijay Raj Dixit on 25/02/26.
//

import Foundation
import WebKit

/// Map low-level errors to user-facing messages
/// Maps WebKit navigation failures into user-facing copy for the article detail screen.
enum NavigationErrorMapper {
    static func message(from navigationError: WebPage.NavigationError, viewType: ViewType) -> String {
        switch navigationError {
        case .invalidURL:
            return "This article link appears to be invalid."
        case .webContentProcessTerminated:
            return "The page was interrupted while loading. Please try again."
        case .pageClosed:
            return "The page was closed before loading completed."
        case .failedProvisionalNavigation(let underlyingError):
            return message(from: underlyingError, viewType: viewType)
        @unknown default:
            return "Unable to load this article right now. Please try again."
        }
    }

    static func message(from error: Error, viewType: ViewType) -> String {
        let fallback = viewType == .newsView
            ? "Unable to load articles right now. Please try again."
            : "Unable to load this article right now. Please try again."

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

    private static func normalizedURLError(from error: Error) -> URLError? {
        if let urlError = error as? URLError {
            return urlError
        }

        let nsError = error as NSError
        guard nsError.domain == NSURLErrorDomain else {
            return nil
        }

        return URLError(URLError.Code(rawValue: nsError.code))
    }
}
