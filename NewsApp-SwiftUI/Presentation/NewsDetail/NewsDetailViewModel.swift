//
//  NewsDetailViewModel.swift
//  NewsApp-SwiftUI-MVVM-Combine
//
//  Created by Vijay Raj Dixit on 25/02/26.
//

import Foundation
import Combine
import WebKit

@MainActor
/// Presentation state container for loading one article page and handling detail actions.
final class NewsDetailViewModel: ObservableObject {
    let retryButtonTitle = "Try again"
    let emptyStateTitle = "Unable to load the page"
    let bookmarkIconName = "bookmark"
    let bookmarkedIconName = "bookmark.fill"
    let shareIconName = "square.and.arrow.up"
    private let invalidArticleLinkMessage = "We couldn’t open this article. The link may be invalid or the article may no longer be available."
    private let defaultErrorMessage = "Unable to load this article."

    @Published private(set) var isLoading: Bool = false
    @Published private(set) var isBookmarked: Bool = false
    @Published var alertMessage: String? = nil

    let page = WebPage()
    private let bookmarkRepository: BookmarkRepository
    private let logger: LoggerService
    private let article: Article

    init(
        article: Article,
        bookmarkRepository: BookmarkRepository,
        logger: LoggerService
    ) {
        self.article = article
        self.bookmarkRepository = bookmarkRepository
        self.logger = logger
    }

    /// Validated article URL (http/https + host)
    var articleURL: URL? {
        guard
            let url = URL(string: article.articleURL),
            let scheme = url.scheme?.lowercased(),
            ["http", "https"].contains(scheme),
            url.host != nil
        else { return nil }

        return url
    }

    var showEmptyState: Bool {
        alertMessage != nil && !isLoading
    }

    var bookmarkIconNameToDisplay: String {
        isBookmarked ? bookmarkedIconName : bookmarkIconName
    }

    var errorMessageToDisplay: String {
        alertMessage ?? defaultErrorMessage
    }

    var isErrorPresented: Bool {
        alertMessage != nil && !showEmptyState
    }

    func load() async {
        guard let articleURL else {
            alertMessage = invalidArticleLinkMessage
            return
        }
        await load(articleURL)
    }

    func retry() async {
        await load()
    }

    func load(_ articleURL: URL) async {
        guard !isLoading else { return }

        resolveBookmarkState()
        isLoading = true
        alertMessage = nil
        defer { isLoading = false }

        do {
            for try await event in page.load(articleURL) {
                if event == .committed || event == .finished {
                    isLoading = false
                    return
                }
            }
        } catch is CancellationError {
            return
        } catch let urlError as URLError where urlError.code == .cancelled {
            return
        } catch {
            logger.error("Article load failed",
                         category: .network,
                         metadata: [
                            "url": articleURL.absoluteString,
                            "error": error.localizedDescription
                         ])
            alertMessage = processErrorForUI(from: error)
        }
    }
    
    func dismissError() {
        alertMessage = nil
    }

    func setErrorPresented(_ isPresented: Bool) {
        if !isPresented {
            dismissError()
        }
    }

    func resolveBookmarkState() {
        do {
            isBookmarked = try bookmarkRepository.isBookmarked(article.articleURL)
        } catch {
            isBookmarked = false
            logger.error(
                "Bookmark lookup failed",
                category: .bookmark,
                metadata: ["error": error.localizedDescription]
            )
        }
    }
    
    private func processErrorForUI(from error: Error) -> String {
        if let navigationError = error as? WebPage.NavigationError {
            return NavigationErrorMapper.message(from: navigationError, viewType: .newsDetailView)
        } else {
            return AppErrorMapper.message(from: error, viewType: .newsDetailView)
        }
    }

    func toggleBookmark() {
        do {
            isBookmarked = try bookmarkRepository.toggle(article)
        } catch {
            logger.error("Bookmark toggle failed",
                         category: .bookmark,
                         metadata: ["error": error.localizedDescription])
        }
    }
}
