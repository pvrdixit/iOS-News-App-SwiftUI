//
//  NewsPaginationState.swift
//  NewsApp-SwiftUI-MVVM-Combine
//
//  Created by Vijay Raj Dixit on 26/02/26.
//


import Foundation

struct NewsPaginationState {
    private(set) var currentPage: Int = 1
    private(set) var totalResults: Int = 0 /// 0 means "unknown" until first network response
    private(set) var canLoadMore: Bool = true
    let pageSize: Int

    init(pageSize: Int) {
        self.pageSize = min(max(1, pageSize), 100)
    }

    var nextPageCandidate: Int? {
        canLoadMore ? currentPage + 1 : nil
    }

    mutating func applyFirstPage(articles incoming: [Article], totalResults: Int) -> [Article] {
        let firstPage = deduped(existing: [], incoming: incoming)
        self.totalResults = max(totalResults, firstPage.count)
        currentPage = 1
        canLoadMore = firstPage.count < self.totalResults
        return firstPage
    }

    mutating func applyNextPage(existing: [Article], incoming: [Article], totalResults: Int, nextPage: Int) -> [Article] {
        let merged = deduped(existing: existing, incoming: incoming)
        self.totalResults = max(self.totalResults, totalResults)

        /// No new unique items => stop paginating
        guard merged.count > existing.count else {
            canLoadMore = false
            return merged
        }

        currentPage = max(currentPage, nextPage)

        if self.totalResults > 0 {
            canLoadMore = merged.count < self.totalResults
        } else {
            /// totalResults unknown (e.g., after cache restore)
            canLoadMore = incoming.count >= pageSize
        }

        return merged
    }

    private func deduped(existing: [Article], incoming: [Article]) -> [Article] {
        var seenURLs = Set(existing.map(\.url))
        var merged = existing

        for article in incoming where seenURLs.insert(article.url).inserted {
            merged.append(article)
        }

        return merged
    }
}
