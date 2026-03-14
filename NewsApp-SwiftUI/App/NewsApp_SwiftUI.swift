//
//  NewsApp_SwiftUI.swift
//  NewsApp-SwiftUI
//
//  Created by Vijay Raj Dixit on 29/01/26.
//

import SwiftUI

@main
/// Application entry point that wires the root dependency container into the UI tree.
struct NewsApp_SwiftUI: App {
    private let appDI: AppDI

    @MainActor
    init() {
        appDI = AppDI(
            selectedNewsProvider: .gNews
        )
    }

    var body: some Scene {
        WindowGroup {
            AppRouter(appDI: appDI)
                .environment(\.appDI, appDI)
        }
    }
}
