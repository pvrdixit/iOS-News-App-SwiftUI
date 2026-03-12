//
//  Article.swift
//  NewsApp-SwiftUI-MVVM-Combine
//
//  Created by Vijay Raj Dixit on 29/01/26.
//

import Foundation

struct Article: Codable, Identifiable {
    var id: String { url } /// for Identifiable
    let source: Source
    let author: String?
    let title: String
    let description: String?
    let url: String
    let urlToImage: String?
    let publishedAt: String
    let content: String?
}

/// For passing it as navigation item, custom Hasher reduces load
extension Article: Hashable {
    static func == (lhs: Article, rhs: Article) -> Bool { lhs.url == rhs.url }
    func hash(into hasher: inout Hasher) { hasher.combine(url) }
}
