//
//  SettingsView.swift
//  NewsApp-SwiftUI-MVVM-Combine
//
//  Created by Vijay Raj Dixit on 01/03/26.
//


import SwiftUI

/// Settings screen for read-only app info and destructive local-data actions.
struct SettingsView: View {
    @ObservedObject var viewModel: SettingsViewModel

    init(viewModel: SettingsViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        List {
            Section(viewModel.regionSectionTitle) {
                HStack {
                    Label(viewModel.regionLabelTitle, systemImage: viewModel.regionLabelSystemImage)
                    Spacer()
                    Text(viewModel.regionCode).foregroundStyle(.secondary)
                }
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
    }
}

#Preview {
    @MainActor in
    let appDI = AppDI.preview()
    return SettingsView(viewModel: appDI.makeSettingsViewModel())
        .environment(\.appDI, appDI)
}
