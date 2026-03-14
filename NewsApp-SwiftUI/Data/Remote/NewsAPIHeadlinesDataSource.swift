//
//  NewsAPIHeadlinesDataSource.swift
//  NewsApp-SwiftUI
//
//  Created by Vijay Raj Dixit on 13/03/26.
//

import Foundation

/// Remote data source that talks to NewsAPI and normalizes its pagination rules.
final class NewsAPIHeadlinesDataSource: RemoteHeadlinesDataSource {
    private let apiKey: String
    private let countryCode: String
    private let networkService: NetworkService

    init(apiKey: String, countryCode: String, networkService: NetworkService) {
        self.apiKey = apiKey
        self.countryCode = countryCode
        self.networkService = networkService
    }

    func fetchTopHeadlines(
        searchText: String?,
        category: String?,
        pageSize: Int,
        cursor: String?
    ) async throws -> HeadlinesPage {
        let safePageSize = min(max(1, pageSize), 100)
        let page = max(1, Int(cursor ?? "") ?? 1)

        guard let url = makeURL(
            searchText: searchText,
            category: category,
            page: page,
            pageSize: safePageSize
        ) else {
            throw URLError(.badURL)
        }

        let request = APIRequest(url: url, method: .get)
        let response: NewsAPITopHeadlinesResponseDTO = try await networkService.requestAsync(request.urlRequest())
        let nextCursor = Self.makeNextCursor(
            currentPage: page,
            pageSize: safePageSize,
            totalResults: response.totalResults
        )

        return HeadlinesPage(
            articles: response.articles.map(\.domainArticle),
            totalResults: response.totalResults,
            nextCursor: nextCursor
        )
    }
}

private extension NewsAPIHeadlinesDataSource {
    func makeURL(searchText: String?, category: String?, page: Int, pageSize: Int) -> URL? {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "newsapi.org"
        components.path = "/v2/top-headlines"
        components.queryItems = [
            URLQueryItem(name: "apiKey", value: apiKey),
            URLQueryItem(name: "country", value: countryCode)
        ]

        if let category, !category.isEmpty {
            components.queryItems?.append(URLQueryItem(name: "category", value: category))
        }

        let trimmedSearch = searchText?.trimmingCharacters(in: .whitespacesAndNewlines)
        if let trimmedSearch, !trimmedSearch.isEmpty {
            components.queryItems?.append(URLQueryItem(name: "q", value: trimmedSearch))
        }

        components.queryItems?.append(URLQueryItem(name: "page", value: "\(page)"))
        components.queryItems?.append(URLQueryItem(name: "pageSize", value: "\(pageSize)"))

        return components.url
    }
    static func makeNextCursor(currentPage: Int, pageSize: Int, totalResults: Int) -> String? {
        currentPage * pageSize < totalResults ? "\(currentPage + 1)" : nil
    }
}
