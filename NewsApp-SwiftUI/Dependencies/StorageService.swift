//
//  StorageService.swift
//  NewsApp-SwiftUI-MVVM-Combine
//
//  Created by Vijay Raj Dixit on 28/02/26.
//

protocol RecentHistoryStore {
    /// Returns most-recent-first.
    func load() throws -> [Article]

    /// Inserts if missing; otherwise moves the item to the front (MRU).
    /// Enforces maxItems by evicting least-recent items.
    func touch(_ article: Article) throws

    func clear() throws
}

protocol BookmarkStore {
    func load() throws -> [Article]
    func save(_ articles: [Article]) throws
    func clear() throws
    func toggle(_ article: Article) throws -> Bool
    func isBookmarked(_ url: String) -> Bool
}

protocol NewsCacheStore {
    func load() throws -> [Article]?
    func save(articles: [Article]) throws
    func clear() throws
}
