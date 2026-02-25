//
//  NewsDetailView.swift
//  NewsApp-SwiftUI-MVVM-Combine
//
//  Created by Vijay Raj Dixit on 30/01/26.
//

import SwiftUI
import WebKit

struct NewsDetailView: View {
    let url: URL

    var body: some View {
        VStack {
            WebView(url: url)
                .ignoresSafeArea()
        }
    }
}

#Preview {
    NewsDetailView(url: URL(string: "https://www.apple.com")!)
}
