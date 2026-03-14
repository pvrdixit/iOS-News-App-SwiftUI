//
//  HeadlinesDataSourceFactory.swift
//  NewsApp-SwiftUI
//
//  Created by Vijay Raj Dixit on 13/03/26.
//

/// Builds the concrete remote data source for the currently selected news provider.
enum HeadlinesDataSourceFactory {
    static func make(
        configuration: AppConfiguration,
        providerID: NewsProviderID,
        networkService: NetworkService
    ) -> RemoteHeadlinesDataSource? {
        switch providerID {
        case .newsAPI:
            guard let apiKey = configuration.newsAPIKey else { return nil }
            return NewsAPIHeadlinesDataSource(
                apiKey: apiKey,
                countryCode: configuration.countryCode,
                networkService: networkService
            )
        case .newsData:
            guard let apiKey = configuration.newsDataAPIKey else { return nil }
            return NewsDataHeadlinesDataSource(
                apiKey: apiKey,
                countryCode: configuration.countryCode,
                languageCode: configuration.languageCode,
                networkService: networkService
            )
        case .gNews:
            guard let apiKey = configuration.gNewsAPIKey else { return nil }
            return GNewsHeadlinesDataSource(
                apiKey: apiKey,
                countryCode: configuration.countryCode,
                languageCode: configuration.languageCode,
                networkService: networkService
            )
        }
    }
}
