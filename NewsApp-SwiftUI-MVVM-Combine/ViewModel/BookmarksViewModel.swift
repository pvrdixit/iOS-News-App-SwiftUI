//
//  BookmarksViewModel.swift
//  NewsApp-SwiftUI-MVVM-Combine
//
//  Created by Vijay Raj Dixit on 27/02/26.
//

import SwiftUI
import Combine

enum BookmarksViewSegment: String, CaseIterable, Identifiable {
    case bookmarks = "Bookmarks"
    case recentHistory = "History"
    var id: String { rawValue }
}

@MainActor
final class BookmarksViewModel: ObservableObject {
    @Published var selectedSegment: BookmarksViewSegment = .bookmarks
    @Published private(set) var displayedArticles: [Article] = []
    private let recentHistory: RecentHistoryStore
    private let bookmarks: BookmarkStore
    private let logger: LoggerService

    init(recentHistory: RecentHistoryStore, bookmarks: BookmarkStore, logger: LoggerService) {
        self.recentHistory = recentHistory
        self.bookmarks = bookmarks
        self.logger = logger
    }
  
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
            logger.error("Segment load failed",
                         category: logCategory(for: selectedSegment),
                         metadata: [
                            "segment": selectedSegment.rawValue,
                            "error": error.localizedDescription
                         ])
        }
    }
    
    /// Store Recent History
    func saveRecentlyViewed(_ article: Article) {
        do {
            try recentHistory.touch(article)
            if selectedSegment == .recentHistory {
                displayedArticles = try recentHistory.load()
            }
        } catch {
            logger.error("Recent save failed",
                         category: .recent,
                         metadata: [
                            "error": error.localizedDescription
                         ])
        }
    }
}

private extension BookmarksViewModel {
    func logCategory(for segment: BookmarksViewSegment) -> LogCategory {
        switch segment {
        case .bookmarks:
            return .bookmark
        case .recentHistory:
            return .recent
        }
    }

    func articles(for segment: BookmarksViewSegment) throws -> [Article] {
        switch segment {
        case .bookmarks:
            return try bookmarks.load()
        case .recentHistory:
            return try recentHistory.load()
        }
    }
}
