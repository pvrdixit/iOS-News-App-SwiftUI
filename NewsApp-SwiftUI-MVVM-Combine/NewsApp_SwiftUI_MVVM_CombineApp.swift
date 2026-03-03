//
//  NewsApp_SwiftUI_MVVM_CombineApp.swift
//  NewsApp-SwiftUI-MVVM-Combine
//
//  Created by Vijay Raj Dixit on 29/01/26.
//

import SwiftUI

@main
struct NewsApp_SwiftUI_MVVM_CombineApp: App {
    private let dependencies: AppDependencies
    @StateObject private var homeVM: NewsViewModel
    @StateObject private var exploreVM: ExploreViewModel
    @StateObject private var bookmarksVM: BookmarksViewModel
    @StateObject private var settingsVM: SettingsViewModel
    
    @MainActor
    init() {
        let dependencies = AppDependencies()
        self.dependencies = dependencies
        _homeVM = StateObject(wrappedValue:
                                dependencies.makeNewsViewModel()
        )

        _exploreVM = StateObject(wrappedValue:
                                    dependencies.makeExploreViewModel()
        )
        
        _bookmarksVM = StateObject(wrappedValue:
                                    dependencies.makeBookmarksViewModel()
        )

        _settingsVM = StateObject(wrappedValue:
                                    dependencies.makeSettingsViewModel()
        )
    }
    
    var body: some Scene {
        WindowGroup {
            TabView {
                NavigationStack { NewsView(viewModel: homeVM) }
                    .tabItem { Label("Home", systemImage: "house") }
                
                NavigationStack { ExploreView(viewModel: exploreVM) }
                .tabItem { Label("Explore", systemImage: "safari") }
                
                NavigationStack { BookmarksView(viewModel: bookmarksVM) }
                    .tabItem { Label("Bookmarks", systemImage: "bookmark") }

                NavigationStack { SettingsView(viewModel: settingsVM) }
                .tabItem { Label("Settings", systemImage: "gearshape") }
            }
            .environment(\.appDependencies, dependencies)
        }
    }
}
