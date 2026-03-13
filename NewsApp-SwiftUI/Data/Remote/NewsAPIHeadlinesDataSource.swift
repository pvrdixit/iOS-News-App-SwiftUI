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
        category: NewsCategory?,
        pageSize: Int,
        cursor: String?
    ) async throws -> ProviderHeadlinesPage {
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

        return ProviderHeadlinesPage(
            articles: response.articles.map(\.domainArticle),
            totalResults: response.totalResults,
            nextCursor: nextCursor
        )
    }
}

private extension NewsAPIHeadlinesDataSource {
    func makeURL(searchText: String?, category: NewsCategory?, page: Int, pageSize: Int) -> URL? {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "newsapi.org"
        components.path = "/v2/top-headlines"
        components.queryItems = [
            URLQueryItem(name: "country", value: countryCode),
            URLQueryItem(name: "apiKey", value: apiKey),
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "pageSize", value: "\(pageSize)")
        ]

        if let categoryValue = newsAPICategoryValue(for: category) {
            components.queryItems?.append(URLQueryItem(name: "category", value: categoryValue))
        }

        let trimmedSearch = searchText?.trimmingCharacters(in: .whitespacesAndNewlines)
        if let trimmedSearch, !trimmedSearch.isEmpty {
            components.queryItems?.append(URLQueryItem(name: "q", value: trimmedSearch))
        }

        debugPrint(components.url ?? "")
        return components.url
    }

    func newsAPICategoryValue(for category: NewsCategory?) -> String? {
        switch category {
        case .top:
            return nil
        case .general:
            return NewsCategory.general.rawValue
        case .business:
            return NewsCategory.business.rawValue
        case .technology:
            return NewsCategory.technology.rawValue
        case .sports:
            return NewsCategory.sports.rawValue
        case .entertainment:
            return NewsCategory.entertainment.rawValue
        case .health:
            return NewsCategory.health.rawValue
        case .science:
            return NewsCategory.science.rawValue
        default:
            return nil
        }
    }

    static func makeNextCursor(currentPage: Int, pageSize: Int, totalResults: Int) -> String? {
        currentPage * pageSize < totalResults ? "\(currentPage + 1)" : nil
    }
}
