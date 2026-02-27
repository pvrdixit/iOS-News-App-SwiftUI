//
//  NewsStoreTarget.swift
//  NewsApp-SwiftUI-MVVM-Combine
//
//  Created by Vijay Raj Dixit on 27/02/26.
//

import Foundation

enum NewsStoreTarget {
    case headlinesCache
    case bookmarks
    case recentHistory

    var fileName: String {
        switch self {
        case .headlinesCache: return "headlines_cache.json"
        case .bookmarks:      return "bookmarks.json"
        case .recentHistory:  return "recent_history.json"
        }
    }

    var directory: FileManager.SearchPathDirectory {
        switch self {
        case .headlinesCache:
            return .cachesDirectory            /// ok to be purged by iOS
        case .bookmarks, .recentHistory:
            return .documentDirectory          /// should persist
        }
    }
}
