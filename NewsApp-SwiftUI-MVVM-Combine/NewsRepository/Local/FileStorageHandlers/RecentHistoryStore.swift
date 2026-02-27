//
//  RecentHistoryStore.swift
//  NewsApp-SwiftUI-MVVM-Combine
//
//  Created by Vijay Raj Dixit on 27/02/26.
//

import Foundation

final class RecentHistoryStore {
    private let store: JSONFileStore<[Article]>
    private let maxItems: Int

    init(maxItems: Int = 30) {
        self.maxItems = maxItems
        self.store = JSONFileStore<[Article]>(target: .recentHistory)
    }

    func load() throws -> [Article] {
        try store.load() ?? []
    }

    func save(_ articles: [Article]) throws {
        try store.save(Array(articles.prefix(maxItems)))
    }

    /// Minimal: add newest at the front and trim, Expensive insert is fine as Max is 30
    func prepend(_ article: Article) throws {
        var items = try load()
        items.insert(article, at: 0)
        if items.count > maxItems {
            items.removeLast(items.count - maxItems)
        }
        try store.save(items)
    }

    func clear() throws {
        try store.delete()
    }
}
