//
//  AppDI.swift
//  NewsApp-SwiftUI
//
//  Created by Vijay Raj Dixit on 13/03/26.
//

import Foundation
import SwiftUI

/// Describes the runtime environment so infrastructure can swap implementations safely.
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

/// Holds optional dependency overrides used by previews and tests.
struct AppDIOverrides {
    var logger: LoggerService?
    var networkService: NetworkService?
    var remoteHeadlinesDataSource: RemoteHeadlinesDataSource?
    var headlinesRepository: HeadlinesRepository?
    var bookmarkRepository: BookmarkRepository?
    var recentHistoryRepository: RecentHistoryRepository?
    var newsCacheRepository: NewsCacheRepository?

    static let none = AppDIOverrides()
}

/// Central composition root that assembles infrastructure, repositories, use cases, and view models.
final class AppDI {
    let logger: LoggerService
    let configuration: AppConfiguration
    let selectedNewsProvider: NewsProviderID
    private let overrides: AppDIOverrides

    lazy var networkService: NetworkService = overrides.networkService ?? HTTPUtility(timeout: 8.0)
    lazy var remoteHeadlinesDataSource: RemoteHeadlinesDataSource? = overrides.remoteHeadlinesDataSource ?? HeadlinesDataSourceFactory.make(
        configuration: configuration,
        providerID: selectedNewsProvider,
        networkService: networkService
    )

    lazy var headlinesRepository: HeadlinesRepository = overrides.headlinesRepository ?? HeadlinesRepositoryImpl(
        providerID: selectedNewsProvider.rawValue,
        providerDisplayName: selectedNewsProvider.displayName,
        dataSource: remoteHeadlinesDataSource,
        logger: logger
    )
    lazy var bookmarkRepository: BookmarkRepository = overrides.bookmarkRepository ?? JSONBookmarksStore()
    lazy var recentHistoryRepository: RecentHistoryRepository = overrides.recentHistoryRepository ?? JSONRecentHistoryStore(maxItems: 30)
    lazy var newsCacheRepository: NewsCacheRepository = overrides.newsCacheRepository ?? JSONNewsCacheStore()

    lazy var fetchTopHeadlinesUseCase = FetchTopHeadlinesUseCase(repository: headlinesRepository)

    init(
        environment: AppRuntimeEnvironment = .current,
        configuration: AppConfiguration = .load(),
        selectedNewsProvider: NewsProviderID = .newsAPI,
        overrides: AppDIOverrides = .none
    ) {
        self.configuration = configuration
        self.selectedNewsProvider = selectedNewsProvider
        self.overrides = overrides
        self.logger = overrides.logger ?? LoggerServiceFactory.make(for: environment)
    }

    static func live(
        environment: AppRuntimeEnvironment = .current,
        configuration: AppConfiguration = .load(),
        selectedNewsProvider: NewsProviderID = .newsAPI,
        overrides: AppDIOverrides = .none
    ) -> AppDI {
        AppDI(
            environment: environment,
            configuration: configuration,
            selectedNewsProvider: selectedNewsProvider,
            overrides: overrides
        )
    }

    static func preview(
        configuration: AppConfiguration = .load(),
        selectedNewsProvider: NewsProviderID = .newsAPI,
        overrides: AppDIOverrides = .none
    ) -> AppDI {
        AppDI(
            environment: .development,
            configuration: configuration,
            selectedNewsProvider: selectedNewsProvider,
            overrides: overrides
        )
    }

    @MainActor
    func makeHomeViewModel() -> HomeViewModel {
        HomeViewModel(
            fetchTopHeadlines: fetchTopHeadlinesUseCase,
            recentHistoryRepository: recentHistoryRepository,
            newsCacheRepository: newsCacheRepository,
            logger: logger
        )
    }

    @MainActor
    func makeBookmarksViewModel() -> BookmarksViewModel {
        BookmarksViewModel(
            bookmarkRepository: bookmarkRepository,
            recentHistoryRepository: recentHistoryRepository,
            logger: logger
        )
    }

    @MainActor
    func makeSettingsViewModel() -> SettingsViewModel {
        SettingsViewModel(
            newsCacheRepository: newsCacheRepository,
            bookmarkRepository: bookmarkRepository,
            recentHistoryRepository: recentHistoryRepository,
            regionCode: configuration.countryCode.uppercased(),
            logger: logger
        )
    }

    @MainActor
    func makeExploreViewModel() -> ExploreViewModel {
        ExploreViewModel(
            fetchTopHeadlines: fetchTopHeadlinesUseCase,
            recentHistoryRepository: recentHistoryRepository,
            availableCategories: ExploreCategoriesProvider.categories(for: selectedNewsProvider),
            logger: logger
        )
    }

    @MainActor
    func makeNewsDetailViewModel(article: Article) -> NewsDetailViewModel {
        NewsDetailViewModel(
            article: article,
            bookmarkRepository: bookmarkRepository,
            logger: logger
        )
    }
}

/// Selects the logging backend based on the current runtime environment.
private enum LoggerServiceFactory {
    static func make(
        for environment: AppRuntimeEnvironment,
        subsystem: String = Bundle.main.bundleIdentifier ?? "NewsApp"
    ) -> LoggerService {
        switch environment {
        case .development:
            return OSLoggerService(subsystem: subsystem)
        case .production:
            return RemoteLoggerService()
        }
    }
}

/// Exposes the dependency container through SwiftUI environment values.
private struct AppDIKey: EnvironmentKey {
    static let defaultValue: AppDI = .preview()
}

extension EnvironmentValues {
    var appDI: AppDI {
        get { self[AppDIKey.self] }
        set { self[AppDIKey.self] = newValue }
    }
}
