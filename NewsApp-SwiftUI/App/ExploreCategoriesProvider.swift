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
            return [
                .general,
                .business,
                .technology,
                .sports,
                .entertainment,
                .health,
                .science
            ]
        case .newsData:
            return [
                .top,
                .breaking,
                .crime,
                .domestic,
                .world,
                .business,
                .technology,
                .sports,
                .entertainment,
                .education,
                .lifestyle,
                .science,
                .health
            ]
        }
    }
}
