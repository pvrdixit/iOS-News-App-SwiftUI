//
//  ExploreCategory.swift
//  NewsApp-SwiftUI-MVVM-Combine
//
//  Created by Vijay Raj Dixit on 02/03/26.
//

import Foundation

/// Presentation-friendly explore categories with display titles and domain mappings.
enum ExploreCategory: String, Identifiable {
    case general
    case top
    case world
    case business
    case technology
    case sports
    case entertainment
    case education
    case environment
    case lifestyle
    case science
    case health

    var id: Self { self }

    var title: String {
        switch self {
        case .general:
            return "General"
        case .top:
            return "Top"
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
        case .environment:
            return "Environment"
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
        case .general:
            return .general
        case .top:
            return .top
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
        case .environment:
            return .environment
        case .lifestyle:
            return .lifestyle
        case .science:
            return .science
        case .health:
            return .health
        }
    }
}
