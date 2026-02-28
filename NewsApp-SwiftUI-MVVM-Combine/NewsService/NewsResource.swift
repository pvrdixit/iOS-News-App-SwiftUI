//
//  NewsResource.swift
//  NewsApp-SwiftUI-MVVM-Combine
//
//  Created by Vijay Raj Dixit on 29/01/26.
//

import Foundation

final class NewsResource: NewsService {
    private let service: NetworkService

    init(service: NetworkService) {
        self.service = service
    }

    /// Fetch paginated top headlines using async/await.
    func fetchTopHeadlines(page: Int = 1, pageSize: Int = 20) async throws -> Headlines {
        let safePage = max(1, page)
        let safePageSize = min(max(1, pageSize), 100)
        guard let url = makeTopHeadlinesURL(page: safePage, pageSize: safePageSize) else {
            throw URLError(.badURL)
        }

        let apiRequest = APIRequest(url: url, method: .get)
        return try await service.requestAsync(apiRequest.urlRequest())
    }
    
    /// Construct topheadlines API endpoint
    private func makeTopHeadlinesURL(page: Int, pageSize: Int) -> URL? {
        let safePage = max(1, page)
        let safePageSize = min(max(1, pageSize), 100) // API max page size

        var components = URLComponents()
        components.scheme = APIConstants.scheme
        components.host = APIConstants.host
        components.path = APIConstants.Path.topHeadlines
        components.queryItems = [
            URLQueryItem(name: APIConstants.Query.country, value: APIConstants.Default.country),
            URLQueryItem(name: APIConstants.Query.apiKey, value: NewsAPIKey.newsAPIKey),
            URLQueryItem(name: APIConstants.Query.page, value: "\(safePage)"),
            URLQueryItem(name: APIConstants.Query.pageSize, value: "\(safePageSize)")
        ]
        return components.url
    }
}
