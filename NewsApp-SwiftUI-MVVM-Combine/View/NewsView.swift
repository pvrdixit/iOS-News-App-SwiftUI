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
    
    // Toolbar
    @ToolbarContentBuilder
    private var toolBarSetup: some ToolbarContent {
        ToolbarImageButtonItem(systemImage: "magnifyingglass",
                               placement: .topBarTrailing) {
            // Search...
        }

        ToolbarImageButtonItem(systemImage: "arrow.clockwise",
                               placement: .topBarLeading) {
            viewModel.retry()
        }
    }

    var body: some View {
        NavigationStack {
            List(viewModel.articles) { article in
                NewsViewListItem(authorName: article.author ?? "",
                                 date: article.publishedDateToDisplay,
                                 headline: article.title,
                                 imageURL: article.urlToImage)
                .onTapGesture {
                    if let url = URL(string: article.url) {
                        selectedURL = url
                    }
                }
            }
            .listStyle(.plain)
            .navigationTitle("News USA")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { toolBarSetup }
            .overlay {
                if viewModel.isLoading && viewModel.noArticlesToShow {
                    ProgressView()
                }
            }
            .task {
                viewModel.load()
            }
            .refreshable {
                await viewModel.refresh()
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

extension NewsView {
    //Error Alert parameters
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
        title: "Ok",
        action: {})
    }

    private var secondaryAlertAction: (title: String, action: () -> Void) {(
        title: "Retry",
        action: {viewModel.retry()})
    }
}

#Preview {
    NewsView()
}
