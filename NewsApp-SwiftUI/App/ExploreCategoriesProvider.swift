//
//  ExploreCategoriesProvider.swift
//  NewsApp-SwiftUI
//
//  Created by Vijay Raj Dixit on 13/03/26.
//

import Foundation

/// Supplies the explore categories available for each configured news provider.
enum ExploreCategoriesProvider {
    static func categories(for providerID: NewsProviderID) -> [ExploreCategory] {
        switch providerID {
        case .newsAPI:
            return NewsAPISupportedCategories.supportedCategories.map {
                ExploreCategory(id: $0.rawValue, title: $0.displayName)
            }
        case .newsData:
            return NewsDataSupportedCategories.supportedCategories.map {
                ExploreCategory(id: $0.rawValue, title: $0.displayName)
            }
        case .gNews:
            return GNewsSupportedCategories.supportedCategories.map {
                ExploreCategory(id: $0.rawValue, title: $0.displayName)
            }
        }
    }
}
