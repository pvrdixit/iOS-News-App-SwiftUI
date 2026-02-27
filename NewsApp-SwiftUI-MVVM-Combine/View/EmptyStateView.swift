//
//  EmptyStateView.swift
//  NewsApp-SwiftUI-MVVM-Combine
//
//  Created by Vijay Raj Dixit on 27/02/26.
//

import SwiftUI

struct EmptyStateView: View {
    let title: String
    let message: String
    let buttonTitle: String?
    let action: (() -> Void)?

    var body: some View {
        VStack(spacing: 12) {
            Text(title).font(.title3).bold()
            Text(message).font(.body).multilineTextAlignment(.center)

            if let buttonTitle, let action {
                Button(buttonTitle, action: action)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}