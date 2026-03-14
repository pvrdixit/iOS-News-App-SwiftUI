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
/// Presentation state container for settings, including NewsData region/language selection and clear-data actions.
final class SettingsViewModel: ObservableObject {
    let navigationTitle = "Settings"
    let regionSectionTitle = "Region & Language"
    let countryLabelTitle = "Country"
    let languageLabelTitle = "Language"
    let selectionBlockedMessage = "Sorry country change and language change is not allowed for current source"
    let selectCountryTitle = "Select Country"
    let selectLanguageTitle = "Select Language"
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
    @Published private(set) var selectedCountryCode: String
    @Published private(set) var selectedLanguageCode: String

    let actions: [ClearDataAction]
    let countryOptions: [SelectListItem]
    let languageOptions: [SelectListItem]
    let privacyItems: [SettingsLabelItem] = [
        SettingsLabelItem(id: "noAds", title: "No Ads", systemImage: "checkmark.seal"),
        SettingsLabelItem(id: "noDataCollection", title: "No data collection", systemImage: "hand.raised")
    ]
    private let newsCacheRepository: NewsCacheRepository
    private let logger: LoggerService
    let allowsRegionAndLanguageChanges: Bool
    private let saveCountryCode: (String) -> Void
    private let saveLanguageCode: (String) -> Void
    private let notifyPreferenceChanged: () -> Void

    init(
        newsCacheRepository: NewsCacheRepository,
        bookmarkRepository: BookmarkRepository,
        recentHistoryRepository: RecentHistoryRepository,
        allowsRegionAndLanguageChanges: Bool,
        selectedCountryCode: String,
        selectedLanguageCode: String,
        countryOptions: [SelectListItem],
        languageOptions: [SelectListItem],
        saveCountryCode: @escaping (String) -> Void,
        saveLanguageCode: @escaping (String) -> Void,
        notifyPreferenceChanged: @escaping () -> Void,
        logger: LoggerService
    ) {
        self.newsCacheRepository = newsCacheRepository
        self.logger = logger
        self.allowsRegionAndLanguageChanges = allowsRegionAndLanguageChanges
        self.selectedCountryCode = selectedCountryCode
        self.selectedLanguageCode = selectedLanguageCode
        self.countryOptions = countryOptions
        self.languageOptions = languageOptions
        self.saveCountryCode = saveCountryCode
        self.saveLanguageCode = saveLanguageCode
        self.notifyPreferenceChanged = notifyPreferenceChanged

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

    var selectedCountryName: String {
        displayName(for: selectedCountryCode, in: countryOptions, fallback: selectedCountryCode.uppercased())
    }

    var selectedLanguageName: String {
        displayName(for: selectedLanguageCode, in: languageOptions, fallback: selectedLanguageCode.uppercased())
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
                metadata: [
                    "action": pendingAction.id,
                    "error": error.localizedDescription
                ]
            )
        }

        clearPendingAction()
    }

    func selectCountry(code: String) {
        guard allowsRegionAndLanguageChanges else { return }
        guard selectedCountryCode != code else { return }

        selectedCountryCode = code
        saveCountryCode(code)
        handlePreferenceChange()
    }

    func selectLanguage(code: String) {
        guard allowsRegionAndLanguageChanges else { return }
        guard selectedLanguageCode != code else { return }

        selectedLanguageCode = code
        saveLanguageCode(code)
        handlePreferenceChange()
    }
}

private extension SettingsViewModel {
    func handlePreferenceChange() {
        do {
            try newsCacheRepository.clear()
        } catch {
            logger.error(
                "Cache clear failed after region/language update",
                category: .cache,
                metadata: ["error": error.localizedDescription]
            )
        }

        notifyPreferenceChanged()
    }

    func displayName(for code: String, in options: [SelectListItem], fallback: String) -> String {
        options.first(where: { $0.id == code })?.title ?? fallback
    }
}
