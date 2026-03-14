import SwiftUI

/// Simple option model used by the searchable selection list for country and language picking.
struct SelectListItem: Identifiable, Hashable {
    let id: String
    let title: String
}

/// Searchable list view used to select a country or language from a long option set.
struct SelectListView: View {
    let title: String
    let items: [SelectListItem]
    let selectedID: String
    let onSelect: (SelectListItem) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""

    var body: some View {
        List(filteredItems) { item in
            Button {
                onSelect(item)
                dismiss()
            } label: {
                HStack {
                    Text(item.title)
                    Spacer()
                    if item.id == selectedID {
                        Image(systemName: "checkmark")
                            .foregroundStyle(.accent)
                    }
                }
            }
            .foregroundStyle(.primary)
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
        .searchable(text: $searchText, prompt: "Search")
    }
}

private extension SelectListView {
    var filteredItems: [SelectListItem] {
        let trimmedSearch = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedSearch.isEmpty else { return items }

        return items.filter {
            $0.title.localizedCaseInsensitiveContains(trimmedSearch)
        }
    }
}
