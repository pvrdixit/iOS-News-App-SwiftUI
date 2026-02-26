//
//  NewsDetailView.swift
//  NewsApp-SwiftUI-MVVM-Combine
//
//  Created by Vijay Raj Dixit on 30/01/26.
//

import SwiftUI
import WebKit

struct NewsDetailView: View {
    @StateObject private var viewModel = NewsDetailViewModel()
    let url: URL

    /// NewsDetailView
    var body: some View {
        WebView(viewModel.page)
            .ignoresSafeArea()
            .overlay {
                if viewModel.isLoading {
                    ProgressView()
                }
            }
            .task(id: url) {
                await viewModel.load(url: url)
            }
            .showAlert(
                message: errorAlertMessage,
                isPresented: errorAlertBinding,
                primaryRightButton: (
                    title: "Retry",
                    action: {
                        Task { await viewModel.retry() }
                    }
                )
            )
    }
}

/// Error Alerts
private extension NewsDetailView {
    var errorAlertMessage: String {
        viewModel.alertMessage ?? "Unable to load this article."
    }

    var errorAlertBinding: Binding<Bool> {
        Binding(
            get: { viewModel.alertMessage != nil },
            set: { newValue in
                if !newValue { viewModel.dismissError() }
            }
        )
    }
}

#Preview {
    NewsDetailView(url: URL(string: "https://www.apple.com")!)
}
