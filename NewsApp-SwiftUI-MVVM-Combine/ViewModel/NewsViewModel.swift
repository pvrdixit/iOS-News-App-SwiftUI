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
    @Published var alertMessage: String? = nil

    private let resource: NewsResource
    private let cacheStore = NewsCacheStore()
    private let cacheContext = "top_headlines_us"
    private var requestTimeoutSecs: Double { articles.isEmpty ? 20 : 8 }
    private var cancellables = Set<AnyCancellable>()

    init(resource: NewsResource) {
        self.resource = resource
    }
    convenience init() { self.init(resource: NewsResource()) }

    deinit {
        cancellables.forEach { $0.cancel() }
    }

    func load() {
        guard !isLoading else { return }

        if articles.isEmpty {
            loadCachedIfAvailable()
        }

        isLoading = true
        alertMessage = nil
        cancellables.removeAll()

        resource.fetchTopHeadlines()
            .timeout(.seconds(requestTimeoutSecs),
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
            }
            .store(in: &cancellables)
    }
    
    func dismissError() {
        alertMessage = nil
    }

    private func loadCachedIfAvailable() {
        guard let cached = cacheStore.load(context: cacheContext) else { return }
        articles = cached.articles
    }
}
