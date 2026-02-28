//
//  JSONNewsCacheStore.swift
//  NewsApp-SwiftUI-MVVM-Combine
//
//  Created by Vijay Raj Dixit on 28/02/26.
//

import Foundation

/// Headlines cache stored in Caches directory (may be purged by iOS).
final class JSONNewsCacheStore: NewsCacheStore {
    private let disk: JSONDiskStore

    init() {
        self.disk = JSONDiskStore(
            fileName: "headlines_cache.json",
            directory: .cachesDirectory
        )
    }

    func load() throws -> [Article]? {
        try disk.load([Article].self)
    }

    func save(articles: [Article]) throws {
        try disk.save(articles)
    }

    func clear() throws {
        try disk.delete()
    }
}
