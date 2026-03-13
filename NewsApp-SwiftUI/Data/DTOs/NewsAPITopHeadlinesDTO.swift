//
//  NewsAPITopHeadlinesDTO.swift
//  NewsApp-SwiftUI
//
//  Created by Vijay Raj Dixit on 13/03/26.
//

/// Root DTO returned by NewsAPI for a top-headlines request.
struct NewsAPITopHeadlinesResponseDTO: Decodable {
    let totalResults: Int
    let articles: [NewsAPIArticleDTO]
}

/// NewsAPI article payload before it is normalized into the domain Article model.
struct NewsAPIArticleDTO: Decodable {
    let source: NewsAPISourceDTO
    let author: String?
    let title: String
    let description: String?
    let url: String
    let urlToImage: String?
    let publishedAt: String
    let content: String?
}

/// NewsAPI source payload embedded inside each NewsAPIArticleDTO.
struct NewsAPISourceDTO: Decodable {
    let id: String?
    let name: String
}
