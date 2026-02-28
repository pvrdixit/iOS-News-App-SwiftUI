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
    @StateObject private var bookmarksVM: BookmarksViewModel
    
    @MainActor
    init() {
        let dependencies = AppDependencies()
        self.dependencies = dependencies
        _homeVM = StateObject(wrappedValue:
                                dependencies.makeNewsViewModel()
        )
        
        _bookmarksVM = StateObject(wrappedValue:
                                    dependencies.makeBookmarksViewModel()
        )
    }
    
    var body: some Scene {
        WindowGroup {
            TabView {
                NavigationStack { NewsView(viewModel: homeVM) }
                    .tabItem { Label("Home", systemImage: "house") }
                
                NavigationStack {
                    PlaceholderTabView(title: "Explore")
                }
                .tabItem { Label("Explore", systemImage: "safari") }
                
                NavigationStack { BookmarksView(viewModel: bookmarksVM) }
                    .tabItem { Label("Bookmarks", systemImage: "bookmark") }
                
                NavigationStack {
                    PlaceholderTabView(title: "Settings")
                }
                .tabItem { Label("Settings", systemImage: "gearshape") }
            }
            .environment(\.appDependencies, dependencies)
        }
    }
}

private struct PlaceholderTabView: View {
    let title: String

    var body: some View {
        Text(title)
    }
}
