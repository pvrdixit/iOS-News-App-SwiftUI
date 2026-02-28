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
        let items = (try store.load()) ?? []
        if items.count <= maxItems {
            return items
        }
        return Array(items.prefix(maxItems))
    }

    /// MRU-first + LRU eviction (maxItems)
    func touch(_ article: Article) throws {
        var recentArticles = try load()

        if let idx = recentArticles.firstIndex(where: { $0.id == article.id }) {
            recentArticles.remove(at: idx)
        }

        recentArticles.insert(article, at: 0)

        if recentArticles.count > maxItems {
            recentArticles.removeLast(recentArticles.count - maxItems)
        }

        try store.save(recentArticles)
    }

    func clear() throws {
        try store.delete()
    }
}
