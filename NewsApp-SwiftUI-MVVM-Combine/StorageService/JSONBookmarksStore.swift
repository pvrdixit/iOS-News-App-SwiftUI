//
//  JSONBookmarksStore.swift
//  NewsApp-SwiftUI-MVVM-Combine
//
//  Created by Vijay Raj Dixit on 28/02/26.
//


import Foundation

final class JSONBookmarksStore: BookmarkStore {
    private let disk: JSONDiskStore

    init() {
        self.disk = JSONDiskStore(
            fileName: "bookmarks.json",
            directory: .documentDirectory
        )
    }

    func load() throws -> [Article] {
        try disk.load([Article].self) ?? []
    }

    func save(_ articles: [Article]) throws {
        try disk.save(articles)
    }

    func clear() throws {
        try disk.delete()
    }

    func toggle(_ article: Article) throws -> Bool {
        var items = try load()

        if let idx = items.firstIndex(where: { $0.url == article.url }) {
            items.remove(at: idx)
            try disk.save(items)
            return false
        } else {
            items.insert(article, at: 0)
            try disk.save(items)
            return true
        }
    }

    func isBookmarked(_ url: String) -> Bool {
        guard let items = try? load() else { return false }
        return items.contains(where: { $0.url == url })
    }
}