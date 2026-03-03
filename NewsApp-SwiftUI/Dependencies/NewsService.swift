//
//  NewsService.swift
//  NewsApp-SwiftUI-MVVM-Combine
//
//  Created by Vijay Raj Dixit on 28/02/26.
//


protocol NewsService {
    func fetchTopHeadlines(search: String?, category: String?, page: Int, pageSize: Int) async throws -> Headlines
}
