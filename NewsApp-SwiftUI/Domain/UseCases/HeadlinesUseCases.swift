//
//  HeadlinesUseCases.swift
//  NewsApp-SwiftUI
//
//  Created by Vijay Raj Dixit on 13/03/26.
//

/// Executes the main headline-fetching flow against the domain repository contract.
struct FetchTopHeadlinesUseCase {
    private let repository: HeadlinesRepository

    init(repository: HeadlinesRepository) {
        self.repository = repository
    }

    func execute(_ query: HeadlinesQuery) async throws -> HeadlinesPage {
        try await repository.fetchTopHeadlines(query)
    }
}
