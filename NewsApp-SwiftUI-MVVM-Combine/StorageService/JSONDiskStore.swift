//
//  JSONDiskStore.swift
//  NewsApp-SwiftUI-MVVM-Combine
//
//  Created by Vijay Raj Dixit on 28/02/26.
//


import Foundation

/// Persists a Codable payload to a single JSON file on disk.
/// Used by bookmarks, recent history, and headline cache stores.
final class JSONDiskStore {
    private let fileManager: FileManager = .default
    private let encoder: JSONEncoder = JSONEncoder()
    private let decoder: JSONDecoder = JSONDecoder()
    private let fileURL: URL
    
    init(fileName: String, directory: FileManager.SearchPathDirectory) {
        encoder.dateEncodingStrategy = .iso8601
        decoder.dateDecodingStrategy = .iso8601
        
        let baseURL = fileManager.urls(for: directory, in: .userDomainMask).first
        ?? fileManager.temporaryDirectory
        
        self.fileURL = baseURL.appendingPathComponent(fileName, isDirectory: false)
    }
    
    func load<T: Decodable>(_ type: T.Type) throws -> T? {
        guard fileManager.fileExists(atPath: fileURL.path) else { return nil }
        let data = try Data(contentsOf: fileURL)
        return try decoder.decode(T.self, from: data)
    }
    
    func save<T: Encodable>(_ value: T) throws {
        let data = try encoder.encode(value)
        try data.write(to: fileURL, options: .atomic)
    }
    
    func delete() throws {
        guard fileManager.fileExists(atPath: fileURL.path) else { return }
        try fileManager.removeItem(at: fileURL)
    }
}
