//
//  SettingsViewModel.swift
//  NewsApp-SwiftUI-MVVM-Combine
//
//  Created by Vijay Raj Dixit on 01/03/26.
//

import Foundation
import Combine

/// Presentation model describing one destructive storage action exposed from Settings.
struct ClearDataAction: Identifiable {
    let id: String
    let title: String
    let message: String
    let labelTitle: String
    let systemImage: String
    let logCategory: LogCategory
    let perform: () throws -> Void
}

/// Small presentation model for static informational rows shown in Settings.
struct SettingsLabelItem: Identifiable {
    let id: String
    let title: String
    let systemImage: String
}

@MainActor
/// Presentation state container for the settings screen and its destructive actions.
final class SettingsViewModel: ObservableObject {
    let navigationTitle = "Settings"
    let regionSectionTitle = "Region"
    let regionLabelTitle = "Region"
    let regionLabelSystemImage = "globe"
    let regionCode: String
    let storageSectionTitle = "Storage"
    let aboutSectionTitle = "About"
    let openSourceTitle = "Open Source"
    let openSourceSystemImage = "link"
    let openSourceURL = URL(string: "https://github.com/pvrdixit")!
    let authorName = "Vijay Raj Dixit"
    let authorRole = "iOS Freelance Developer • SwiftUI / UIKit"
    let appDescription = "Production-grade News app showcasing MVVM, caching, pagination, and structured logging."
    let privacySectionTitle = "Privacy"
    let confirmCancelButtonTitle = "Cancel"
    private let defaultConfirmTitle = "Confirm"

    @Published var pendingAction: ClearDataAction?
    @Published var showConfirmAlert = false

    let actions: [ClearDataAction]
    let privacyItems: [SettingsLabelItem] = [
        SettingsLabelItem(id: "noAds", title: "No Ads", systemImage: "checkmark.seal"),
        SettingsLabelItem(id: "noDataCollection", title: "No data collection", systemImage: "hand.raised")
    ]
    private let logger: LoggerService

    init(
        newsCacheRepository: NewsCacheRepository,
        bookmarkRepository: BookmarkRepository,
        recentHistoryRepository: RecentHistoryRepository,
        regionCode: String,
        logger: LoggerService
    ) {
        self.logger = logger
        self.regionCode = regionCode

        self.actions = [
            ClearDataAction(
                id: "clearCache",
                title: "Confirm",
                message: "Clear cached headlines? The app will refetch from network.",
                labelTitle: "Clear cache",
                systemImage: "trash",
                logCategory: .cache,
                perform: { try newsCacheRepository.clear() }
            ),
            ClearDataAction(
                id: "clearBookmarks",
                title: "Confirm",
                message: "Clear all bookmarks? This cannot be undone.",
                labelTitle: "Clear bookmarks",
                systemImage: "bookmark",
                logCategory: .bookmark,
                perform: { try bookmarkRepository.clear() }
            ),
            ClearDataAction(
                id: "clearHistory",
                title: "Confirm",
                message: "Clear recent history? This cannot be undone.",
                labelTitle: "Clear history",
                systemImage: "clock.arrow.circlepath",
                logCategory: .recent,
                perform: { try recentHistoryRepository.clear() }
            )
        ]
    }

    var confirmTitle: String {
        pendingAction?.title ?? defaultConfirmTitle
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
