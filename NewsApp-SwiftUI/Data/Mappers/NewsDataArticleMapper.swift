//
//  NewsDataArticleMapper.swift
//  NewsApp-SwiftUI
//
//  Created by Vijay Raj Dixit on 13/03/26.
//

import Foundation

extension NewsDataArticleDTO {
    var domainArticle: Article? {
        guard let title,
              let link,
              let pubDate
        else {
            return nil
        }
        
        return Article(
            title: title,
            credit: sourceName ?? "",
            date: pubDate,
            articleURL: link,
            imageURL: imageURL
        )
    }
}
