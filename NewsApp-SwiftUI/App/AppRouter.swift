//
//  AppRouter.swift
//  NewsApp-SwiftUI
//
//  Created by Vijay Raj Dixit on 13/03/26.
//

import SwiftUI

/// Hosts the tab-based app navigation and owns one view model per top-level screen.
struct AppRouter: View {
    @StateObject private var homeViewModel: HomeViewModel
    @StateObject private var exploreViewModel: ExploreViewModel
    @StateObject private var bookmarksViewModel: BookmarksViewModel
    @StateObject private var settingsViewModel: SettingsViewModel

    @MainActor
    init(appDI: AppDI) {
        _homeViewModel = StateObject(wrappedValue: appDI.makeHomeViewModel())
        _exploreViewModel = StateObject(wrappedValue: appDI.makeExploreViewModel())
        _bookmarksViewModel = StateObject(wrappedValue: appDI.makeBookmarksViewModel())
        _settingsViewModel = StateObject(wrappedValue: appDI.makeSettingsViewModel())
    }

    var body: some View {
        TabView {
            NavigationStack {
                HomeView(viewModel: homeViewModel)
            }
            .tabItem { Label("Home", systemImage: "house") }

            NavigationStack {
                ExploreView(viewModel: exploreViewModel)
            }
            .tabItem { Label("Explore", systemImage: "safari") }

            NavigationStack {
                BookmarksView(viewModel: bookmarksViewModel)
            }
            .tabItem { Label("Bookmarks", systemImage: "bookmark") }

            NavigationStack {
                SettingsView(viewModel: settingsViewModel)
            }
            .tabItem { Label("Settings", systemImage: "gearshape") }
        }
    }
}
