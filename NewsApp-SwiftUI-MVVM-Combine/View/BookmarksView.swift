//
//  BookmarksView.swift
//  NewsApp-SwiftUI-MVVM-Combine
//
//  Created by Vijay Raj Dixit on 27/02/26.
//

import SwiftUI

struct BookmarksView: View {
    @StateObject private var viewModel = BookmarksViewModel()
    @State private var selectedArticle: Article?
    
    var body: some View {
        VStack(spacing: 16) {
            Picker("Saved Content", selection: $viewModel.selectedSegment) {
                ForEach(BookmarkPageSegment.allCases) { segment in
                    Text(segment.rawValue).tag(segment)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            
            if viewModel.displayedArticles.isEmpty {
                EmptyStateView(title: viewModel.emptyStateTitle, message: viewModel.emptyStateMessage, buttonTitle: nil, action: nil)
            } else {
                List {
                    ForEach(viewModel.displayedArticles) { article in
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
                    }
                }
                .listStyle(.plain)
            }
        }
        .navigationTitle("Bookmarks")
        .navigationBarTitleDisplayMode(.inline)
        .task(id: viewModel.selectedSegment) {
            viewModel.loadSelectedSegment()
        }
        .navigationDestination(item: $selectedArticle) { article in
            NewsDetailView(article: article)
        }
    }
}

#Preview {
    BookmarksView()
}
