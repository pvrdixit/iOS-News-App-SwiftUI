//
//  ExploreCategory.swift
//  NewsApp-SwiftUI-MVVM-Combine
//
//  Created by Vijay Raj Dixit on 02/03/26.
//

import Foundation

/// Presentation-friendly explore categories with display titles and domain mappings.
enum ExploreCategory: String, Identifiable {
    case top
    case general
    case breaking
    case crime
    case domestic
    case world
    case business
    case technology
    case sports
    case entertainment
    case education
    case lifestyle
    case science
    case health

    var id: Self { self }

    var title: String {
        switch self {
        case .top:
            return "Top"
        case .general:
            return "General"
        case .breaking:
            return "Breaking"
        case .crime:
            return "Crime"
        case .domestic:
            return "Domestic"
        case .world:
            return "World"
        case .business:
            return "Business"
        case .technology:
            return "Tech"
        case .sports:
            return "Sports"
        case .entertainment:
            return "Entertainment"
        case .education:
            return "Education"
        case .lifestyle:
            return "Lifestyle"
        case .science:
            return "Science"
        case .health:
            return "Health"
        }
    }

    var domainValue: NewsCategory {
        switch self {
        case .top:
            return .top
        case .general:
            return .general
        case .breaking:
            return .breaking
        case .crime:
            return .crime
        case .domestic:
            return .domestic
        case .world:
            return .world
        case .business:
            return .business
        case .technology:
            return .technology
        case .sports:
            return .sports
        case .entertainment:
            return .entertainment
        case .education:
            return .education
        case .lifestyle:
            return .lifestyle
        case .science:
            return .science
        case .health:
            return .health
        }
    }
}
