//
//  JSONRecentHistoryStore.swift
//  NewsApp-SwiftUI-MVVM-Combine
//
//  Created by Vijay Raj Dixit on 28/02/26.
//


import Foundation

final class JSONRecentHistoryStore: RecentHistoryStore {
    private let disk: JSONDiskStore
    private let maxItems: Int

    init(maxItems: Int = 30) {
        self.maxItems = maxItems
        self.disk = JSONDiskStore(
            fileName: "recent_history.json",
            directory: .documentDirectory
        )
    }

    /// MRU-first ordering.
    func load() throws -> [Article] {
        let items = try disk.load([Article].self) ?? []
        return Array(items.prefix(maxItems))
    }

    /// Inserts or moves-to-front (MRU) + LRU eviction.
    func touch(_ article: Article) throws {
        var mru = MRUList(items: try load(), maxItems: maxItems, key: { $0.id })
        mru.record(article)
        try disk.save(mru.items)
    }

    func clear() throws {
        try disk.delete()
    }
}
