//
//  NewsResource.swift
//  NewsApp-SwiftUI-MVVM-Combine
//
//  Created by Vijay Raj Dixit on 29/01/26.
//



import Foundation
import Combine

final class NewsResource {
    private let service: NetworkService

    // Inject the service for testability; default is your HTTPUtility
    init(service: NetworkService = HTTPUtility()) {
        self.service = service
    }

    // Primary API: caller supplies apiKey explicitly
    func fetchTopHeadlines() -> AnyPublisher<Headlines, Error> {
        guard let url = makeTopHeadlinesURL(apiKey: NewsAPIKey.newsAPIKey) else {
            return Fail(error: URLError(.badURL))
                .eraseToAnyPublisher()
        }
        
        let apiRequest = APIRequest(url: url, method: .get)
        
        return service.request(apiRequest.urlRequest())
    }
    
    // Async API
    func fetchTopHeadlinesAsync() async throws -> Headlines {
        guard let url = makeTopHeadlinesURL(apiKey: NewsAPIKey.newsAPIKey) else {
            throw URLError(.badURL)
        }

        let apiRequest = APIRequest(url: url, method: .get)
        return try await service.requestAsync(apiRequest.urlRequest())
    }
    
    // MARK: - Private helpers
    private func makeTopHeadlinesURL(apiKey: String) -> URL? {
        var components = URLComponents()
        components.scheme = APIConstants.scheme
        components.host = APIConstants.host
        components.path = APIConstants.Path.topHeadlines
        components.queryItems = [
            URLQueryItem(name: APIConstants.Query.country, value: APIConstants.Default.country),
            URLQueryItem(name: APIConstants.Query.apiKey, value: apiKey)
        ]
        return components.url
    }
}
