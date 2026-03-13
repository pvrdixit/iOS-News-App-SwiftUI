//
//  InfrastructureErrorMapper.swift
//  NewsApp-SwiftUI
//
//  Created by Vijay Raj Dixit on 13/03/26.
//

import Foundation

/// Translates infrastructure failures into domain AppError values at the data boundary.
enum InfrastructureErrorMapper {
    static func mapHeadlinesError(_ error: Error) -> Error {
        if isCancellation(error) {
            return error
        }

        if let appError = error as? AppError {
            return appError
        }

        if let urlError = normalizedURLError(from: error) {
            switch urlError.code {
            case .notConnectedToInternet:
                return AppError.networkUnavailable
            case .timedOut:
                return AppError.timedOut
            case .badURL, .unsupportedURL:
                return AppError.invalidRequest
            case .badServerResponse, .cannotFindHost, .cannotConnectToHost, .networkConnectionLost:
                return AppError.serverError
            default:
                return AppError.invalidResponse
            }
        }

        if error is DecodingError {
            return AppError.decodingFailed
        }

        return AppError.unknown
    }

    static func mapStorageError(_ error: Error) -> AppError {
        if let appError = error as? AppError {
            return appError
        }

        return AppError.storageFailure
    }

    private static func isCancellation(_ error: Error) -> Bool {
        if error is CancellationError {
            return true
        }

        guard let urlError = normalizedURLError(from: error) else {
            return false
        }

        return urlError.code == .cancelled
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
