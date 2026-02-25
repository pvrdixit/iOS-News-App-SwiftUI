//
//  HTTPUtility.swift
//  NewsApp-SwiftUI-MVVM-Combine
//
//  Created by Vijay Raj Dixit on 29/01/26.
//



import Foundation
import Combine

final class HTTPUtility: NetworkService {
    
    private let session: URLSession
    private let decoder: JSONDecoder
    
    init(session: URLSession = .shared) {
        self.session = session
        self.decoder = JSONDecoder()
    }
    
    func request<T: Decodable>(_ request: URLRequest) -> AnyPublisher<T, Error> {
        session.dataTaskPublisher(for: request)
            // Validate HTTP response
            .tryMap { data, response in
                guard
                    let httpResponse = response as? HTTPURLResponse,
                    (200...299).contains(httpResponse.statusCode)
                else {
                    throw URLError(.badServerResponse)
                }

                NetworkDebugLogger.printResponseData(data)
                return data
            }
            // Decode
            .decode(type: T.self, decoder: decoder)
            .mapError { error in
                if let decodingError = error as? DecodingError {
                    NetworkDebugLogger.printDecodingError(decodingError)
                }
                return error
            }
            .eraseToAnyPublisher()
    }
    
    func requestAsync<T: Decodable>(_ request: URLRequest) async throws -> T {
        let (data, response) = try await session.data(for: request)

        guard
            let httpResponse = response as? HTTPURLResponse,
            (200...299).contains(httpResponse.statusCode)
        else {
            throw URLError(.badServerResponse)
        }

        NetworkDebugLogger.printResponseData(data)

        do {
            return try decoder.decode(T.self, from: data)
        } catch let decodingError as DecodingError {
            NetworkDebugLogger.printDecodingError(decodingError)
            throw decodingError
        }
    }
}
