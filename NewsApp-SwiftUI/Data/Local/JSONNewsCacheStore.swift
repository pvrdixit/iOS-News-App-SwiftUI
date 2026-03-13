//
//  JSONNewsCacheStore.swift
//  NewsApp-SwiftUI-MVVM-Combine
//
//  Created by Vijay Raj Dixit on 28/02/26.
//

import Foundation

/// JSON-backed headlines cache repository stored in the system caches directory.
final class JSONNewsCacheStore: NewsCacheRepository {
    private let disk: JSONDiskStore

    init() {
        self.disk = JSONDiskStore(
            fileName: "headlines_cache.json",
            directory: .cachesDirectory
        )
    }

    func load() throws -> [Article]? {
        do {
            return try disk.load([Article].self)
        } catch {
            throw InfrastructureErrorMapper.mapStorageError(error)
        }
    }

    func save(_ articles: [Article]) throws {
        do {
            try disk.save(articles)
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
