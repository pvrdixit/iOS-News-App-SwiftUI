//
//  NewsProviderID.swift
//  NewsApp-SwiftUI
//
//  Created by Vijay Raj Dixit on 13/03/26.
//

import Foundation

/// Identifies the remote news provider selected for the current app session.
enum NewsProviderID: String {
    case newsAPI = "newsapi"
    case newsData = "newsdata"
    case gNews = "gnews"

    var displayName: String {
        switch self {
        case .newsAPI:
            return "NewsAPI"
        case .newsData:
            return "NewsData"
        case .gNews:
            return "GNews"
        }
    }
}
