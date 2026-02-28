//
//  NewsViewModel.swift
//  NewsApp-SwiftUI-MVVM-Combine
//
//  Created by Vijay Raj Dixit on 29/01/26.
//

import SwiftUI
import Combine

enum LoadingState {
    case isLoading
    case isRefreshing
    case idle
}

@MainActor
final class NewsViewModel: ObservableObject {
    @Published private(set) var articles: [Article] = []
    @Published private(set) var loadingState: LoadingState = .idle
    @Published var alertMessage: String? = nil

    private let newsService: NewsService
    private let recentHistory: RecentHistoryStore
    private let newsCache: NewsCacheStore
    private let logger: LoggerService
    private var paginationState = NewsPaginationState(pageSize: 5)
    private let loadMoreThreshold = 1
    private var hasLoadedFirstPageFromNetwork = false

    init(
        newsService: NewsService,
        recentHistory: RecentHistoryStore,
        newsCache: NewsCacheStore,
        logger: LoggerService
    ) {
        self.newsService = newsService
        self.recentHistory = recentHistory
        self.newsCache = newsCache
        self.logger = logger
    }

    /// Fetch articles
    func fetchNews(_ state: LoadingState = .isLoading) async {
        await fetchPage(page: 1, isFirstPage: true, state)
    }

    /// Pagination trigger
    func loadMoreIfNeeded(currentItem: Article) async {
        guard hasLoadedFirstPageFromNetwork,
              shouldLoadMore(after: currentItem),
              let nextPage = paginationState.nextPageCandidate
        else { return }

        await fetchPage(page: nextPage, isFirstPage: false)
    }
    
    /// Store recent history
    func saveRecentlyViewed(_ article: Article) {
        do {
            try recentHistory.touch(article)
        } catch {
            logStorageError("Recent save failed", category: .recent, error: error)
        }
    }

    func dismissError() {
        alertMessage = nil
    }
}

/// Private Helpers
/// Fetch flow and network error handling
private extension NewsViewModel {
    func fetchPage(page: Int, isFirstPage: Bool, _ state: LoadingState = .isLoading) async {
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
        }

        do {
            let headlines = try await newsService.fetchTopHeadlines(page: page, pageSize: paginationState.pageSize)
            applyFetchedHeadlines(headlines, page: page, isFirstPage: isFirstPage)
        } catch {
            deferredAlertMessage = resolveFetchError(error, page: page, isFirstPage: isFirstPage)
        }
    }

    func applyFetchedHeadlines(_ headlines: Headlines, page: Int, isFirstPage: Bool) {
        if isFirstPage {
            if !shouldKeepExistingArticles(onFirstPageResponse: headlines.articles) {
                articles = paginationState.applyFirstPage(
                    articles: headlines.articles,
                    totalResults: headlines.totalResults
                )
            }
            hasLoadedFirstPageFromNetwork = true
        } else {
            articles = paginationState.applyNextPage(
                existing: articles,
                incoming: headlines.articles,
                totalResults: headlines.totalResults,
                nextPage: page
            )
        }

        saveToCache(articles: articles)
    }
}

/// Pagination helpers
private extension NewsViewModel {
    func shouldLoadMore(after article: Article) -> Bool {
        guard loadingState == .idle, paginationState.canLoadMore else { return false }
        guard let index = articles.firstIndex(where: { $0.id == article.id }) else { return false }

        let triggerIndex = max(articles.count - loadMoreThreshold, 0)
        return index >= triggerIndex
    }

    func shouldKeepExistingArticles(onFirstPageResponse incoming: [Article]) -> Bool {
        guard !articles.isEmpty, !incoming.isEmpty else { return false }

        if articles.first?.id == incoming.first?.id {
            return true
        }

        let existingTopFive = Array(articles.prefix(5)).map(\.id)
        let incomingTopFive = Array(incoming.prefix(5)).map(\.id)
        guard existingTopFive.count == 5, incomingTopFive.count == 5 else {
            return false
        }

        return existingTopFive == incomingTopFive
    }
}

/// ResolveError -> Log + UI error mapping helper
private extension NewsViewModel {
    func resolveFetchError(_ error: Error, page: Int, isFirstPage: Bool) -> String? {
        if error is CancellationError { return nil }
        if let urlError = error as? URLError, urlError.code == .cancelled { return nil }

        if isFirstPage, articles.isEmpty, let cachedArticles = loadFromCacheIfAvailable() {
            articles = cachedArticles
            logger.warning(
                "First-page fetch failed, showing cached headlines",
                category: .cache,
                metadata: [
                    "page": "\(page)",
                    "cachedCount": "\(cachedArticles.count)",
                    "error": error.localizedDescription
                ]
            )
            return nil
        }

        var metadata: [String: String] = [
            "page": "\(page)",
            "error": error.localizedDescription
        ]
        if let decodingMetadata = NetworkLogger.metadata(for: error) {
            metadata.merge(decodingMetadata, uniquingKeysWith: { current, _ in current })
        }

        logger.error(
            "Failed to fetch headlines",
            category: .network,
            metadata: metadata
        )

        return processErrorForUI(from: error)
    }
    
    func processErrorForUI(from error: Error) -> String {
        NetworkErrorMapper.message(from: error, viewType: .newsView)
    }
}


/// Cache and storage helpers
private extension NewsViewModel {
    func loadFromCacheIfAvailable() -> [Article]? {
        do {
            return try newsCache.load()
        } catch {
            logStorageError("Cache load failed", category: .cache, error: error)
            return nil
        }
    }

    func saveToCache(articles: [Article]) {
        do {
            try newsCache.save(articles: articles)
        } catch {
            logStorageError("Cache save failed", category: .cache, error: error)
        }
    }

    func logStorageError(_ message: String, category: LogCategory, error: Error) {
        logger.error(
            message,
            category: category,
            metadata: [
                "error": error.localizedDescription
            ]
        )
    }
}
