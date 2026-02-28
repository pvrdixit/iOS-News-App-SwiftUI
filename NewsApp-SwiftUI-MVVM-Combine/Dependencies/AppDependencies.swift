//
//  AppDependencies.swift
//  NewsApp-SwiftUI-MVVM-Combine
//
//  Created by Vijay Raj Dixit on 28/02/26.
//

import Foundation

enum AppRuntimeEnvironment {
    case development
    case production

    static var current: AppRuntimeEnvironment {
        #if DEBUG
        return .development
        #else
        return .production
        #endif
    }
}

enum LoggerServiceFactory {
    static func make(for environment: AppRuntimeEnvironment, subsystem: String = Bundle.main.bundleIdentifier ?? "NewsApp") -> LoggerService {
        switch environment {
        case .development:
            return OSLoggerService(subsystem: subsystem)
        case .production:
            return RemoteLoggerService() /// Just to define scope, not implemented
        }
    }
}

final class AppDependencies {
    /// Always available
    let logger: LoggerService

    /// Leaf dependencies (no dependencies of their own)
    lazy var bookmarks: BookmarkStore = JSONBookmarksStore()
    lazy var recentHistory: RecentHistoryStore = JSONRecentHistoryStore(maxItems: 30)
    lazy var newsCache: NewsCacheStore = JSONNewsCacheStore()

    /// Shared infrastructure
    lazy var networkService: NetworkService = HTTPUtility(timeout: 8.0)

    /// Higher-level services (depend on other services)
    lazy var newsService: NewsService = NewsResource(service: networkService)

    init(
        environment: AppRuntimeEnvironment = .current,
        logger: LoggerService? = nil
    ) {
        self.logger = logger ?? LoggerServiceFactory.make(for: environment)
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
