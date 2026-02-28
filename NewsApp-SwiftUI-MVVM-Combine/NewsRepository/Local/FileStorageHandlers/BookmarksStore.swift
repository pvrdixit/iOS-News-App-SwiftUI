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
    
    ///Toggle and check if bookmarked
    func toggle(_ article: Article) throws -> Bool {
        var items = try load()
        
        if let idx = items.firstIndex(where: { $0.url == article.url }) {
            items.remove(at: idx)
            try store.save(items)
            return false
        } else {
            items.insert(article, at: 0)
            try store.save(items)
            return true
        }
    }
    
    func isBookmarked(_ url: String) -> Bool {
        guard let items = try? load() else { return false }
        return items.contains(where: { $0.url == url })
    }
}
