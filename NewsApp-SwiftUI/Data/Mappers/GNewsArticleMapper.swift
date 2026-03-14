//
//  GNewsArticleMapper.swift
//  NewsApp-SwiftUI
//
//  Created by Vijay Raj Dixit on 14/03/26.
//

import Foundation

extension GNewsArticleDTO {
    var domainArticle: Article? {
        guard let title,
              let url,
              let publishedAt
        else {
            return nil
        }

        return Article(
            title: title,
            credit: source?.name,
            date: publishedAt,
            articleURL: url,
            imageURL: image
        )
    }
}
