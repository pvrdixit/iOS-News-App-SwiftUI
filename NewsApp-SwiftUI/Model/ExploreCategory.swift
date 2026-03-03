//
//  ExploreCategory.swift
//  NewsApp-SwiftUI-MVVM-Combine
//
//  Created by Vijay Raj Dixit on 02/03/26.
//

import Foundation

enum ExploreCategory: String, CaseIterable, Identifiable {
    case all
    case business
    case technology
    case sports
    case health
    case entertainment

    var id: Self { self }

    var title: String {
        switch self {
        case .all:
            return "All"
        case .business:
            return "Business"
        case .technology:
            return "Tech"
        case .sports:
            return "Sports"
        case .health:
            return "Health"
        case .entertainment:
            return "Entertainment"
        }
    }

    var apiValue: String? {
        self == .all ? nil : rawValue
    }
}
