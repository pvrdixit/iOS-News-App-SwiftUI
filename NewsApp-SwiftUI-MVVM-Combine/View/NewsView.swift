//
//  NewsView.swift
//  NewsApp-SwiftUI-MVVM-Combine
//
//  Created by Vijay Raj Dixit on 29/01/26.
//

import SwiftUI

struct NewsView: View {
    @ObservedObject var viewModel: NewsViewModel
    @State private var selectedArticle: Article?

    init(viewModel: NewsViewModel) {
        self.viewModel = viewModel
    }
    
    /// NewsView
    var body: some View {
        List {
            ForEach(viewModel.articles) { article in
                NewsViewListItem(authorName: article.author ?? "",
                                 date: article.publishedDateToDisplay,
                                 headline: article.title,
                                 imageURL: article.urlToImage)
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
        .overlay {
            if viewModel.shouldShowLoadingOverlay {
                ProgressView()
            } else if viewModel.shouldShowEmptyState {
                EmptyStateView(
                    title: viewModel.emptyStateTitle,
                    message: viewModel.emptyStateMessage,
                    buttonTitle: viewModel.emptyStateRetryButtonTitle,
                    action: {
                        requestLoadingRefresh()
                    }
                )
            }
        }
        .task {
            if viewModel.shouldFetchOnAppear {
                await viewModel.fetchNews()
            }
        }
        .refreshable {
            await viewModel.fetchNews(.isRefreshing)
        }
        .showAlert(message: viewModel.errorMessageToDisplay,
                   isPresented: errorAlertBinding,
                   primaryRightButton: primaryAlertAction,
                   secondaryCancelButton: secondaryAlertAction)
        .navigationDestination(item: $selectedArticle) { article in
            NewsDetailScene(article: article)
        }
    }
}

private extension NewsView {
    func requestRefresh() {
        Task {
            await viewModel.fetchNews()
        }
    }

    func requestLoadingRefresh() {
        Task {
            await viewModel.fetchNews(.isLoading)
        }
    }

    var errorAlertBinding: Binding<Bool> {
        Binding(
            get: { viewModel.isErrorPresented },
            set: { isPresented in
                viewModel.setErrorPresented(isPresented)
            }
        )
    }
    
    var primaryAlertAction: (title: String, action: () -> Void) {(
        title: viewModel.retryButtonTitle,
        action: {
            requestRefresh()
        })
    }

    var secondaryAlertAction: (title: String, action: () -> Void) {(
        title: viewModel.cancelButtonTitle,
        action: {
            viewModel.dismissError()
        })
    }
}

#Preview {
    @MainActor in
    let dependencies = AppDependencies()
    return NewsView(viewModel: dependencies.makeNewsViewModel())
        .environment(\.appDependencies, dependencies)
}
