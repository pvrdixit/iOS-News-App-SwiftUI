//
//  StorageRepositories.swift
//  NewsApp-SwiftUI
//
//  Created by Vijay Raj Dixit on 13/03/26.
//

/// Domain contract for bookmark persistence and bookmark lookups.
protocol BookmarkRepository {
    func load() throws -> [Article]
    func clear() throws
    func toggle(_ article: Article) throws -> Bool
    func isBookmarked(_ articleURL: String) throws -> Bool
}

/// Domain contract for storing and reading recently viewed articles.
protocol RecentHistoryRepository {
    func load() throws -> [Article]
    func touch(_ article: Article) throws
    func clear() throws
}

/// Domain contract for persisting the latest fetched headlines page locally.
protocol NewsCacheRepository {
    func load() throws -> [Article]?
    func save(_ articles: [Article]) throws
    func clear() throws
}
