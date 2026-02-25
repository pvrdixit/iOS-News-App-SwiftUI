//
//  Article.swift
//  NewsApp-SwiftUI-MVVM-Combine
//
//  Created by Vijay Raj Dixit on 29/01/26.
//

import Foundation

// MARK: - Article
struct Article: Codable, Identifiable {
    var id: String { url }
    let source: Source
    let author: String?
    let title: String
    let description: String?
    let url: String
    let urlToImage: String?
    let publishedAt: String
    let content: String?
    var publishedDateToDisplay: String {
        let iso = ISO8601DateFormatter()
        guard let date = iso.date(from: publishedAt) else { return "" }

        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "d MMM yyyy, h:mm a"

        return formatter.string(from: date)
    }
}
