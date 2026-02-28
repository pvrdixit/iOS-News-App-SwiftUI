//
//  NewsDetailView.swift
//  NewsApp-SwiftUI-MVVM-Combine
//
//  Created by Vijay Raj Dixit on 30/01/26.
//

import SwiftUI
import WebKit

struct NewsDetailView: View {
    @StateObject private var viewModel: NewsDetailViewModel
    
    init(viewModel: NewsDetailViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    /// Toolbar
    @ToolbarContentBuilder
    private var toolBarSetup: some ToolbarContent {
        ToolbarItemGroup(placement: .topBarTrailing) {
            Button {
                viewModel.toggleBookmark()
            } label: {
                Image(systemName: viewModel.isBookmarked ? "bookmark.fill" : "bookmark")
            }

            if let url = viewModel.url {
                ShareLink(item: url) {
                    Image(systemName: "square.and.arrow.up")
                }
            }
        }
    }
    
    /// NewsDetailView
    var body: some View {
        WebView(viewModel.page)
            .ignoresSafeArea()
            .toolbar { toolBarSetup }
            .overlay {
                if viewModel.isLoading {
                    ProgressView()
                } else if viewModel.showEmptyState {
                    EmptyStateView(
                        title: "Unable to load the page",
                        message: errorAlertMessage,
                        buttonTitle: "Try again",
                        action: {
                            Task { await viewModel.retry() }
                        }
                    )
                }
            }
            .task {
                await viewModel.load()
            }
            .showAlert(
                message: errorAlertMessage,
                isPresented: errorAlertBinding,
                primaryRightButton: (
                    title: "Retry",
                    action: {
                        Task { await viewModel.retry() }
                    }
                )
            )
    }
}

/// Error Alerts
private extension NewsDetailView {
    var errorAlertMessage: String {
        viewModel.alertMessage ?? "Unable to load this article."
    }

    var errorAlertBinding: Binding<Bool> {
        Binding(
            get: { viewModel.alertMessage != nil && !viewModel.showEmptyState },
            set: { newValue in
                if !newValue { viewModel.dismissError() }
            }
        )
    }
}

#Preview {
    @MainActor in
    let dependencies = AppDependencies()
    let article = Article(
        source: Source(id: "id", name: "Sample Source"),
        author: "Sample Author",
        title: "Sample Title",
        description: "Sample Description",
        url: "https://www.apple.com",
        urlToImage: "https://picsum.photos/seed/picsum/1800/900",
        publishedAt: "2026-02-28T10:00:00Z",
        content: "Sample Content"
    )

    return NewsDetailView(
        viewModel: dependencies.makeNewsDetailViewModel(article: article)
    )
}
