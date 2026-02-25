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
    }

    enum Query {
        // Names of the query parameters
        static let country = "country"
        static let apiKey  = "apiKey"
    }

    enum Default {
        static let country = "us"
    }
}