//
//  AppErrorMapper.swift
//  NewsApp-SwiftUI
//
//  Created by Vijay Raj Dixit on 13/03/26.
//

import Foundation

/// Maps domain AppError values into screen-friendly user messages.
enum AppErrorMapper {
    static func message(from error: Error, viewType: ViewType) -> String {
        let fallback = viewType == .newsView
            ? "Unable to load articles right now. Please try again."
            : "Unable to load this article right now. Please try again."

        guard let appError = error as? AppError else {
            return fallback
        }

        switch appError {
        case .networkUnavailable:
            return "No internet connection. Please check your network and try again."
        case .timedOut:
            return "The request timed out. Please try again."
        case .serverError, .invalidResponse:
            return "Could not connect to the server. Please try again."
        case .invalidRequest:
            return fallback
        case .decodingFailed:
            return "We received an unexpected response. Please try again."
        case .unconfiguredProvider:
            return "This news provider is not configured right now."
        case .storageFailure:
            return "Saved data is temporarily unavailable."
        case .unknown:
            return fallback
        }
    }
}
