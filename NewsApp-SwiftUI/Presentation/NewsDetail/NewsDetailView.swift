//
//  NewsDetailView.swift
//  NewsApp-SwiftUI-MVVM-Combine
//
//  Created by Vijay Raj Dixit on 30/01/26.
//

import SwiftUI
import WebKit

/// Full-screen article detail view that embeds a WebKit page with bookmarking and sharing actions.
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

            if let articleURL = viewModel.articleURL {
                ShareLink(item: articleURL) {
                    Image(systemName: viewModel.shareIconName)
                }
            }
        }
    }
    
    /// NewsDetailView
    var body: some View {
        WebView(viewModel.page)
            .ignoresSafeArea()
            .toolbar(.hidden, for: .tabBar)
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
    let appDI = AppDI.preview()
    let article = Article(
        title: "Sample Title",
        credit: "Sample Source",
        date: "2026-02-28T10:00:00Z",
        articleURL: "https://www.apple.com",
        imageURL: "https://picsum.photos/seed/picsum/1800/900"
    )

    NewsDetailView(
        viewModel: appDI.makeNewsDetailViewModel(article: article)
    )
}
