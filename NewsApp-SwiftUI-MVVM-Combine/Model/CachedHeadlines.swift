//
//  CachedHeadlines.swift
//  NewsApp-SwiftUI-MVVM-Combine
//
//  Created by Vijay Raj Dixit on 25/02/26.
//

import Foundation

struct CachedHeadlines: Codable {
    let context: String
    let cachedAt: Date
    let articles: [Article]
}
