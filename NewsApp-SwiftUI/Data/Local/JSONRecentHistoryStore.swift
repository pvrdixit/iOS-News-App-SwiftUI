//
//  JSONRecentHistoryStore.swift
//  NewsApp-SwiftUI-MVVM-Combine
//
//  Created by Vijay Raj Dixit on 28/02/26.
//


import Foundation

/// JSON-backed recent-history repository that keeps articles in MRU order.
final class JSONRecentHistoryStore: RecentHistoryRepository {
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
        do {
            let items = try disk.load([Article].self) ?? []
            return Array(items.prefix(maxItems))
        } catch {
            throw InfrastructureErrorMapper.mapStorageError(error)
        }
    }

    /// Inserts or moves-to-front (MRU) + LRU eviction.
    func touch(_ article: Article) throws {
        do {
            let items = try disk.load([Article].self) ?? []
            var mru = MRUList(items: items, maxItems: maxItems, key: { $0.id })
            mru.record(article)
            try disk.save(mru.items)
        } catch {
            throw InfrastructureErrorMapper.mapStorageError(error)
        }
    }

    func clear() throws {
        do {
            try disk.delete()
        } catch {
            throw InfrastructureErrorMapper.mapStorageError(error)
        }
    }
}
