//
//  NetworkService.swift
//  NewsApp-SwiftUI-MVVM-Combine
//
//  Created by Vijay Raj Dixit on 29/01/26.
//


import Foundation
import Combine

protocol NetworkService {
    func request<T: Decodable>(_ request: URLRequest) -> AnyPublisher<T, Error>
    func requestAsync<T: Decodable>(_ request: URLRequest) async throws -> T
}
