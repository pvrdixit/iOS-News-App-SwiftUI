//
//  ExploreView.swift
//  NewsApp-SwiftUI-MVVM-Combine
//
//  Created by Vijay Raj Dixit on 02/03/26.
//

import SwiftUI

struct ExploreView: View {
    @ObservedObject var viewModel: ExploreViewModel
    @State private var selectedArticle: Article?

    var body: some View {
        List {
            CategoryChips(selected: $viewModel.selectedCategory, categories: ExploreCategory.allCases)
                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))

            ForEach(viewModel.articles) { article in
                NewsViewListItem(
                    authorName: article.author ?? "",
                    date: article.publishedDateToDisplay,
                    headline: article.title,
                    imageURL: article.urlToImage
                )
                .onTapGesture {
                    selectedArticle = article
                    viewModel.saveRecentlyViewed(article)
                }
                .task(id: article.id) {
                    await viewModel.loadMoreIfNeeded(currentItem: article)
                }
            }
        }
        .listStyle(.plain)
        .navigationTitle("Explore")
        .navigationBarTitleDisplayMode(.inline)
        .searchable(text: $viewModel.search, prompt: "Search news")
        .overlay {
            if viewModel.isLoading && viewModel.articles.isEmpty {
                ProgressView()
            } else if showEmptyState {
                EmptyStateView(
                    title: emptyStateTitle,
                    message: emptyStateMessage,
                    buttonTitle: nil,
                    action: nil
                )
            }
        }
        .task {
            if viewModel.articles.isEmpty {
                await viewModel.refresh()
            }
        }
        .onSubmit(of: .search) {
            Task { await viewModel.refresh() }
        }
        .onChange(of: viewModel.search) { oldValue, newValue in
            let oldTrimmed = oldValue.trimmingCharacters(in: .whitespacesAndNewlines)
            let newTrimmed = newValue.trimmingCharacters(in: .whitespacesAndNewlines)
            if !oldTrimmed.isEmpty && newTrimmed.isEmpty {
                Task { await viewModel.refresh() }
            }
        }
        .onChange(of: viewModel.selectedCategory) { _, _ in
            Task { await viewModel.refresh() }
        }
        .showAlert(
            message: viewModel.alertMessage ?? "Unable to explore news, please try again",
            isPresented: errorAlertBinding,
            primaryRightButton: (
                title: "Retry",
                action: {
                    Task { await viewModel.refresh() }
                }
            ),
            secondaryCancelButton: (
                title: "Cancel",
                action: {
                    viewModel.dismissError()
                }
            )
        )
        .navigationDestination(item: $selectedArticle) { article in
            NewsDetailScene(article: article)
        }
    }
}

private extension ExploreView {
    var showEmptyState: Bool {
        !viewModel.isLoading && viewModel.articles.isEmpty
    }

    var hasActiveFilters: Bool {
        let q = viewModel.search.trimmingCharacters(in: .whitespacesAndNewlines)
        return !q.isEmpty || viewModel.selectedCategory != .all
    }

    var emptyStateTitle: String {
        if !hasActiveFilters {
            return "Search or pick a category"
        }
        return "No results"
    }

    var emptyStateMessage: String {
        if !hasActiveFilters {
            return "Use the search bar or choose a category to explore."
        }
        return "Try a different search or category."
    }

    var errorAlertBinding: Binding<Bool> {
        Binding(
            get: { viewModel.alertMessage != nil },
            set: { isPresented in
                if !isPresented {
                    viewModel.dismissError()
                }
            }
        )
    }
}

#Preview {
    @MainActor in
    let dependencies = AppDependencies()
    return NavigationStack {
        ExploreView(viewModel: dependencies.makeExploreViewModel())
            .environment(\.appDependencies, dependencies)
    }
}
