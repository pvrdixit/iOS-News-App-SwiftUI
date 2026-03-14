//
//  HeadlinesRepositoryImpl.swift
//  NewsApp-SwiftUI
//
//  Created by Vijay Raj Dixit on 13/03/26.
//

import Foundation

/// Data-layer repository that fetches headlines from the selected remote provider.
final class HeadlinesRepositoryImpl: HeadlinesRepository {
    private let providerID: String
    private let providerDisplayName: String
    private let dataSource: RemoteHeadlinesDataSource?
    private let logger: LoggerService

    init(providerID: String, providerDisplayName: String, dataSource: RemoteHeadlinesDataSource?, logger: LoggerService) {
        self.providerID = providerID
        self.providerDisplayName = providerDisplayName
        self.dataSource = dataSource
        self.logger = logger
    }

    func fetchTopHeadlines(_ query: HeadlinesQuery) async throws -> HeadlinesPage {
        guard let dataSource else {
            logger.error(
                "Selected headlines provider is not configured",
                category: .network,
                metadata: [
                    "provider": providerID
                ]
            )
            throw AppError.unconfiguredProvider(providerDisplayName)
        }

        do {
            return try await dataSource.fetchTopHeadlines(
                searchText: query.searchText,
                category: query.category,
                pageSize: query.pageSize,
                cursor: query.cursor
            )
        } catch {
            throw InfrastructureErrorMapper.mapHeadlinesError(error)
        }
    }
}
