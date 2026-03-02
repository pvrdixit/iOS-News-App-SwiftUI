//
//  SettingsView.swift
//  NewsApp-SwiftUI-MVVM-Combine
//
//  Created by Vijay Raj Dixit on 01/03/26.
//


import SwiftUI

struct SettingsView: View {
    @ObservedObject var viewModel: SettingsViewModel

    init(viewModel: SettingsViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        List {
            Section("Region") {
                HStack {
                    Label("Region", systemImage: "globe")
                    Spacer()
                    Text("US").foregroundStyle(.secondary)
                }
            }
            
            Section("Storage") {
                ForEach(viewModel.actions) { action in
                    Button {
                        viewModel.prompt(action)
                    } label: {
                        Label(action.labelTitle, systemImage: action.systemImage)
                    }
                }
            }

            Section("About") {
                Link(destination: URL(string: "https://github.com/pvrdixit")!) {
                    Label("Open Source", systemImage: "link")
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Vijay Raj Dixit")
                        .font(.headline)

                    Text("iOS Freelance Developer • SwiftUI / UIKit")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    Text("Production-grade News app showcasing MVVM, caching, pagination, and structured logging.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 4)
            }

            Section("Privacy") {
                Label("No Ads", systemImage: "checkmark.seal")
                Label("No data collection", systemImage: "hand.raised")
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .showAlert(
            title: viewModel.confirmTitle,
            message: viewModel.confirmMessage,
            isPresented: $viewModel.showConfirmAlert,
            secondaryCancelButton: ("Cancel", { viewModel.clearPendingAction() }),
            destructiveAction: {
                viewModel.runPendingAction()
            }
        )
    }
}

#Preview {
    @MainActor in
    let dependencies = AppDependencies()
    return SettingsView(viewModel: dependencies.makeSettingsViewModel())
        .environment(\.appDependencies, dependencies)
}
