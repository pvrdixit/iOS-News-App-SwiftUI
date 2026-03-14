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
    let gNewsAPIKey: String?
    let countryCode: String
    let languageCode: String

    static func load(bundle: Bundle = .main) -> AppConfiguration {
        let newsAPIKey = configuredValue(forKey: "NEWS_API_KEY", bundle: bundle)
        let newsDataAPIKey = configuredValue(forKey: "NEWSDATA_API_KEY", bundle: bundle)
        let gNewsAPIKey = configuredValue(forKey: "GNEWS_API_KEY", bundle: bundle)
        let countryCode = configuredValue(forKey: "NEWS_COUNTRY_CODE", bundle: bundle) ?? "us"
        let languageCode = configuredValue(forKey: "NEWS_LANGUAGE_CODE", bundle: bundle) ?? "en"

        return AppConfiguration(
            newsAPIKey: newsAPIKey,
            newsDataAPIKey: newsDataAPIKey,
            gNewsAPIKey: gNewsAPIKey,
            countryCode: countryCode,
            languageCode: languageCode
        )
    }
}

private extension AppConfiguration {
    /// Reads a configured bundle value and safely ignores accidental whitespace or unresolved placeholders.
    static func configuredValue(forKey key: String, bundle: Bundle) -> String? {
        guard let rawValue = bundle.object(forInfoDictionaryKey: key) as? String else {
            return nil
        }

        let value = rawValue.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !value.isEmpty, !value.hasPrefix("$(") else {
            return nil
        }

        return value
    }
}
