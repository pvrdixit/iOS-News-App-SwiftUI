//
//  NewsAPIArticleMapper.swift
//  NewsApp-SwiftUI
//
//  Created by Vijay Raj Dixit on 13/03/26.
//

import Foundation

extension NewsAPIArticleDTO {
    var domainArticle: Article {
        let normalizedAuthor = author?
            .trimmingCharacters(in: .whitespacesAndNewlines)
        let resolvedCredit = normalizedAuthor?.isEmpty == false ? normalizedAuthor : source.name

        return Article(
            title: title,
            credit: resolvedCredit,
            date: publishedAt,
            articleURL: url,
            imageURL: urlToImage
        )
    }
}
