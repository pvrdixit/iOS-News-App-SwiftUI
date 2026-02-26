//
//  NewsApp_SwiftUI_MVVM_CombineApp.swift
//  NewsApp-SwiftUI-MVVM-Combine
//
//  Created by Vijay Raj Dixit on 29/01/26.
//

import SwiftUI

@main
struct NewsApp_SwiftUI_MVVM_CombineApp: App {
    var body: some Scene {
        WindowGroup {
            let newsResource = NewsResource()
            let newsViewModel = NewsViewModel(resource: newsResource)
            NewsView(viewModel: newsViewModel)
        }
    }
}
