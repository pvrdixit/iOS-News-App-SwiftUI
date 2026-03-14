//
//  Headlines.swift
//  NewsApp-SwiftUI
//
//  Created by Vijay Raj Dixit on 13/03/26.
//

import Foundation

/// Domain request model for fetching a page of headlines.
struct HeadlinesQuery {
    let searchText: String?
    let category: String?
    let pageSize: Int
    let cursor: String?
}

/// Domain response model returned after fetching one page of headlines.
struct HeadlinesPage {
    let articles: [Article]
    let totalResults: Int?
    let nextCursor: String?
}

/// Domain contract for any source capable of fetching paginated headline results.
protocol HeadlinesRepository {
    func fetchTopHeadlines(_ query: HeadlinesQuery) async throws -> HeadlinesPage
}
