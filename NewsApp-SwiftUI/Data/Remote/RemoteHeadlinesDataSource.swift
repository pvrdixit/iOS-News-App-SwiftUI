//
//  RemoteHeadlinesDataSource.swift
//  NewsApp-SwiftUI
//
//  Created by Vijay Raj Dixit on 13/03/26.
//

import Foundation

/// Provider-specific page model returned before the repository exposes a domain HeadlinesPage.
struct ProviderHeadlinesPage {
    let articles: [Article]
    let totalResults: Int?
    let nextCursor: String?
}

/// Data-layer contract for fetching headlines from a concrete remote provider API.
protocol RemoteHeadlinesDataSource {
    func fetchTopHeadlines(
        searchText: String?,
        category: NewsCategory?,
        pageSize: Int,
        cursor: String?
    ) async throws -> ProviderHeadlinesPage
}
