//
//  RemoteHeadlinesDataSource.swift
//  NewsApp-SwiftUI
//
//  Created by Vijay Raj Dixit on 13/03/26.
//

import Foundation

/// Data-layer contract for fetching headlines from a concrete remote provider API.
protocol RemoteHeadlinesDataSource {
    func fetchTopHeadlines(
        searchText: String?,
        category: NewsCategory?,
        pageSize: Int,
        cursor: String?
    ) async throws -> HeadlinesPage
}
