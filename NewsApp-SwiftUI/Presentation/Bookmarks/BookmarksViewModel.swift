//
//  BookmarksViewModel.swift
//  NewsApp-SwiftUI-MVVM-Combine
//
//  Created by Vijay Raj Dixit on 27/02/26.
//

import Foundation
import Combine

/// Identifies which saved-content segment is currently active in the bookmarks screen.
enum BookmarksViewSegment: String, CaseIterable, Identifiable {
    case bookmarks = "Bookmarks"
    case recentHistory = "History"
    var id: String { rawValue }
}

@MainActor
/// Presentation state container for bookmarks and recent-history content.
final class BookmarksViewModel: ObservableObject {
    let navigationTitle = "Bookmarks"

    @Published var selectedSegment: BookmarksViewSegment = .bookmarks
    @Published private(set) var displayedArticles: [Article] = []
    private let bookmarkRepository: BookmarkRepository
    private let recentHistoryRepository: RecentHistoryRepository
    private let logger: LoggerService

    init(
        bookmarkRepository: BookmarkRepository,
        recentHistoryRepository: RecentHistoryRepository,
        logger: LoggerService
    ) {
        self.bookmarkRepository = bookmarkRepository
        self.recentHistoryRepository = recentHistoryRepository
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

    var shouldShowEmptyState: Bool {
        displayedArticles.isEmpty
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
            try recentHistoryRepository.touch(article)
            if selectedSegment == .recentHistory {
                displayedArticles = try recentHistoryRepository.load()
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
            return try bookmarkRepository.load()
        case .recentHistory:
            return try recentHistoryRepository.load()
        }
    }
}
