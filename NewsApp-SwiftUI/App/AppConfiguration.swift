//
//  AppConfiguration.swift
//  NewsApp-SwiftUI
//
//  Created by Vijay Raj Dixit on 13/03/26.
//

import Foundation

/// Loads provider keys and regional defaults from the app bundle configuration.
struct AppConfiguration {
    let newsAPIKey: String?
    let newsDataAPIKey: String?
    let countryCode: String
    let languageCode: String

    static func load(bundle: Bundle = .main) -> AppConfiguration {
        let newsAPIKey = sanitizedString(forKey: "NEWS_API_KEY", bundle: bundle)
        let newsDataAPIKey = sanitizedString(forKey: "NEWSDATA_API_KEY", bundle: bundle)
        let countryCode = sanitizedString(forKey: "NEWS_COUNTRY_CODE", bundle: bundle) ?? "us"
        let languageCode = sanitizedString(forKey: "NEWS_LANGUAGE_CODE", bundle: bundle) ?? "en"

        return AppConfiguration(
            newsAPIKey: newsAPIKey,
            newsDataAPIKey: newsDataAPIKey,
            countryCode: countryCode,
            languageCode: languageCode
        )
    }
}

private extension AppConfiguration {
    /// Trims configuration values and ignores unresolved build setting placeholders.
    static func sanitizedString(forKey key: String, bundle: Bundle) -> String? {
        guard let rawValue = bundle.object(forInfoDictionaryKey: key) as? String else {
            return nil
        }

        let trimmed = rawValue.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, !trimmed.hasPrefix("$(") else {
            return nil
        }

        return trimmed
    }
}
