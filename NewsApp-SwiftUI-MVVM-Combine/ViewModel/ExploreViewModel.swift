//
//  ExploreViewModel.swift
//  NewsApp-SwiftUI-MVVM-Combine
//
//  Created by Vijay Raj Dixit on 02/03/26.
//

import Foundation
import Combine

@MainActor
final class ExploreViewModel: ObservableObject {
    @Published var search: String = ""
    @Published var selectedCategory: ExploreCategory = .all
    @Published private(set) var articles: [Article] = []
    @Published private(set) var isLoading: Bool = false
    @Published var alertMessage: String? = nil

    private let newsService: NewsService
    private let recentHistory: RecentHistoryStore
    private let logger: LoggerService
    private var paginationState = NewsPaginationState(pageSize: 10)
    private let loadMoreThreshold = 1
    private var hasLoadedFirstPageFromNetwork = false

    init(
        newsService: NewsService,
        recentHistory: RecentHistoryStore,
        logger: LoggerService
    ) {
        self.newsService = newsService
        self.recentHistory = recentHistory
        self.logger = logger
    }

    func refresh() async {
        await fetchPage(page: 1, isFirstPage: true)
    }

    func loadMoreIfNeeded(currentItem: Article) async {
        guard hasLoadedFirstPageFromNetwork,
              shouldLoadMore(after: currentItem),
              let nextPage = paginationState.nextPageCandidate
        else { return }

        await fetchPage(page: nextPage, isFirstPage: false)
    }

    func dismissError() {
        alertMessage = nil
    }
    
    /// Store recent history
    func saveRecentlyViewed(_ article: Article) {
        do {
            try recentHistory.touch(article)
        } catch {
            logger.error(
                "Recent save failed",
                category: .recent,
                metadata: [
                    "error": error.localizedDescription
                ]
            )
        }
    }
}

private extension ExploreViewModel {
    var normalizedSearch: String? {
        let trimmed = search.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }
    
    func fetchPage(page: Int, isFirstPage: Bool) async {
        guard !isLoading else { return }

        isLoading = true
        if isFirstPage {
            alertMessage = nil
        }

        defer { isLoading = false }

        do {
            let headlines = try await newsService.fetchTopHeadlines(
                search: normalizedSearch,
                category: selectedCategory.apiValue,
                page: page,
                pageSize: paginationState.pageSize
            )
            if isFirstPage {
                articles = paginationState.applyFirstPage(
                    articles: headlines.articles,
                    totalResults: headlines.totalResults
                )
                hasLoadedFirstPageFromNetwork = true
            } else {
                articles = paginationState.applyNextPage(
                    existing: articles,
                    incoming: headlines.articles,
                    totalResults: headlines.totalResults,
                    nextPage: page
                )
            }
        } catch {
            alertMessage = NetworkErrorMapper.message(from: error, viewType: .newsView)
        }
    }

    func shouldLoadMore(after article: Article) -> Bool {
        guard !isLoading, paginationState.canLoadMore else { return false }
        guard let index = articles.firstIndex(where: { $0.id == article.id }) else { return false }

        let triggerIndex = max(articles.count - loadMoreThreshold, 0)
        return index >= triggerIndex
    }
}
