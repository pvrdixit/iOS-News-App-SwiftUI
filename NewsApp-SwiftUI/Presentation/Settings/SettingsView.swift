//
//  SettingsView.swift
//  NewsApp-SwiftUI-MVVM-Combine
//
//  Created by Vijay Raj Dixit on 01/03/26.
//


import SwiftUI

/// Settings screen for region/language selection, app info, and destructive local-data actions.
struct SettingsView: View {
    @ObservedObject var viewModel: SettingsViewModel
    @State private var activeSelection: SettingsSelectionType?
    @State private var showSelectionBlockedAlert = false

    init(viewModel: SettingsViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        List {
            Section(viewModel.regionSectionTitle) {
                Button {
                    presentSelection(.country)
                } label: {
                    settingRow(title: viewModel.countryLabelTitle, value: viewModel.selectedCountryName)
                }
                .foregroundStyle(.primary)

                Button {
                    presentSelection(.language)
                } label: {
                    settingRow(title: viewModel.languageLabelTitle, value: viewModel.selectedLanguageName)
                }
                .foregroundStyle(.primary)
            }
            
            Section(viewModel.storageSectionTitle) {
                ForEach(viewModel.actions) { action in
                    Button {
                        viewModel.prompt(action)
                    } label: {
                        Label(action.labelTitle, systemImage: action.systemImage)
                    }
                }
            }

            Section(viewModel.aboutSectionTitle) {
                Link(destination: viewModel.openSourceURL) {
                    Label(viewModel.openSourceTitle, systemImage: viewModel.openSourceSystemImage)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text(viewModel.authorName)
                        .font(.headline)

                    Text(viewModel.authorRole)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    Text(viewModel.appDescription)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 4)
            }

            Section(viewModel.privacySectionTitle) {
                ForEach(viewModel.privacyItems) { item in
                    Label(item.title, systemImage: item.systemImage)
                }
            }
        }
        .navigationTitle(viewModel.navigationTitle)
        .navigationBarTitleDisplayMode(.inline)
        .showAlert(
            title: viewModel.confirmTitle,
            message: viewModel.confirmMessage,
            isPresented: $viewModel.showConfirmAlert,
            secondaryCancelButton: (viewModel.confirmCancelButtonTitle, { viewModel.clearPendingAction() }),
            destructiveAction: {
                viewModel.runPendingAction()
            }
        )
        .showAlert(message: viewModel.selectionBlockedMessage, isPresented: $showSelectionBlockedAlert)
        .sheet(item: $activeSelection) { selection in
            NavigationStack {
                switch selection {
                case .country:
                    SelectListView(
                        title: viewModel.selectCountryTitle,
                        items: viewModel.countryOptions,
                        selectedID: viewModel.selectedCountryCode
                    ) { item in
                        viewModel.selectCountry(code: item.id)
                    }
                case .language:
                    SelectListView(
                        title: viewModel.selectLanguageTitle,
                        items: viewModel.languageOptions,
                        selectedID: viewModel.selectedLanguageCode
                    ) { item in
                        viewModel.selectLanguage(code: item.id)
                    }
                }
            }
        }
    }
}

/// Identifies which searchable picker sheet should be presented from Settings.
private enum SettingsSelectionType: String, Identifiable {
    case country
    case language

    var id: String { rawValue }
}

private extension SettingsView {
    func presentSelection(_ selection: SettingsSelectionType) {
        guard viewModel.allowsRegionAndLanguageChanges else {
            showSelectionBlockedAlert = true
            return
        }

        activeSelection = selection
    }

    func settingRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
            Spacer()
            Text(value)
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    @MainActor in
    let appDI = AppDI.preview()
    return SettingsView(viewModel: appDI.makeSettingsViewModel())
        .environment(\.appDI, appDI)
}
