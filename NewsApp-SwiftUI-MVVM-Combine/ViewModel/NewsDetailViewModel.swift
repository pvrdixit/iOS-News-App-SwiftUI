//
//  NewsDetailViewModel.swift
//  NewsApp-SwiftUI-MVVM-Combine
//
//  Created by Vijay Raj Dixit on 25/02/26.
//

import SwiftUI
import Combine
import WebKit

@MainActor
final class NewsDetailViewModel: ObservableObject {
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var isBookmarked: Bool = false
    @Published var alertMessage: String? = nil

    let page = WebPage()
    private let bookmarksStore = BookmarksStore()
    private let article: Article

    init(article: Article) {
        self.article = article
    }

    /// Validated URL (http/https + host)
    var url: URL? {
        guard
            let url = URL(string: article.url),
            let scheme = url.scheme?.lowercased(),
            ["http", "https"].contains(scheme),
            url.host != nil
        else { return nil }

        return url
    }

    var showEmptyState: Bool {
        alertMessage != nil && !isLoading
    }

    /// No-arg load used by the View: validates URL then loads or sets alert
    func load() async {
        guard let url else {
            alertMessage = "We couldn’t open this article. The link may be invalid or the article may no longer be available."
            return
        }
        await load(url)
    }

    /// No-arg retry used by the View
    func retry() async {
        await load()
    }

    func load(_ url: URL) async {
        guard !isLoading else { return }

        isBookmarked = bookmarksStore.isBookmarked(article.url)
        isLoading = true
        alertMessage = nil
        defer { isLoading = false }

        do {
            for try await event in page.load(url) {
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
            Log.shared.error("Article load failed",
                             category: .network,
                             metadata: [
                                "url": url.absoluteString,
                                "error": error.localizedDescription
                             ])
            alertMessage = processErrorForUI(from: error)
        }
    }
    
    func dismissError() {
        alertMessage = nil
    }
    
    private func processErrorForUI(from error: Error) -> String {
        if let navigationError = error as? WebPage.NavigationError {
            return NavigationErrorMapper.message(from: navigationError, viewType: .newsDetailView)
        } else {
            return NetworkErrorMapper.message(from: error, viewType: .newsDetailView)
        }
    }

    func toggleBookmark() {
        do {
            isBookmarked = try bookmarksStore.toggle(article)
        } catch {
            Log.shared.error("Bookmark toggle failed",
                             category: .bookmark,
                             metadata: ["error": error.localizedDescription])
        }
    }
}
