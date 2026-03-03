//
//  NavigationErrorMapper.swift
//  NewsApp-SwiftUI-MVVM-Combine
//
//  Created by Vijay Raj Dixit on 25/02/26.
//

import WebKit

/// Map low-level errors to user-facing messages
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
            return NetworkErrorMapper.message(from: underlyingError, viewType: viewType)
        @unknown default:
            return "Unable to load this article right now. Please try again."
        }
    }
}
