//
//  CategoryChips.swift
//  NewsApp-SwiftUI-MVVM-Combine
//
//  Created by Vijay Raj Dixit on 02/03/26.
//

import SwiftUI

/// Horizontal selector used to switch between explore categories.
struct CategoryChips: View {
    @Binding var selected: ExploreCategory
    let categories: [ExploreCategory]
    @Namespace private var chipSelectionAnimation

    private let maxVisibleCategories = 5

    private var visibleCategories: [ExploreCategory] {
        let defaultVisibleCategories = Array(categories.prefix(maxVisibleCategories))
        guard !defaultVisibleCategories.contains(selected) else {
            return defaultVisibleCategories
        }

        var visibleCategories = Array(categories.prefix(maxVisibleCategories - 1))
        visibleCategories.append(selected)
        return visibleCategories
    }

    private var hiddenCategories: [ExploreCategory] {
        categories.filter { !visibleCategories.contains($0) }
    }

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 0) {
                ForEach(visibleCategories) { category in
                    Button {
                        selectCategory(category)
                    } label: {
                        chipView(title: category.title, isSelected: category == selected)
                    }
                    .buttonStyle(.plain)
                }

                if !hiddenCategories.isEmpty {
                    moreMenuView
                }
            }
        }
    }
}

private extension CategoryChips {
    var moreMenuView: some View {
        Menu {
            ForEach(hiddenCategories) { category in
                Button(category.title) {
                    selectCategory(category)
                }
            }
        } label: {
            chipView(title: "More", isSelected: false, showsDisclosure: true)
        }
        .buttonStyle(.plain)
        .opacity(1)
    }

    func selectCategory(_ category: ExploreCategory) {
        guard selected != category else { return }

        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            selected = category
        }
    }

    func chipView(title: String, isSelected: Bool, showsDisclosure: Bool = false) -> some View {
        VStack(spacing: 4) {
            HStack(spacing: 6) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(isSelected ? .semibold : .regular)

                if showsDisclosure {
                    Image(systemName: "chevron.down")
                        .font(.caption2.weight(.semibold))
                }
            }
            .foregroundStyle(.primary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)

            chipIndicator(isSelected: isSelected)
        }
    }

    @ViewBuilder
    func chipIndicator(isSelected: Bool) -> some View {
        if isSelected {
            RoundedRectangle(cornerRadius: 2)
                .fill(Color.accent)
                .frame(height: 2)
                .matchedGeometryEffect(id: "indicator", in: chipSelectionAnimation)
        } else {
            Color.clear.frame(height: 2)
        }
    }
}

#Preview {
    @Previewable @State var selected = ExploreCategory(id: "general", title: "General")
    CategoryChips(selected: $selected, categories: ExploreCategoriesProvider.categories(for: .newsAPI))
}
