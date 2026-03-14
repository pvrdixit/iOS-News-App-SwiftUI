//
//  NewsDataHeadlinesDataSource.swift
//  NewsApp-SwiftUI
//
//  Created by Vijay Raj Dixit on 13/03/26.
//

import Foundation

/// Remote data source that talks to NewsData and normalizes its cursor-based pagination.
final class NewsDataHeadlinesDataSource: RemoteHeadlinesDataSource {
    private let apiKey: String
    private let countryCode: String
    private let languageCode: String
    private let networkService: NetworkService

    init(
        apiKey: String,
        countryCode: String,
        languageCode: String,
        networkService: NetworkService
    ) {
        self.apiKey = apiKey
        self.countryCode = countryCode
        self.languageCode = languageCode
        self.networkService = networkService
    }

    func fetchTopHeadlines(
        searchText: String?,
        category: NewsCategory?,
        pageSize: Int,
        cursor: String?
    ) async throws -> HeadlinesPage {
        let safePageSize = min(max(1, pageSize), 50)

        guard let url = makeURL(
            searchText: searchText,
            category: category,
            pageSize: safePageSize,
            cursor: cursor
        ) else {
            throw URLError(.badURL)
        }

        let request = APIRequest(url: url, method: .get)
        let response: NewsDataLatestResponseDTO = try await networkService.requestAsync(request.urlRequest())
        let articles = response.results
            .filter { $0.duplicate == false }
            .compactMap(\.domainArticle)

        return HeadlinesPage(
            articles: articles,
            totalResults: response.totalResults,
            nextCursor: response.nextPage
        )
    }
}

private extension NewsDataHeadlinesDataSource {
    func makeURL(
        searchText: String?,
        category: NewsCategory?,
        pageSize: Int,
        cursor: String?
    ) -> URL? {
        let selectedCountryCode = NewsDataPreferences.countryCode(default: countryCode)
        let selectedLanguageCode = NewsDataPreferences.languageCode(default: languageCode)

        var components = URLComponents()
        components.scheme = "https"
        components.host = "newsdata.io"
        components.path = "/api/1/latest"
        components.queryItems = [
            URLQueryItem(name: "apikey", value: apiKey),
            URLQueryItem(name: "country", value: selectedCountryCode),
            URLQueryItem(name: "language", value: selectedLanguageCode),
            URLQueryItem(name: "size", value: "\(pageSize)"),
            URLQueryItem(name: "removeduplicate", value: "1")
        ]

        if let categoryValue = newsDataCategoryValue(for: category) {
            components.queryItems?.append(URLQueryItem(name: "category", value: categoryValue))
        }

        let trimmedSearch = searchText?.trimmingCharacters(in: .whitespacesAndNewlines)
        if let trimmedSearch, !trimmedSearch.isEmpty {
            components.queryItems?.append(URLQueryItem(name: "q", value: trimmedSearch))
        }

        if let cursor, !cursor.isEmpty {
            components.queryItems?.append(URLQueryItem(name: "page", value: cursor))
        }

        return components.url
    }

    func newsDataCategoryValue(for category: NewsCategory?) -> String? {
        switch category {
        case .top:
            return "top"
        case .general:
            return "general"
        case .world:
            return "world"
        case .business:
            return "business"
        case .technology:
            return "technology"
        case .sports:
            return "sports"
        case .entertainment:
            return "entertainment"
        case .education:
            return "education"
        case .lifestyle:
            return "food,lifestyle,tourism"
        case .environment:
            return "environment"
        case .science:
            return "science"
        case .health:
            return "health"
        case nil:
            return nil
        }
    }
}
