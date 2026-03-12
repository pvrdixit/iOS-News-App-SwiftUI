//
//  CategoryChips.swift
//  NewsApp-SwiftUI-MVVM-Combine
//
//  Created by Vijay Raj Dixit on 02/03/26.
//

import SwiftUI

struct CategoryChips: View {
    @Binding var selected: ExploreCategory
    let categories: [ExploreCategory]

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(categories) { category in
                    Button {
                        selected = category
                    } label: {
                        Text(category.title)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(
                                Capsule()
                                    .fill(category == selected ? Color.accent  : Color.secondary.opacity(0.1))
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.vertical, 4)
        }
    }
}

#Preview {
    @Previewable @State var selected: ExploreCategory = .all
    CategoryChips(selected: $selected, categories: ExploreCategory.allCases)
}
