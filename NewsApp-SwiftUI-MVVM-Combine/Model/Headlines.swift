//
//  Headlines.swift
//  NewsApp-SwiftUI-MVVM-Combine
//
//  Created by Vijay Raj Dixit on 29/01/26.
//


struct Headlines: Codable {
    let status: String
    let totalResults: Int
    let articles: [Article]
}
