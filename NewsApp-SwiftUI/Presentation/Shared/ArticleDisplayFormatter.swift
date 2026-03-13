//
//  ArticleDisplayFormatter.swift
//  NewsApp-SwiftUI-MVVM-Combine
//
//  Created by Vijay Raj Dixit on 12/03/26.
//

import Foundation

/// Formats article date strings from provider payloads into localized display text.
enum ArticleDisplayFormatter {
    static func displayDate(from value: String) -> String {
        guard let date = parsedDate(from: value) else { return "" }

        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "d MMM yyyy, h:mm a"

        return formatter.string(from: date)
    }
}

private extension ArticleDisplayFormatter {
    static func parsedDate(from value: String) -> Date? {
        let isoFormatter = ISO8601DateFormatter()
        if let date = isoFormatter.date(from: value) {
            return date
        }

        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = isoFormatter.date(from: value) {
            return date
        }

        return fallbackDateFormatters.lazy.compactMap { formatter in
            formatter.date(from: value)
        }.first
    }

    static var fallbackDateFormatters: [DateFormatter] {
        ["yyyy-MM-dd HH:mm:ss", "yyyy-MM-dd HH:mm:ss zzz", "yyyy-MM-dd HH:mm:ss VV"].map { format in
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.timeZone = TimeZone(secondsFromGMT: 0)
            formatter.dateFormat = format
            return formatter
        }
    }
}
