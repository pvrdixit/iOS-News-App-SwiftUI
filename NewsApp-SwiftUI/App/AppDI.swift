//
//  AppDI.swift
//  NewsApp-SwiftUI
//
//  Created by Vijay Raj Dixit on 13/03/26.
//

import Foundation
import Combine
import SwiftUI

/// Central composition root that assembles infrastructure, repositories, and view models.
final class AppDI {
    private let logger: LoggerService
    private let configuration: AppConfiguration
    private let selectedNewsProvider: NewsProviderID
    private let headlinesRepository: HeadlinesRepository
    private let bookmarkRepository: BookmarkRepository
    private let recentHistoryRepository: RecentHistoryRepository
    private let newsCacheRepository: NewsCacheRepository
    private let preferenceDidChange = PassthroughSubject<Void, Never>()

    init(
        configuration: AppConfiguration = .load(),
        selectedNewsProvider: NewsProviderID = .newsAPI
    ) {
        let logger = LoggerServiceFactory.makeDefault()
        let networkService = HTTPUtility(timeout: 8.0)
        let remoteHeadlinesDataSource = HeadlinesDataSourceFactory.make(
            configuration: configuration,
            providerID: selectedNewsProvider,
            networkService: networkService
        )

        self.configuration = configuration
        self.selectedNewsProvider = selectedNewsProvider
        self.logger = logger
        self.headlinesRepository = HeadlinesRepositoryImpl(
            providerID: selectedNewsProvider.rawValue,
            providerDisplayName: selectedNewsProvider.displayName,
            dataSource: remoteHeadlinesDataSource,
            logger: logger
        )
        self.bookmarkRepository = JSONBookmarksStore()
        self.recentHistoryRepository = JSONRecentHistoryStore(maxItems: 30)
        self.newsCacheRepository = JSONNewsCacheStore()
    }

    static func preview(
        configuration: AppConfiguration = .load(),
        selectedNewsProvider: NewsProviderID = .newsAPI
    ) -> AppDI {
        AppDI(
            configuration: configuration,
            selectedNewsProvider: selectedNewsProvider
        )
    }

    @MainActor
    func makeHomeViewModel() -> HomeViewModel {
        HomeViewModel(
            headlinesRepository: headlinesRepository,
            recentHistoryRepository: recentHistoryRepository,
            newsCacheRepository: newsCacheRepository,
            preferenceDidChange: preferenceDidChange.eraseToAnyPublisher(),
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
        let selectedCountryCode = selectedNewsProvider == .newsData
            ? NewsDataPreferences.countryCode(default: configuration.countryCode)
            : configuration.countryCode
        let selectedLanguageCode = selectedNewsProvider == .newsData
            ? NewsDataPreferences.languageCode(default: configuration.languageCode)
            : configuration.languageCode

        return SettingsViewModel(
            newsCacheRepository: newsCacheRepository,
            bookmarkRepository: bookmarkRepository,
            recentHistoryRepository: recentHistoryRepository,
            allowsRegionAndLanguageChanges: selectedNewsProvider == .newsData,
            selectedCountryCode: selectedCountryCode,
            selectedLanguageCode: selectedLanguageCode,
            countryOptions: Country.allCases
                .map { SelectListItem(id: $0.rawValue, title: $0.displayName) }
                .sorted { $0.title < $1.title },
            languageOptions: Language.allCases
                .map { SelectListItem(id: $0.rawValue, title: $0.displayName) }
                .sorted { $0.title < $1.title },
            saveCountryCode: { NewsDataPreferences.setCountryCode($0) },
            saveLanguageCode: { NewsDataPreferences.setLanguageCode($0) },
            notifyPreferenceChanged: { self.preferenceDidChange.send(()) },
            logger: logger
        )
    }

    @MainActor
    func makeExploreViewModel() -> ExploreViewModel {
        ExploreViewModel(
            headlinesRepository: headlinesRepository,
            recentHistoryRepository: recentHistoryRepository,
            availableCategories: ExploreCategoriesProvider.categories(for: selectedNewsProvider),
            preferenceDidChange: preferenceDidChange.eraseToAnyPublisher(),
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

/// Selects the logging backend from the active build configuration.
private enum LoggerServiceFactory {
    static func makeDefault(
        subsystem: String = Bundle.main.bundleIdentifier ?? "NewsApp"
    ) -> LoggerService {
        #if DEBUG
        return OSLoggerService(subsystem: subsystem)
        #else
        return RemoteLoggerService()
        #endif
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
