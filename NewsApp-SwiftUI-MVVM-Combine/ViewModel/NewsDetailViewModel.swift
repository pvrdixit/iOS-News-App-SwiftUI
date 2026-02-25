//
//  NewsDetailViewModel.swift
//  NewsApp-SwiftUI-MVVM-Combine
//
//  Created by Vijay Raj Dixit on 25/02/26.
//

import SwiftUI
import Combine
import WebKit

@MainActor
final class NewsDetailViewModel: ObservableObject {
    @Published private(set) var isLoading: Bool = false
    @Published var alertMessage: String? = nil
    
    let page = WebPage()
    private var currentURL: URL?
    
    func load(url: URL) async {
        guard !isLoading else { return }
        
        currentURL = url
        isLoading = true
        alertMessage = nil
        
        do {
            for try await event in page.load(url) {
                if event == .committed || event == .finished {
                    isLoading = false
                    return
                }
            }
            isLoading = false
        } catch {
            isLoading = false
            alertMessage = processErrorForUI(from: error)
        }
    }
    
    func retry() async {
        guard let currentURL else { return }
        await load(url: currentURL)
    }
    
    func dismissError() {
        alertMessage = nil
    }
    
    // Map low-level errors to user-facing messages
    private func processErrorForUI(from error: Error) -> String {
        if let navigationError = error as? WebPage.NavigationError {
            return NavigationErrorMapper.message(from: navigationError, viewType: .newsDetailView)
        } else {
            return NetworkErrorMapper.message(from: error, viewType: .newsDetailView)
        }
    }
}
