//
//  JSONFileStore.swift
//  NewsApp-SwiftUI-MVVM-Combine
//
//  Created by Vijay Raj Dixit on 27/02/26.
//

import Foundation

final class JSONFileStore<Payload: Codable> {
    private let fileManager: FileManager
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder
    private let fileURL: URL

    init(target: NewsStoreTarget) {
        self.fileManager = .default
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()
        encoder.dateEncodingStrategy = .iso8601
        decoder.dateDecodingStrategy = .iso8601
        self.encoder = encoder
        self.decoder = decoder

        let baseURL = fileManager.urls(for: target.directory, in: .userDomainMask).first
            ?? fileManager.temporaryDirectory

        self.fileURL = baseURL.appendingPathComponent(target.fileName, isDirectory: false)
    }

    func load() throws -> Payload? {
        guard fileManager.fileExists(atPath: fileURL.path) else { return nil }
        let data = try Data(contentsOf: fileURL)
        return try decoder.decode(Payload.self, from: data)
    }

    func save(_ payload: Payload) throws {
        let data = try encoder.encode(payload)
        try data.write(to: fileURL, options: .atomic)
    }

    func delete() throws {
        guard fileManager.fileExists(atPath: fileURL.path) else { return }
        try fileManager.removeItem(at: fileURL)
    }
}
