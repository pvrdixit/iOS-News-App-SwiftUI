//
//  ArticleListItemView.swift
//  NewsApp-SwiftUI-MVVM-Combine
//
//  Created by Vijay Raj Dixit on 29/01/26.
//

import SwiftUI

/// Main reusable list row used anywhere the app renders an Article in feed-style lists.
struct ArticleListItemView: View {
    let credit: String
    let date: String
    let title: String
    let imageURL: String?
    
    var body: some View {
        VStack {
            HStack {
                Text(credit)
                    .font(.system(size: 13))
                    .foregroundStyle(.primary.opacity(0.75))
                    .lineLimit(2)
                    .truncationMode(.tail)
                
                Spacer()
                Text(date)
                    .font(.system(size: 13))
                    .foregroundStyle(.primary.opacity(0.75))
            }
            
            ImageBuilderView(imageURL: imageURL)
                .frame(maxWidth: .infinity)
            
            Text(title)
                .font(.system(size: 18))
                .frame(maxWidth: .infinity, alignment: .leading)
        }        
    }
}

#Preview {
    ArticleListItemView(credit: "Source or author name can be shown here", date: "28 Jan 2026, 10:23 AM", title: "Headline is very very long and might exceed the line", imageURL: "https://picsum.photos/seed/picsum/1800/900")
}
