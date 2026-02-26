//
//  NewsView.swift
//  NewsApp-SwiftUI-MVVM-Combine
//
//  Created by Vijay Raj Dixit on 29/01/26.
//

import SwiftUI

struct NewsView: View {
    @StateObject private var viewModel: NewsViewModel
    @State private var selectedURL: URL?

    init(viewModel: NewsViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    init() {
        _viewModel = StateObject(wrappedValue: NewsViewModel())
    }
    
    /// Toolbar
    @ToolbarContentBuilder
    private var toolBarSetup: some ToolbarContent {
        ToolbarImageButtonItem(systemImage: "arrow.clockwise",
                               placement: .topBarTrailing,
                               isDisabled: viewModel.isLoading) {
            Task {
                await viewModel.fetchNews()
            }
        }
    }

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
            .toolbar { toolBarSetup }
            .overlay {
                if viewModel.isLoading {
                    ProgressView()
                }
            }
            .task {
                if viewModel.articles.isEmpty {
                    await viewModel.fetchNews()
                }
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
    private var errorAlertBinding: Binding<Bool> {
        Binding(
            get: {
                viewModel.alertMessage != nil
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
    NewsView()
}
