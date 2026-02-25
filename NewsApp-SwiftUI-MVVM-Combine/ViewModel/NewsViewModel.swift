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
    @Published var alertMessage: String? = nil   // alert-ready message; view binds directly

    private let resource: NewsResource
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
        guard !isLoading else { return }

        isLoading = true
        alertMessage = nil
        cancellables.removeAll()

        resource.fetchTopHeadlines()
            .map(\.articles)
            .receive(on: DispatchQueue.main) // VM is @MainActor, this is defensive but fine
            .sink { [weak self] completion in
                guard let self = self else { return }
                self.isLoading = false

                if case .failure(let error) = completion {
                    self.alertMessage = self.processErrorForUI(from: error)
                }
            } receiveValue: { [weak self] articles in
                guard let self = self else { return }
                self.articles = articles
            }
            .store(in: &cancellables)
    }

    func retry() {
        load()
    }
    
    func dismissError() {
        alertMessage = nil
    }

    // MARK: - Pull to refresh (async/await)
    func refresh() async {
        // Cancel Combine pipelines — refresh should win
        cancellables.forEach { $0.cancel() }
        cancellables.removeAll()
        alertMessage = nil

        do {
            let headlines = try await resource.fetchTopHeadlinesAsync()
            self.articles = headlines.articles
        } catch {
            self.alertMessage = processErrorForUI(from: error)
        }
    }

    // Map low-level errors to user-facing messages
    private func processErrorForUI(from error: Error) -> String {
        if let urlError = error as? URLError {
            print(urlError.code)
            switch urlError.code {
            case .notConnectedToInternet:
                return "No internet connection. Check your network and try again."
            case .timedOut:
                return "Request timed out. Please try again."

            default:
                print(urlError.localizedDescription)
                return "Unknown error. Please try again."
            }
        }
        return error.localizedDescription
    }
}
