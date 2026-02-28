//
//  AppDependencies.swift
//  NewsApp-SwiftUI-MVVM-Combine
//
//  Created by Vijay Raj Dixit on 28/02/26.
//

import Foundation

final class AppDependencies {
    /// Always available
    let logger: LoggerService

    /// Leaf dependencies (no dependencies of their own)
    lazy var bookmarks: BookmarkStore = JSONBookmarksStore()
    lazy var recentHistory: RecentHistoryStore = JSONRecentHistoryStore(maxItems: 30)
    lazy var newsCache: NewsCacheStore = JSONNewsCacheStore()

    /// Shared infrastructure (depends on logger)
    lazy var networkService: NetworkService = HTTPUtility(timeout: 8.0, logger: logger)

    /// Higher-level services (depend on other services)
    lazy var newsService: NewsService = NewsResource(service: networkService, logger: logger)

    init(
        logger: LoggerService = OSLoggerService(
            subsystem: Bundle.main.bundleIdentifier ?? "NewsApp",
            category: .default
        )
    ) {
        self.logger = logger
    }

    @MainActor
    func makeNewsViewModel() -> NewsViewModel {
        NewsViewModel(
            newsService: newsService,
            recentHistory: recentHistory,
            newsCache: newsCache,
            logger: logger
        )
    }

    @MainActor
    func makeBookmarksViewModel() -> BookmarksViewModel {
        BookmarksViewModel(
            recentHistory: recentHistory,
            bookmarks: bookmarks,
            logger: logger
        )
    }

    @MainActor
    func makeNewsDetailViewModel(article: Article) -> NewsDetailViewModel {
        NewsDetailViewModel(
            article: article,
            bookmarksStore: bookmarks,
            logger: logger
        )
    }
}
