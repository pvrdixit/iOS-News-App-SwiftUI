//
//  ArticleDisplayFormatter.swift
//  NewsApp-SwiftUI-MVVM-Combine
//
//  Created by Vijay Raj Dixit on 12/03/26.
//

import Foundation

enum ArticleDisplayFormatter {
    static func publishedDate(from publishedAt: String) -> String {
        let isoFormatter = ISO8601DateFormatter()
        guard let date = isoFormatter.date(from: publishedAt) else { return "" }

        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "d MMM yyyy, h:mm a"

        return formatter.string(from: date)
    }
}
