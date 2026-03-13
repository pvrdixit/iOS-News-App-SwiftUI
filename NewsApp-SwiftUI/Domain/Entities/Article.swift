//
//  Article.swift
//  NewsApp-SwiftUI-MVVM-Combine
//
//  Created by Vijay Raj Dixit on 29/01/26.
//

import Foundation

/// Lightweight domain model representing the article data needed by the app UI and storage.
struct Article: Codable, Identifiable, Hashable {
    let title: String
    let credit: String?
    let date: String
    let articleURL: String
    let imageURL: String?

    var id: String { articleURL }

    init(
        title: String,
        credit: String? = nil,
        date: String,
        articleURL: String,
        imageURL: String? = nil
    ) {
        self.title = title
        self.credit = credit
        self.date = date
        self.articleURL = articleURL
        self.imageURL = imageURL
    }
}
