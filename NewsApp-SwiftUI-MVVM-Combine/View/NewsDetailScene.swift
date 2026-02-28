//
//  NewsDetailScene.swift
//  NewsApp-SwiftUI-MVVM-Combine
//
//  Created by Vijay Raj Dixit on 28/02/26.
//

import SwiftUI

@MainActor
struct NewsDetailScene: View {
    let article: Article
    @Environment(\.appDependencies) private var dependencies

    var body: some View {
        NewsDetailView(
            viewModel: dependencies.makeNewsDetailViewModel(article: article)
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

    return NewsDetailScene(article: article)
        .environment(\.appDependencies, dependencies)
}
