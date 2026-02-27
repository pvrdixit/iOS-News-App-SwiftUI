//
//  BookmarksViewModel.swift
//  NewsApp-SwiftUI-MVVM-Combine
//
//  Created by Vijay Raj Dixit on 27/02/26.
//

import SwiftUI
import Combine

enum BookmarkPageSegment: String, CaseIterable, Identifiable {
    case bookmarks = "Bookmarks"
    case recentHistory = "Recent History"

    var id: String { rawValue }
}

@MainActor
final class BookmarksViewModel: ObservableObject {
    @Published var selectedSegment: BookmarkPageSegment = .bookmarks
    @Published private(set) var displayedArticles: [Article] = []
    private let recentStore = RecentHistoryStore()
    private let bookmarksStore = BookmarksStore()
  
    var emptyStateTitle: String {
        switch selectedSegment {
        case .bookmarks:
            return "No Bookmarks"
        case .recentHistory:
            return "No Recent History"
        }
    }

    var emptyStateMessage: String {
        switch selectedSegment {
        case .bookmarks:
            return "Saved articles will appear here."
        case .recentHistory:
            return "Recently viewed articles will appear here."
        }
    }

    func loadSelectedSegment() {
        do {
            displayedArticles = try articles(for: selectedSegment)
        } catch {
            displayedArticles = []
        }
    }
}

private extension BookmarksViewModel {
    func articles(for segment: BookmarkPageSegment) throws -> [Article] {
        switch segment {
        case .bookmarks:
            return try bookmarksStore.load()
        case .recentHistory:
            return try recentStore.load()
        }
    }
}
