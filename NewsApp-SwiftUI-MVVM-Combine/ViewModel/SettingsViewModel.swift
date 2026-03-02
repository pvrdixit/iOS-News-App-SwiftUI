//
//  SettingsViewModel.swift
//  NewsApp-SwiftUI-MVVM-Combine
//
//  Created by Vijay Raj Dixit on 01/03/26.
//

import Foundation
import Combine

struct ClearDataAction: Identifiable {
    let id: String
    let title: String
    let message: String
    let labelTitle: String
    let systemImage: String
    let logCategory: LogCategory
    let perform: () throws -> Void
}

@MainActor
final class SettingsViewModel: ObservableObject {
    @Published var pendingAction: ClearDataAction?
    @Published var showConfirmAlert = false

    let actions: [ClearDataAction]
    private let logger: LoggerService

    init(
        newsCache: NewsCacheStore,
        bookmarksStore: BookmarkStore,
        recentHistory: RecentHistoryStore,
        logger: LoggerService
    ) {
        self.logger = logger

        self.actions = [
            ClearDataAction(
                id: "clearCache",
                title: "Confirm",
                message: "Clear cached headlines? The app will refetch from network.",
                labelTitle: "Clear cache",
                systemImage: "trash",
                logCategory: .cache,
                perform: { try newsCache.clear() }
            ),
            ClearDataAction(
                id: "clearBookmarks",
                title: "Confirm",
                message: "Clear all bookmarks? This cannot be undone.",
                labelTitle: "Clear bookmarks",
                systemImage: "bookmark",
                logCategory: .bookmark,
                perform: { try bookmarksStore.clear() }
            ),
            ClearDataAction(
                id: "clearHistory",
                title: "Confirm",
                message: "Clear recent history? This cannot be undone.",
                labelTitle: "Clear history",
                systemImage: "clock.arrow.circlepath",
                logCategory: .recent,
                perform: { try recentHistory.clear() }
            )
        ]
    }

    var confirmTitle: String {
        pendingAction?.title ?? "Confirm"
    }

    var confirmMessage: String {
        pendingAction?.message ?? ""
    }

    func prompt(_ action: ClearDataAction) {
        pendingAction = action
        showConfirmAlert = true
    }

    func clearPendingAction() {
        pendingAction = nil
        showConfirmAlert = false
    }

    func runPendingAction() {
        guard let pendingAction else { return }

        do {
            try pendingAction.perform()
        } catch {
            logger.error(
                "Settings clear failed",
                category: pendingAction.logCategory,
                metadata: ["error": error.localizedDescription]
            )
        }

        clearPendingAction()
    }
}
