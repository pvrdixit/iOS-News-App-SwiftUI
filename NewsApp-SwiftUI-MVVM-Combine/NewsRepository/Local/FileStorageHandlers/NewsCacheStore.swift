//
//  NewsCacheStore.swift
//  NewsApp-SwiftUI-MVVM-Combine
//
//  Created by Vijay Raj Dixit on 25/02/26.
//

import Foundation

final class NewsCacheStore {
    private let store: JSONFileStore<[Article]>

    init() {
        self.store = JSONFileStore<[Article]>(target: .headlinesCache)
    }

    func load() throws -> [Article]? {
        try store.load()
    }

    func save(articles: [Article]) throws {
        try store.save(articles)
    }

    func clear() throws {
        try store.delete()
    }
}
