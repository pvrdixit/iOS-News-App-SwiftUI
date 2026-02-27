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

    /// Default init with a standard request/resource timeout.
    init(timeout: TimeInterval = 8.0) {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = timeout
        config.timeoutIntervalForResource = timeout

        self.session = URLSession(configuration: config)
        self.decoder = JSONDecoder()
    }

    /// Make request, validate response, decode (async/await).
    func requestAsync<T: Decodable>(_ request: URLRequest) async throws -> T {
        let method = request.httpMethod ?? "GET"
        let urlString = request.url?.absoluteString ?? "unknown"

        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await session.data(for: request)
        } catch {
            Log.shared.error("Request failed",
                             category: .network,
                             metadata: [
                                "method": method,
                                "url": urlString,
                                "error": error.localizedDescription
                             ])
            throw error
        }

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode)
        else {
            if let httpResponse = response as? HTTPURLResponse {
                Log.shared.error("Request returned bad status code",
                                 category: .network,
                                 metadata: [
                                    "method": method,
                                    "url": urlString,
                                    "statusCode": "\(httpResponse.statusCode)"
                                 ])
            } else {
                Log.shared.error("Request returned non-HTTP response",
                                 category: .network,
                                 metadata: [
                                    "method": method,
                                    "url": urlString
                                 ])
            }
            throw URLError(.badServerResponse)
        }

        do {
            return try decoder.decode(T.self, from: data)
        } catch let decodingError as DecodingError {
            NetworkDebugLogger.debugDecodingError(decodingError)
            Log.shared.error("Response decode failed",
                             category: .network,
                             metadata: [
                                "method": method,
                                "url": urlString,
                                "error": decodingError.localizedDescription
                             ])
            throw decodingError
        } catch {
            Log.shared.error("Unexpected decode error",
                             category: .network,
                             metadata: [
                                "method": method,
                                "url": urlString,
                                "error": error.localizedDescription
                             ])
            throw error
        }
    }
}
