//
//  MRUList.swift
//  NewsApp-SwiftUI-MVVM-Combine
//
//  Created by Vijay Raj Dixit on 28/02/26.
//


import Foundation

/// Small helper that enforces MRU order and max-items trimming.
struct MRUList<Element, Key: Hashable> {
    private(set) var items: [Element]
    private let maxItems: Int
    private let key: (Element) -> Key

    init(items: [Element] = [], maxItems: Int, key: @escaping (Element) -> Key) {
        self.items = items
        self.maxItems = maxItems
        self.key = key
        trimIfNeeded()
    }

    mutating func record(_ element: Element) {
        let k = key(element)
        if let idx = items.firstIndex(where: { key($0) == k }) {
            items.remove(at: idx)
        }
        items.insert(element, at: 0)
        trimIfNeeded()
    }

    private mutating func trimIfNeeded() {
        guard items.count > maxItems else { return }
        items.removeLast(items.count - maxItems)
    }
}