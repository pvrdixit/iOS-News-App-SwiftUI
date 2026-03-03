//
//  APIConstants.swift
//  NewsApp-SwiftUI-MVVM-Combine
//
//  Created by Vijay Raj Dixit on 29/01/26.
//


import Foundation

enum APIConstants {
    static let scheme = "https"
    static let host = "newsapi.org"

    enum Path {
        static let topHeadlines = "/v2/top-headlines"
        static let everything = "/v2/everything"
    }

    enum Query {
        static let country = "country"
        static let apiKey  = "apiKey"
        static let page = "page"
        static let pageSize = "pageSize"
        static let search = "q"
        static let category = "category"
    }

    enum Default {
        static let country = "us"
    }

    enum Category {
        static let business = "business"
        static let entertainment = "entertainment"
        static let general = "general"
        static let health = "health"
        static let science = "science"
        static let sports = "sports"
        static let technology = "technology"
    }
}
