//
//  NewsViewModel.swift
//  NewsApp-SwiftUI-MVVM-Combine
//
//  Created by Vijay Raj Dixit on 29/01/26.
//

import Combine
import SwiftUI

@MainActor
final class NewsViewModel: ObservableObject {
    @Published private(set) var articles: [Article] = []
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var isRefreshing: Bool = false
    @Published private(set) var lastUpdatedText: String?
    @Published var alertMessage: String? = nil   // alert-ready message; view binds directly

    private let resource: NewsResource
    private let cacheStore = NewsCacheStore()
    private let cacheContext = "top_headlines_us"
    private let requestTimeoutSecs: Double = 8
    private let requestTimeoutSecsLongWait: Double = 20
    private var cancellables = Set<AnyCancellable>()

    init(resource: NewsResource) {
        self.resource = resource
    }
    convenience init() { self.init(resource: NewsResource()) }

    deinit {
        cancellables.forEach { $0.cancel() }
    }

    var noArticlesToShow: Bool { articles.isEmpty }

    func load() {
        guard !isLoading && !isRefreshing else { return }

        if articles.isEmpty {
            loadCachedIfAvailable()
        }

        isLoading = true
        alertMessage = nil
        cancellables.removeAll()

        resource.fetchTopHeadlines()
            .timeout(.seconds(noArticlesToShow ? requestTimeoutSecsLongWait : requestTimeoutSecs),
                     scheduler: DispatchQueue.main,
                     customError: { URLError(.timedOut) })
            .map(\.articles)
            .receive(on: DispatchQueue.main) // VM is @MainActor, this is defensive but fine
            .sink { [weak self] completion in
                guard let self = self else { return }
                self.isLoading = false

                if case .failure(let error) = completion {
                    self.alertMessage = NetworkErrorMapper.message(from: error, viewType: .newsView)
                }
            } receiveValue: { [weak self] articles in
                guard let self = self else { return }
                self.articles = articles
                self.cacheStore.save(articles: articles, context: self.cacheContext)
                self.lastUpdatedText = self.formattedTimestamp(date: Date())
            }
            .store(in: &cancellables)
    }
    
    func dismissError() {
        alertMessage = nil
    }

    // MARK: - Pull to refresh (async/await)
    func refresh() async {
        guard !isLoading && !isRefreshing else { return }

        cancellables.forEach { $0.cancel() }
        cancellables.removeAll()
        isRefreshing = true
        alertMessage = nil
        defer { isRefreshing = false }

        do {
            let headlines = try await withTimeout(seconds: requestTimeoutSecs) {
                try await self.resource.fetchTopHeadlinesAsync()
            }
            self.articles = headlines.articles
            self.cacheStore.save(articles: headlines.articles, context: self.cacheContext)
            self.lastUpdatedText = self.formattedTimestamp(date: Date())
        } catch {
            self.alertMessage = NetworkErrorMapper.message(from: error, viewType: .newsView)
        }
    }

    private func withTimeout<T>(seconds: Double,
                                operation: @escaping () async throws -> T) async throws -> T {
        try await withThrowingTaskGroup(of: T.self) { group in
            group.addTask {
                try await operation()
            }
            group.addTask {
                try await Task.sleep(nanoseconds: UInt64(seconds * 1e9))
                throw URLError(.timedOut)
            }

            let value = try await group.next()!
            group.cancelAll()
            return value
        }
    }

    private func loadCachedIfAvailable() {
        guard let cached = cacheStore.load(context: cacheContext) else { return }
        articles = cached.articles
        lastUpdatedText = formattedTimestamp(date: cached.cachedAt)
    }

    private func formattedTimestamp(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.timeZone = TimeZone.current
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return "Updated \(formatter.string(from: date))"
    }
}
