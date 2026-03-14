//
//  HomeViewModel.swift
//  NewsApp-SwiftUI-MVVM-Combine
//
//  Created by Vijay Raj Dixit on 29/01/26.
//

import Foundation
import Combine

/// Describes the loading mode so the home screen can render loading and refresh states correctly.
enum LoadingState {
    case isLoading
    case isRefreshing
    case idle
}

@MainActor
/// Presentation state container for the home feed, pagination, cache fallback, and recent-history writes.
final class HomeViewModel: ObservableObject {
    let navigationTitle = "News"
    let retryButtonTitle = "Retry"
    let cancelButtonTitle = "Cancel"
    let emptyStateRetryButtonTitle = "Try again"
    private let defaultErrorMessage = "Unable to fetch news, please try again"
    private let defaultEmptyStateTitle = "No news available"
    private let failedEmptyStateTitle = "Couldn't load news"
    private let defaultEmptyStateMessage = "No articles are available right now. Please try again."

    @Published private(set) var articles: [Article] = []
    @Published private(set) var loadingState: LoadingState = .idle
    @Published var alertMessage: String? = nil

    private let headlinesRepository: HeadlinesRepository
    private let recentHistoryRepository: RecentHistoryRepository
    private let newsCacheRepository: NewsCacheRepository
    private let logger: LoggerService
    private var paginationState = HeadlinesPaginationState(pageSize: 5)
    private let loadMoreThreshold = 1
    private var hasLoadedFirstPageFromNetwork = false
    private var pendingPreferenceRefresh = false
    private var cancellables = Set<AnyCancellable>()

    var shouldShowLoadingOverlay: Bool {
        loadingState == .isLoading
    }

    var shouldShowEmptyState: Bool {
        articles.isEmpty && loadingState == .idle
    }

    var emptyStateTitle: String {
        alertMessage == nil ? defaultEmptyStateTitle : failedEmptyStateTitle
    }

    var emptyStateMessage: String {
        alertMessage ?? defaultEmptyStateMessage
    }

    var errorMessageToDisplay: String {
        alertMessage ?? defaultErrorMessage
    }

    var isErrorPresented: Bool {
        alertMessage != nil && !shouldShowEmptyState
    }

    var shouldFetchOnAppear: Bool {
        articles.isEmpty
    }

    init(
        headlinesRepository: HeadlinesRepository,
        recentHistoryRepository: RecentHistoryRepository,
        newsCacheRepository: NewsCacheRepository,
        preferenceDidChange: AnyPublisher<Void, Never>,
        logger: LoggerService
    ) {
        self.headlinesRepository = headlinesRepository
        self.recentHistoryRepository = recentHistoryRepository
        self.newsCacheRepository = newsCacheRepository
        self.logger = logger
        observePreferenceChanges(preferenceDidChange)
    }

    /// Fetch articles
    func fetchNews(_ state: LoadingState = .isLoading) async {
        await fetchPage(cursor: nil, isFirstPage: true, state)
    }

    /// Pagination trigger
    func loadMoreIfNeeded(currentItem: Article) async {
        guard hasLoadedFirstPageFromNetwork,
              shouldLoadMore(after: currentItem),
              let nextCursor = paginationState.nextCursor
        else { return }

        await fetchPage(cursor: nextCursor, isFirstPage: false)
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

    func dismissError() {
        alertMessage = nil
    }

    func setErrorPresented(_ isPresented: Bool) {
        if !isPresented {
            dismissError()
        }
    }
}

/// Private Helpers
/// Fetch flow and network error handling
private extension HomeViewModel {
    func observePreferenceChanges(_ preferenceDidChange: AnyPublisher<Void, Never>) {
        preferenceDidChange
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                Task { @MainActor [weak self] in
                    await self?.reloadForPreferenceChange()
                }
            }
            .store(in: &cancellables)
    }

    func reloadForPreferenceChange() async {
        guard loadingState == .idle else {
            pendingPreferenceRefresh = true
            return
        }

        logger.info("Refreshing home feed after region/language change", category: .cache)
        paginationState = HeadlinesPaginationState(pageSize: paginationState.pageSize)
        hasLoadedFirstPageFromNetwork = false
        articles = []
        alertMessage = nil
        await fetchNews()
    }

