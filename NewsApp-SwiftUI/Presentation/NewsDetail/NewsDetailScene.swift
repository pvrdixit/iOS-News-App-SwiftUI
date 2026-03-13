//
//  NewsDetailScene.swift
//  NewsApp-SwiftUI-MVVM-Combine
//
//  Created by Vijay Raj Dixit on 28/02/26.
//

import SwiftUI

@MainActor
/// Thin scene wrapper that asks the DI container for a detail view model for one article.
struct NewsDetailScene: View {
    let article: Article
    @Environment(\.appDI) private var appDI

    var body: some View {
        NewsDetailView(
            viewModel: appDI.makeNewsDetailViewModel(article: article)
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

    NewsDetailScene(article: article)
        .environment(\.appDI, appDI)
}
