//
//  HomeView.swift
//  NewsApp-SwiftUI-MVVM-Combine
//
//  Created by Vijay Raj Dixit on 29/01/26.
//

import SwiftUI

/// Home screen that renders the main top-headlines feed.
struct HomeView: View {
    @ObservedObject var viewModel: HomeViewModel
    @State private var selectedArticle: Article?

    init(viewModel: HomeViewModel) {
        self.viewModel = viewModel
    }
    
    /// HomeView
    var body: some View {
        List {
            ForEach(viewModel.articles) { article in
                ArticleListItemView(credit: article.credit ?? "",
                                    date: ArticleDisplayFormatter.displayDate(from: article.date),
                                    title: article.title,
                                    imageURL: article.imageURL)
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

private extension HomeView {
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
    let appDI = AppDI.preview()
    return HomeView(viewModel: appDI.makeHomeViewModel())
        .environment(\.appDI, appDI)
}
