//
//  ExploreViewModel.swift
//  NewsApp-SwiftUI-MVVM-Combine
//
//  Created by Vijay Raj Dixit on 02/03/26.
//

import Foundation
import Combine

@MainActor
/// Presentation state container for category-based exploration, search, and pagination.
final class ExploreViewModel: ObservableObject {
    let navigationTitle = "Explore"
    let searchPrompt = "Search news"
    let retryButtonTitle = "Retry"
    let cancelButtonTitle = "Cancel"
    private let defaultErrorMessage = "Unable to explore news, please try again"
    private let defaultEmptyStateTitle = "No news available"
    private let defaultEmptyStateMessage = "Try a different category."
    private let filteredEmptyStateTitle = "No results"
    private let filteredEmptyStateMessage = "Try a different search or category."

    let availableCategories: [ExploreCategory]
    @Published var search: String = ""
    @Published var selectedCategory: ExploreCategory
    @Published private(set) var articles: [Article] = []
    @Published private(set) var isLoading: Bool = false
    @Published var alertMessage: String? = nil

    private let headlinesRepository: HeadlinesRepository
    private let recentHistoryRepository: RecentHistoryRepository
    private let logger: LoggerService
    private var paginationState = HeadlinesPaginationState(pageSize: 10)
    private let loadMoreThreshold = 1
    private var hasLoadedFirstPageFromNetwork = false
    private var isClearingSearchForCategoryChange = false

    var shouldShowEmptyState: Bool {
        !isLoading && articles.isEmpty
    }

    var emptyStateTitle: String {
        hasActiveSearch ? filteredEmptyStateTitle : defaultEmptyStateTitle
    }

    var emptyStateMessage: String {
        hasActiveSearch ? filteredEmptyStateMessage : defaultEmptyStateMessage
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

    private var hasActiveSearch: Bool {
        normalizedSearch != nil
    }

    init(
        headlinesRepository: HeadlinesRepository,
        recentHistoryRepository: RecentHistoryRepository,
        availableCategories: [ExploreCategory],
        logger: LoggerService
    ) {
        let resolvedCategories = availableCategories.isEmpty ? [.general] : availableCategories

        self.headlinesRepository = headlinesRepository
        self.recentHistoryRepository = recentHistoryRepository
        self.availableCategories = resolvedCategories
        self.selectedCategory = resolvedCategories.first ?? .general
        self.logger = logger
    }

    func refresh() async {
        await fetchPage(cursor: nil, isFirstPage: true)
    }

    func loadMoreIfNeeded(currentItem: Article) async {
        guard hasLoadedFirstPageFromNetwork,
              shouldLoadMore(after: currentItem),
              let nextCursor = paginationState.nextCursor
        else { return }

        await fetchPage(cursor: nextCursor, isFirstPage: false)
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
        if isClearingSearchForCategoryChange {
            isClearingSearchForCategoryChange = false
            return false
        }

        let oldTrimmed = oldValue.trimmingCharacters(in: .whitespacesAndNewlines)
        let newTrimmed = newValue.trimmingCharacters(in: .whitespacesAndNewlines)
        return !oldTrimmed.isEmpty && newTrimmed.isEmpty
    }

    func didChangeCategory(from oldValue: ExploreCategory, to newValue: ExploreCategory) -> Bool {
        guard oldValue != newValue else { return false }

        if normalizedSearch != nil {
            isClearingSearchForCategoryChange = true
            search = ""
        }

        return true
    }
    
    /// Store recent history
    func saveRecentlyViewed(_ article: Article) {
        do {
            try recentHistoryRepository.touch(article)
        } catch {
            logger.warning(
                "Recent save failed",
                category: .recent,
                metadata: [
                    "articleURL": article.articleURL,
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
    
    func fetchPage(cursor: String?, isFirstPage: Bool) async {
        guard !isLoading else { return }

        isLoading = true
        if isFirstPage {
            alertMessage = nil
        }

        defer { isLoading = false }

        do {
            let headlinesPage = try await headlinesRepository.fetchTopHeadlines(
                HeadlinesQuery(
                    searchText: normalizedSearch,
                    category: selectedCategory.domainValue,
                    pageSize: paginationState.pageSize,
                    cursor: cursor
                )
            )
            if isFirstPage {
                articles = paginationState.applyFirstPage(
                    articles: headlinesPage.articles,
                    totalResults: headlinesPage.totalResults,
                    nextCursor: headlinesPage.nextCursor
                )
                hasLoadedFirstPageFromNetwork = true
            } else {
                articles = paginationState.applyNextPage(
                    existing: articles,
                    incoming: headlinesPage.articles,
                    totalResults: headlinesPage.totalResults,
                    nextCursor: headlinesPage.nextCursor
                )
            }
        } catch {
            logger.error(
                "Explore fetch failed",
                category: .network,
                metadata: [
                    "category": selectedCategory.rawValue,
                    "search": normalizedSearch ?? "",
                    "cursor": cursor ?? "first",
                    "error": error.localizedDescription
                ]
            )
            alertMessage = AppErrorMapper.message(from: error, viewType: .newsView)
        }
    }

    func shouldLoadMore(after article: Article) -> Bool {
        guard !isLoading, paginationState.canLoadMore else { return false }
        guard let index = articles.firstIndex(where: { $0.id == article.id }) else { return false }

        let triggerIndex = max(articles.count - loadMoreThreshold, 0)
        return index >= triggerIndex
    }
}
