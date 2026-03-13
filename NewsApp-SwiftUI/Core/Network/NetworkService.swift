//
//  NetworkService.swift
//  NewsApp-SwiftUI-MVVM-Combine
//
//  Created by Vijay Raj Dixit on 29/01/26.
//


import Foundation

/// Shared contract for executing decodable network requests.
protocol NetworkService {
    func requestAsync<T: Decodable>(_ request: URLRequest) async throws -> T
}
