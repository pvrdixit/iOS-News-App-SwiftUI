//
//  NewsCacheStore.swift
//  NewsApp-SwiftUI-MVVM-Combine
//
//  Created by Vijay Raj Dixit on 25/02/26.
//

import Foundation

final class NewsCacheStore {
    private let fileManager: FileManager
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder
    private let fileURL: URL

    init(fileManager: FileManager = .default) {
        self.fileManager = fileManager
        self.encoder = JSONEncoder()
        self.decoder = JSONDecoder()
        self.encoder.dateEncodingStrategy = .iso8601
        self.decoder.dateDecodingStrategy = .iso8601

        let cachesURL = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first
            ?? fileManager.temporaryDirectory
        self.fileURL = cachesURL.appendingPathComponent("news_cache.json", isDirectory: false)
    }

    func load(context: String) throws -> CachedHeadlines? {
        guard fileManager.fileExists(atPath: fileURL.path) else {
            return nil
        }

        let data = try Data(contentsOf: fileURL)
        let payload = try decoder.decode(CachedHeadlines.self, from: data)
        guard payload.context == context else { return nil }

        return payload
    }

    func save(articles: [Article], context: String) throws {
        let payload = CachedHeadlines(
            context: context,
            cachedAt: Date(),
            articles: articles
        )

        let data = try encoder.encode(payload)
        try data.write(to: fileURL, options: .atomic)
    }
}
