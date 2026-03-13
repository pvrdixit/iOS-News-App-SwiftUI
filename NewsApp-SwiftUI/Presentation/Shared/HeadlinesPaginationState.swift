//
//  HeadlinesPaginationState.swift
//  NewsApp-SwiftUI-MVVM-Combine
//
//  Created by Vijay Raj Dixit on 26/02/26.
//


import Foundation

/// Tracks pagination cursors and dedupes incoming headline pages inside view models.
struct HeadlinesPaginationState {
    private(set) var totalResults: Int = 0
    private(set) var nextCursor: String?
    let pageSize: Int

    init(pageSize: Int) {
        self.pageSize = min(max(1, pageSize), 100)
    }

    var canLoadMore: Bool {
        nextCursor != nil
    }

    mutating func applyFirstPage(articles incoming: [Article], totalResults: Int?, nextCursor: String?) -> [Article] {
        let firstPage = deduped(existing: [], incoming: incoming)
        self.totalResults = max(totalResults ?? 0, firstPage.count)
        self.nextCursor = nextCursor
        return firstPage
    }

    mutating func refreshFirstPagePreservingLoaded(existing: [Article], incoming: [Article], totalResults: Int?, nextCursor: String?) -> [Article] {
        let retainedNextCursor = self.nextCursor
        let refreshedFirstPage = deduped(existing: [], incoming: incoming)
        let merged = deduped(existing: refreshedFirstPage, incoming: existing)

        self.totalResults = max(totalResults ?? 0, merged.count)

        if let totalResults, merged.count >= totalResults {
            self.nextCursor = nil
        } else if merged.count > refreshedFirstPage.count {
            self.nextCursor = retainedNextCursor
        } else {
            self.nextCursor = nextCursor
        }

        return merged
    }

    mutating func applyNextPage(existing: [Article], incoming: [Article], totalResults: Int?, nextCursor: String?) -> [Article] {
        let merged = deduped(existing: existing, incoming: incoming)
        self.totalResults = max(self.totalResults, max(totalResults ?? 0, merged.count))

        guard merged.count > existing.count else {
            self.nextCursor = nil
            return merged
        }

        if let totalResults, merged.count >= totalResults {
            self.nextCursor = nil
        } else {
            self.nextCursor = nextCursor
        }

        return merged
    }

    private func deduped(existing: [Article], incoming: [Article]) -> [Article] {
        var seenURLs = Set(existing.map(\.articleURL))
        var merged = existing

        for article in incoming where seenURLs.insert(article.articleURL).inserted {
            merged.append(article)
        }

        return merged
    }
}
