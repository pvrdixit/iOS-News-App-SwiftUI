//
//  NewsView.swift
//  NewsApp-SwiftUI-MVVM-Combine
//
//  Created by Vijay Raj Dixit on 29/01/26.
//

import SwiftUI

struct NewsView: View {
    @ObservedObject var viewModel: NewsViewModel
    @State private var selectedURL: URL?

    /// NewsView
    var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.articles) { article in
                    NewsViewListItem(authorName: article.author ?? "",
                                     date: article.publishedDateToDisplay,
                                     headline: article.title,
                                     imageURL: article.urlToImage)
                    .onTapGesture {
                        if let url = URL(string: article.url) {
                            selectedURL = url
                            viewModel.saveRecentlyViewed(article)
                        }
                    }
                    .task(id: article.id) {
                        await viewModel.loadMoreIfNeeded(currentItem: article)
                    }
                }
            }
            .listStyle(.plain)
            .navigationTitle("News")
            .navigationBarTitleDisplayMode(.inline)
            .overlay {
                if viewModel.loadingState == .isLoading {
                    ProgressView()
                } else if showEmptyState {
                    EmptyStateView(
                        title: "Couldn't load news",
                        message: errorAlertMessage,
                        buttonTitle: "Try again",
                        action: {
                            Task {
                                await viewModel.fetchNews(.isLoading)
                            }
                        }
                    )
                }
            }
            .task {
                if viewModel.articles.isEmpty {
                     await viewModel.fetchNews()
                }
            }
            .refreshable {
                await viewModel.fetchNews(.isRefreshing)
            }
            .showAlert(message: errorAlertMessage,
                       isPresented: errorAlertBinding,
                       primaryRightButton: primaryAlertAction,
                       secondaryCancelButton: secondaryAlertAction)
            .navigationDestination(item: $selectedURL) { url in
                NewsDetailView(url: url)
            }
        }
    }
}

/// Error Alerts
extension NewsView {
    private var errorAlertMessage: String { viewModel.alertMessage ?? "Unable to fetch news, please try again" }
    private var showEmptyState: Bool {
        viewModel.articles.isEmpty &&
        viewModel.loadingState == .idle &&
        viewModel.alertMessage != nil
    }

    private var errorAlertBinding: Binding<Bool> {
        Binding(
            get: {
                viewModel.alertMessage != nil && !showEmptyState
            },
            set: {
                if !$0 { viewModel.dismissError() }
            }
        )
    }
    
    private var primaryAlertAction: (title: String, action: () -> Void) {(
        title: "Retry",
        action: {
            Task {
                await viewModel.fetchNews()
            }
        })
    }

    private var secondaryAlertAction: (title: String, action: () -> Void) {(
        title: "Cancel",
        action: {
            viewModel.dismissError()
        })
    }
}

#Preview {
    NewsView(viewModel: NewsViewModel(resource: NewsResource()))
}
