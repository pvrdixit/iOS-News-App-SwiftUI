//
//  NewsViewModel.swift
//  NewsApp-SwiftUI-MVVM-Combine
//
//  Created by Vijay Raj Dixit on 29/01/26.
//

import SwiftUI
import Combine

@MainActor
final class NewsViewModel: ObservableObject {
    @Published private(set) var articles: [Article] = []
    @Published private(set) var isLoading: Bool = false
    @Published var alertMessage: String? = nil

    private let resource: NewsResource
    private let cacheStore = NewsCacheStore()
    private let cacheContext = "top_headlines_us"
    private var paginationState = NewsPaginationState(pageSize: 5)
    private let loadMoreThreshold = 1
    private var hasLoadedFirstPageFromNetwork = false

    init(resource: NewsResource) {
        self.resource = resource
    }
    convenience init() { self.init(resource: NewsResource()) }

    ///Fetch Articles
    func fetchNews() async {
        guard !isLoading else { return }

        await fetchPage(page: 1, isFirstPage: true)
    }
    
    private func fetchPage(page: Int, isFirstPage: Bool) async {
        guard !isLoading else { return }

        isLoading = true
        if isFirstPage {
            alertMessage = nil
        }
        defer { isLoading = false }

        do {
            let headlines = try await resource.fetchTopHeadlinesAsync(
                page: page,
                pageSize: paginationState.pageSize
            )

            if isFirstPage {
                articles = paginationState.applyFirstPage(
                    articles: headlines.articles,
                    totalResults: headlines.totalResults
                )
                hasLoadedFirstPageFromNetwork = true
            } else {
                articles = paginationState.applyNextPage(
                    existing: articles,
                    incoming: headlines.articles,
                    totalResults: headlines.totalResults,
                    nextPage: page
                )
            }
            saveToCache(articles: articles)
        } catch is CancellationError {
            return
        } catch let urlError as URLError where urlError.code == .cancelled {
            return
        } catch {
            if isFirstPage, articles.isEmpty, let cachedArticles = loadFromCacheIfAvailable() {
                articles = cachedArticles
                Log.shared.warning("First-page fetch failed, showing cached headlines",
                                   category: .cache,
                                   metadata: [
                                    "page": "\(page)",
                                    "cachedCount": "\(cachedArticles.count)",
                                    "error": error.localizedDescription
                                   ])
                return
            }
            Log.shared.error("Failed to fetch headlines",
                             category: .network,
                             metadata: [
                                "page": "\(page)",
                                "error": error.localizedDescription
                             ])
            alertMessage = processErrorForUI(from: error)
        }
    }

    ///Pagination Logic
    func loadMoreIfNeeded(currentItem: Article) async {
        guard hasLoadedFirstPageFromNetwork,
              shouldLoadMore(after: currentItem),
              let nextPage = paginationState.nextPageCandidate
        else { return }
        await fetchPage(page: nextPage, isFirstPage: false)
    }
    
    private func shouldLoadMore(after article: Article) -> Bool {
        guard !isLoading, paginationState.canLoadMore else { return false }
        guard let index = articles.firstIndex(where: { $0.id == article.id }) else { return false }

        let triggerIndex = max(articles.count - loadMoreThreshold, 0)
        return index >= triggerIndex
    }
    
    ///Cache Logic
    private func loadFromCacheIfAvailable() -> [Article]? {
        do {
            return try cacheStore.load(context: cacheContext)?.articles
        } catch {
            Log.shared.error("Cache load failed",
                             category: .cache,
                             metadata: [
                                "context": cacheContext,
                                "error": error.localizedDescription
                             ])
            return nil
        }
    }

    private func saveToCache(articles: [Article]) {
        do {
            try cacheStore.save(articles: articles, context: cacheContext)
        } catch {
            Log.shared.error("Cache save failed",
                             category: .cache,
                             metadata: [
                                "context": cacheContext,
                                "count": "\(articles.count)",
                                "error": error.localizedDescription
                             ])
        }
    }

    ///Error flow
    private func processErrorForUI(from error: Error) -> String {
        NetworkErrorMapper.message(from: error, viewType: .newsView)
    }
    
    func dismissError() {
        alertMessage = nil
    }
}
