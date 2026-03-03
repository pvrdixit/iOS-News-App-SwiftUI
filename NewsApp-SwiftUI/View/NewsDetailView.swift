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
                Image(systemName: viewModel.bookmarkIconNameToDisplay)
            }

            if let url = viewModel.url {
                ShareLink(item: url) {
                    Image(systemName: viewModel.shareIconName)
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
                        title: viewModel.emptyStateTitle,
                        message: viewModel.errorMessageToDisplay,
                        buttonTitle: viewModel.retryButtonTitle,
                        action: {
                            requestRetry()
                        }
                    )
                }
            }
            .task {
                await viewModel.load()
            }
            .showAlert(
                message: viewModel.errorMessageToDisplay,
                isPresented: errorAlertBinding,
                primaryRightButton: (
                    title: viewModel.retryButtonTitle,
                    action: {
                        requestRetry()
                    }
                )
            )
    }
}

/// Error Alerts
private extension NewsDetailView {
    func requestRetry() {
        Task { await viewModel.retry() }
    }

    var errorAlertBinding: Binding<Bool> {
        Binding(
            get: { viewModel.isErrorPresented },
            set: { newValue in
                viewModel.setErrorPresented(newValue)
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
