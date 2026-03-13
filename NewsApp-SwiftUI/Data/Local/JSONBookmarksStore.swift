//
//  JSONBookmarksStore.swift
//  NewsApp-SwiftUI-MVVM-Combine
//
//  Created by Vijay Raj Dixit on 28/02/26.
//


import Foundation

/// JSON-backed bookmark repository used for persistent saved articles.
final class JSONBookmarksStore: BookmarkRepository {
    private let disk: JSONDiskStore

    init() {
        self.disk = JSONDiskStore(
            fileName: "bookmarks.json",
            directory: .documentDirectory
        )
    }

    func load() throws -> [Article] {
        do {
            return try disk.load([Article].self) ?? []
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

    func toggle(_ article: Article) throws -> Bool {
        do {
            var items = try disk.load([Article].self) ?? []

            if let idx = items.firstIndex(where: { $0.articleURL == article.articleURL }) {
                items.remove(at: idx)
                try disk.save(items)
                return false
            } else {
                items.insert(article, at: 0)
                try disk.save(items)
                return true
            }
        } catch {
            throw InfrastructureErrorMapper.mapStorageError(error)
        }
    }

    func isBookmarked(_ articleURL: String) throws -> Bool {
        do {
            let items = try disk.load([Article].self) ?? []
            return items.contains(where: { $0.articleURL == articleURL })
        } catch {
            throw InfrastructureErrorMapper.mapStorageError(error)
        }
    }
}
