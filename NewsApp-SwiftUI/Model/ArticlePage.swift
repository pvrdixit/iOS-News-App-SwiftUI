//
//  ArticlePage.swift
//  NewsApp-SwiftUI-MVVM-Combine
//
//  Created by Vijay Raj Dixit on 29/01/26.
//

struct ArticlePage: Decodable {
    let totalResults: Int
    let articles: [Article]
}
