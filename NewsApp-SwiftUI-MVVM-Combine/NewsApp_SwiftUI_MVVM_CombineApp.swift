//
//  NewsApp_SwiftUI_MVVM_CombineApp.swift
//  NewsApp-SwiftUI-MVVM-Combine
//
//  Created by Vijay Raj Dixit on 29/01/26.
//

import SwiftUI

@main
struct NewsApp_SwiftUI_MVVM_CombineApp: App {

    private let newsResource = NewsResource()
    @StateObject private var homeVM: NewsViewModel

    init() {
        _homeVM = StateObject(wrappedValue: NewsViewModel(resource: NewsResource()))
    }

    var body: some Scene {
        WindowGroup {
            TabView {
                NavigationStack {
                    NewsView(viewModel: homeVM)
                }
                .tabItem { Label("Home", systemImage: "house") }

                NavigationStack {
                    PlaceholderTabView(title: "Explore")
                }
                .tabItem { Label("Explore", systemImage: "safari") }

                NavigationStack {
                    PlaceholderTabView(title: "Bookmarks")
                }
                .tabItem { Label("Bookmarks", systemImage: "bookmark") }

                NavigationStack {
                    PlaceholderTabView(title: "Settings")
                }
                .tabItem { Label("Settings", systemImage: "gearshape") }
            }
        }
    }
}

private struct PlaceholderTabView: View {
    let title: String

    var body: some View {
        Text(title)
    }
}
