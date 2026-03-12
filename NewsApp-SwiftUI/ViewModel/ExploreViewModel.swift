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
    let navigationTitle = "Explore"
    let searchPrompt = "Search news"
    let retryButtonTitle = "Retry"
    let cancelButtonTitle = "Cancel"
    private let defaultErrorMessage = "Unable to explore news, please try again"
    private let defaultEmptyStateTitle = "Search or pick a category"
    private let defaultEmptyStateMessage = "Use the search bar or choose a category to explore."
    private let filteredEmptyStateTitle = "No results"
    private let filteredEmptyStateMessage = "Try a different search or category."

    @Published var search: String = ""
    @Published var selectedCategory: ExploreCategory = .all
    @Published private(set) var articles: [Article] = []
    @Published private(set) var isLoading: Bool = false
    @Published var alertMessage: String? = nil

    private let newsResource: NewsResource
    private let recentHistory: RecentHistoryStore
    private let logger: LoggerService
    private var paginationState = NewsPaginationState(pageSize: 10)
    private let loadMoreThreshold = 1
    private var hasLoadedFirstPageFromNetwork = false

    var shouldShowEmptyState: Bool {
        !isLoading && articles.isEmpty
    }

    var emptyStateTitle: String {
        hasActiveFilters ? filteredEmptyStateTitle : defaultEmptyStateTitle
    }

    var emptyStateMessage: String {
        hasActiveFilters ? filteredEmptyStateMessage : defaultEmptyStateMessage
    }

    var errorMessageToDisplay: String {
        alertMessage ?? defaultErrorMessage
    }

    var isErrorPresented: Bool {
        alertMessage != nil
    }

    var shouldRefreshOnAppear: Bool {
        articles.isEmpty
    }

    private var hasActiveFilters: Bool {
        let trimmedSearch = search.trimmingCharacters(in: .whitespacesAndNewlines)
        return !trimmedSearch.isEmpty || selectedCategory != .all
    }

    init(
        newsResource: NewsResource,
        recentHistory: RecentHistoryStore,
        logger: LoggerService
    ) {
        self.newsResource = newsResource
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

    func setErrorPresented(_ isPresented: Bool) {
        if !isPresented {
            dismissError()
        }
    }

    func shouldRefreshOnSearchChange(from oldValue: String, to newValue: String) -> Bool {
        let oldTrimmed = oldValue.trimmingCharacters(in: .whitespacesAndNewlines)
        let newTrimmed = newValue.trimmingCharacters(in: .whitespacesAndNewlines)
        return !oldTrimmed.isEmpty && newTrimmed.isEmpty
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
            let articlePage = try await newsResource.fetchTopHeadlines(
                search: normalizedSearch,
                category: selectedCategory.apiValue,
                page: page,
                pageSize: paginationState.pageSize
            )
            if isFirstPage {
                articles = paginationState.applyFirstPage(
                    articles: articlePage.articles,
                    totalResults: articlePage.totalResults
                )
                hasLoadedFirstPageFromNetwork = true
            } else {
                articles = paginationState.applyNextPage(
                    existing: articles,
                    incoming: articlePage.articles,
                    totalResults: articlePage.totalResults,
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