    func fetchPage(cursor: String?, isFirstPage: Bool, _ state: LoadingState = .isLoading) async {
        guard loadingState == .idle else { return }

        loadingState = state
        var deferredAlertMessage: String?

        if isFirstPage {
            alertMessage = nil
        }

        defer {
            loadingState = .idle
            if let deferredAlertMessage {
                alertMessage = deferredAlertMessage
            }
            schedulePendingPreferenceRefreshIfNeeded()
        }

        do {
            let headlinesPage = try await headlinesRepository.fetchTopHeadlines(
                HeadlinesQuery(
                    searchText: nil,
                    category: nil,
                    pageSize: paginationState.pageSize,
                    cursor: cursor
                )
            )
            applyFetchedPage(headlinesPage, isFirstPage: isFirstPage)
        } catch {
            deferredAlertMessage = resolveFetchError(error, cursor: cursor, isFirstPage: isFirstPage)
        }
    }

    func applyFetchedPage(_ headlinesPage: HeadlinesPage, isFirstPage: Bool) {
        if isFirstPage {
            if shouldPreserveLoadedArticles(
                afterRefreshingWith: headlinesPage.articles,
                incomingNextCursor: headlinesPage.nextCursor
            ) {
                articles = paginationState.refreshFirstPagePreservingLoaded(
                    existing: articles,
                    incoming: headlinesPage.articles,
                    totalResults: headlinesPage.totalResults,
                    nextCursor: headlinesPage.nextCursor
                )
            } else {
                articles = paginationState.applyFirstPage(
                    articles: headlinesPage.articles,
                    totalResults: headlinesPage.totalResults,
                    nextCursor: headlinesPage.nextCursor
                )
            }
            hasLoadedFirstPageFromNetwork = true
        } else {
            articles = paginationState.applyNextPage(
                existing: articles,
                incoming: headlinesPage.articles,
                totalResults: headlinesPage.totalResults,
                nextCursor: headlinesPage.nextCursor
            )
        }

        saveToCache(articles: articles)
    }

    func schedulePendingPreferenceRefreshIfNeeded() {
        guard pendingPreferenceRefresh else { return }

        pendingPreferenceRefresh = false
        Task { @MainActor [weak self] in
            await self?.reloadForPreferenceChange()
        }
    }
}

/// Pagination helpers
private extension HomeViewModel {
    func shouldLoadMore(after article: Article) -> Bool {
        guard loadingState == .idle, paginationState.canLoadMore else { return false }
        guard let index = articles.firstIndex(where: { $0.id == article.id }) else { return false }

        let triggerIndex = max(articles.count - loadMoreThreshold, 0)
        return index >= triggerIndex
    }

    func shouldPreserveLoadedArticles(afterRefreshingWith incoming: [Article], incomingNextCursor: String?) -> Bool {
        guard !articles.isEmpty, !incoming.isEmpty else { return false }

        let comparisonCount = min(paginationState.pageSize, articles.count, incoming.count)
        guard comparisonCount > 0 else { return false }

        let existingFirstPage = Array(articles.prefix(comparisonCount)).map(\.id)
        let incomingFirstPage = Array(incoming.prefix(comparisonCount)).map(\.id)

        return existingFirstPage == incomingFirstPage
    }
}

/// ResolveError -> Log + UI error mapping helper
private extension HomeViewModel {
    func resolveFetchError(_ error: Error, cursor: String?, isFirstPage: Bool) -> String? {
        if error is CancellationError { return nil }
        if let urlError = error as? URLError, urlError.code == .cancelled { return nil }

        if isFirstPage, articles.isEmpty, let cachedArticles = loadFromCacheIfAvailable() {
            articles = cachedArticles
            logger.warning(
                "First-page fetch failed, showing cached headlines",
                category: .cache,
                metadata: [
                    "cursor": cursor ?? "first",
                    "cachedCount": "\(cachedArticles.count)",
                    "error": error.localizedDescription
                ]
            )
            return nil
        }

        let metadata: [String: String] = [
            "cursor": cursor ?? "first",
            "error": error.localizedDescription
        ]

        logger.error(
            "Failed to fetch headlines",
            category: .network,
            metadata: metadata
        )

        return processErrorForUI(from: error)
    }
    
    func processErrorForUI(from error: Error) -> String {
        AppErrorMapper.message(from: error, viewType: .newsView)
    }
}


/// Cache and storage helpers
private extension HomeViewModel {
    func loadFromCacheIfAvailable() -> [Article]? {
        do {
            return try newsCacheRepository.load()
        } catch {
            logStorageWarning("Cache load failed", category: .cache, error: error)
            return nil
        }
    }

    func saveToCache(articles: [Article]) {
        do {
            try newsCacheRepository.save(articles)
        } catch {
            logStorageWarning("Cache save failed", category: .cache, error: error)
        }
    }

    func logStorageWarning(_ message: String, category: LogCategory, error: Error) {
        logger.warning(
            message,
            category: category,
            metadata: [
                "error": error.localizedDescription
            ]
        )
    }
}
