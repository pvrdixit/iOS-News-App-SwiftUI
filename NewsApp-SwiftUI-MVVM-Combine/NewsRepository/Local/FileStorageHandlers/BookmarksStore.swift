//
//  BookmarksStore.swift
//  NewsApp-SwiftUI-MVVM-Combine
//
//  Created by Vijay Raj Dixit on 27/02/26.
//

import Foundation

final class BookmarksStore {
    private let store: JSONFileStore<[Article]>

    init() {
        self.store = JSONFileStore<[Article]>(target: .bookmarks)
    }

    func load() throws -> [Article] {
        try store.load() ?? []
    }

    func save(_ articles: [Article]) throws {
        try store.save(articles)
    }

    func clear() throws {
        try store.delete()
    }
}
