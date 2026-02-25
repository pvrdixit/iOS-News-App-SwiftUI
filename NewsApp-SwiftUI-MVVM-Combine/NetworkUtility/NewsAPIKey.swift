//
//  NewsAPIKey.swift
//  NewsApp-SwiftUI-MVVM-Combine
//
//  Created by Vijay Raj Dixit on 29/01/26.
//


import Foundation

enum NewsAPIKey {
    static let newsAPIKey: String = {
        guard let key = Bundle.main.infoDictionary?["API_KEY"] as? String else {
            fatalError("API_KEY not set")
        }
        print(key)
        return key
    }()
}
