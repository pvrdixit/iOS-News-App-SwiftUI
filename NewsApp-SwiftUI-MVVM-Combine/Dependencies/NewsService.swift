//
//  NewsService.swift
//  NewsApp-SwiftUI-MVVM-Combine
//
//  Created by Vijay Raj Dixit on 28/02/26.
//


protocol NewsService {
    func fetchTopHeadlines(page: Int, pageSize: Int) async throws -> Headlines
}