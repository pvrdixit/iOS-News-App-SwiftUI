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
        .navigationTitle(viewModel.navigationTitle)
        .navigationBarTitleDisplayMode(.inline)
        .searchable(text: $viewModel.search, prompt: viewModel.searchPrompt)
        .overlay {
            if viewModel.isLoading {
                ProgressView()
            } else if viewModel.shouldShowEmptyState {
                EmptyStateView(
                    title: viewModel.emptyStateTitle,
                    message: viewModel.emptyStateMessage,
                    buttonTitle: nil,
                    action: nil
                )
            }
        }
        .task {
            if viewModel.shouldRefreshOnAppear {
                await viewModel.refresh()
            }
        }
        .onSubmit(of: .search) {
            requestRefresh()
        }
        .onChange(of: viewModel.search) { oldValue, newValue in
            if viewModel.shouldRefreshOnSearchChange(from: oldValue, to: newValue) {
                requestRefresh()
            }
        }
        .onChange(of: viewModel.selectedCategory) { _, _ in
            requestRefresh()
        }
        .showAlert(
            message: viewModel.errorMessageToDisplay,
            isPresented: errorAlertBinding,
            primaryRightButton: (
                title: viewModel.retryButtonTitle,
                action: {
                    requestRefresh()
                }
            ),
            secondaryCancelButton: (
                title: viewModel.cancelButtonTitle,
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
    func requestRefresh() {
        Task { await viewModel.refresh() }
    }

    var errorAlertBinding: Binding<Bool> {
        Binding(
            get: { viewModel.isErrorPresented },
            set: { isPresented in
                viewModel.setErrorPresented(isPresented)
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
