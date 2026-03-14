//
//  ExploreCategory.swift
//  NewsApp-SwiftUI-MVVM-Combine
//
//  Created by Vijay Raj Dixit on 02/03/26.
//

import Foundation

/// Presentation model for one provider-specific explore category.
struct ExploreCategory: Identifiable, Equatable, Hashable {
    let id: String
    let title: String
}
