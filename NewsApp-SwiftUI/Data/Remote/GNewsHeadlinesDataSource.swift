//
//  GNewsHeadlinesDataSource.swift
//  NewsApp-SwiftUI
//
//  Created by Vijay Raj Dixit on 14/03/26.
//

import Foundation

/// Remote data source that talks to GNews and normalizes its page-based pagination.
final class GNewsHeadlinesDataSource: RemoteHeadlinesDataSource {
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
        category: String?,
        pageSize: Int,
        cursor: String?
    ) async throws -> HeadlinesPage {
        let safePageSize = min(max(1, pageSize), 10)
        let currentPage = normalizedPage(from: cursor)

        guard let url = makeURL(
            searchText: searchText,
            category: category,
            pageSize: safePageSize,
            page: currentPage
        ) else {
            throw URLError(.badURL)
        }

        let request = APIRequest(url: url, method: .get)
        let response: GNewsTopHeadlinesResponseDTO = try await networkService.requestAsync(request.urlRequest())

        return HeadlinesPage(
            articles: response.articles.compactMap(\.domainArticle),
            totalResults: response.totalArticles,
            nextCursor: nextCursor(
                currentPage: currentPage,
                pageSize: safePageSize,
                totalArticles: response.totalArticles
            )
        )
    }
}

private extension GNewsHeadlinesDataSource {
    func normalizedPage(from cursor: String?) -> Int {
        guard let cursor, let page = Int(cursor), page > 0 else {
            return 1
        }

        return page
    }

    func makeURL(
        searchText: String?,
        category: String?,
        pageSize: Int,
        page: Int
    ) -> URL? {
        let selectedCountryCode = GNewsPreferences.countryCode(default: countryCode)
        let selectedLanguageCode = GNewsPreferences.languageCode(default: languageCode)

        var components = URLComponents()
        components.scheme = "https"
        components.host = "gnews.io"
        components.path = "/api/v4/top-headlines"
        components.queryItems = [
            URLQueryItem(name: "apikey", value: apiKey),
            URLQueryItem(name: "country", value: selectedCountryCode),
            URLQueryItem(name: "lang", value: selectedLanguageCode),
            URLQueryItem(name: "max", value: "\(pageSize)"),
            URLQueryItem(name: "page", value: "\(page)")
        ]

        if let category, !category.isEmpty {
            components.queryItems?.append(URLQueryItem(name: "category", value: category))
        }

        let trimmedSearch = searchText?.trimmingCharacters(in: .whitespacesAndNewlines)
        if let trimmedSearch, !trimmedSearch.isEmpty {
            components.queryItems?.append(URLQueryItem(name: "q", value: trimmedSearch))
        }

        return components.url
    }
    func nextCursor(
        currentPage: Int,
        pageSize: Int,
        totalArticles: Int?
    ) -> String? {
        guard let totalArticles else { return nil }

        let cappedTotal = min(totalArticles, 1000)
        let shownCount = currentPage * pageSize

        guard shownCount < cappedTotal else {
            return nil
        }

        return String(currentPage + 1)
    }
}
