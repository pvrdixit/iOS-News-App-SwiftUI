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

    /// Inject the service for testability; default is your HTTPUtility
    init(service: NetworkService = HTTPUtility()) {
        self.service = service
    }

    /// Fetch news using Combine
    func fetchTopHeadlines() -> AnyPublisher<Headlines, Error> {
        guard let url = makeTopHeadlinesURL() else {
            return Fail(error: URLError(.badURL))
                .eraseToAnyPublisher()
        }
        
        let apiRequest = APIRequest(url: url, method: .get)
        
        return service.request(apiRequest.urlRequest())
    }
    
    /// Construct topheadlines API endpoint
    private func makeTopHeadlinesURL() -> URL? {
        var components = URLComponents()
        components.scheme = APIConstants.scheme
        components.host = APIConstants.host
        components.path = APIConstants.Path.topHeadlines
        components.queryItems = [
            URLQueryItem(name: APIConstants.Query.country, value: APIConstants.Default.country),
            URLQueryItem(name: APIConstants.Query.apiKey, value: NewsAPIKey.newsAPIKey)
        ]
        return components.url
    }
}
