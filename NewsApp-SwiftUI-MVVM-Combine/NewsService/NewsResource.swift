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
    func fetchTopHeadlines(search: String?, category: String?, page: Int = 1, pageSize: Int = 20) async throws -> Headlines {
        let safePage = max(1, page)
        let safePageSize = min(max(1, pageSize), 100)
        guard let url = makeTopHeadlinesURL(search: search, category: category, page: safePage, pageSize: safePageSize) else {
            throw URLError(.badURL)
        }

        let apiRequest = APIRequest(url: url, method: .get)
        return try await service.requestAsync(apiRequest.urlRequest())
    }
    
    /// Construct topheadlines API endpoint
    private func makeTopHeadlinesURL(search: String? = nil, category: String? = nil, page: Int, pageSize: Int) -> URL? {
        let safePage = max(1, page)
        let safePageSize = min(max(1, pageSize), 100) // API max page size

        var components = URLComponents()
        components.scheme = APIConstants.scheme
        components.host = APIConstants.host
        components.path = APIConstants.Path.topHeadlines
       
        components.queryItems = [(URLQueryItem(name: APIConstants.Query.country, value: APIConstants.Default.country))]
        
        if let category, !category.isEmpty {
            components.queryItems?.append(URLQueryItem(name: APIConstants.Query.category, value: category))
        }

        if let search, !search.isEmpty {
            components.queryItems?.append(URLQueryItem(name: APIConstants.Query.search, value: search))
        }
        
        components.queryItems?.append(URLQueryItem(name: APIConstants.Query.apiKey, value: NewsAPIKey.newsAPIKey))
        components.queryItems?.append(URLQueryItem(name: APIConstants.Query.page, value: "\(safePage)"))
        components.queryItems?.append(URLQueryItem(name: APIConstants.Query.pageSize, value: "\(safePageSize)"))
        
        print("NewsResource endpoint: \(components.url?.absoluteString ?? "")")
        return components.url
    }
}
