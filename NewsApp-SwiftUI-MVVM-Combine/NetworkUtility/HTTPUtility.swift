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

    /// Make Request, Validate Response and Decode it using Combine
    func request<T: Decodable>(_ request: URLRequest) -> AnyPublisher<T, Error> {
        session.dataTaskPublisher(for: request)
            .tryMap { data, response in
                guard
                    let httpResponse = response as? HTTPURLResponse,
                    (200...299).contains(httpResponse.statusCode)
                else {
                    throw URLError(.badServerResponse)
                }

                NetworkDebugLogger.debugResponseData(data)
                return data
            }
            .decode(type: T.self, decoder: decoder)
            .mapError { error in
                if let decodingError = error as? DecodingError {
                    NetworkDebugLogger.debugDecodingError(decodingError)
                }
                return error
            }
            .eraseToAnyPublisher()
    }
}
