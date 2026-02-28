//
//  HTTPUtility.swift
//  NewsApp-SwiftUI-MVVM-Combine
//
//  Created by Vijay Raj Dixit on 29/01/26.
//



import Foundation

final class HTTPUtility: NetworkService {

    private let session: URLSession
    private let decoder: JSONDecoder
    private let logger: LoggerService

    /// Default init with a standard request/resource timeout.
    init(timeout: TimeInterval, logger: LoggerService) {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = timeout
        config.timeoutIntervalForResource = timeout

        self.session = URLSession(configuration: config)
        self.decoder = JSONDecoder()
        self.logger = logger
    }

    /// Make request, validate response, decode (async/await).
    func requestAsync<T: Decodable>(_ request: URLRequest) async throws -> T {
        let (data, response) = try await session.data(for: request)

        guard
            let httpResponse = response as? HTTPURLResponse,
            (200...299).contains(httpResponse.statusCode)
        else {
            throw URLError(.badServerResponse)
        }

        do {
            return try decoder.decode(T.self, from: data)
        } catch let decodingError as DecodingError {
            NetworkLogger.logDecodingError(decodingError, logger: logger)
            throw decodingError
        }
    }
}
