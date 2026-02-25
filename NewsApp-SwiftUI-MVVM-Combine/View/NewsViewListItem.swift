//
//  NewsViewListItem.swift
//  NewsApp-SwiftUI-MVVM-Combine
//
//  Created by Vijay Raj Dixit on 29/01/26.
//

import SwiftUI

struct NewsViewListItem: View {
    let authorName: String
    let date: String
    let headline: String
    let imageURL: String?
    
    var body: some View {
        VStack {
            HStack {
                Text(authorName)
                    .font(.system(size: 13))
                    .foregroundStyle(.primary.opacity(0.75))
                
                Spacer()
                Text(date)
                    .font(.system(size: 13))
                    .foregroundStyle(.primary.opacity(0.75))
            }
            
            ImageBuilderView(imageURL: imageURL)
                .frame(maxWidth: .infinity)
            
            Text(headline)
                .font(.system(size: 18))
                .frame(maxWidth: .infinity, alignment: .leading)
        }        
    }
}

#Preview {
    NewsViewListItem(authorName: "Author Name is very very long and might exceed the line", date: "28 Jan 2026, 10:23 AM", headline: "Headline is very very long and might exceed the line", imageURL: "https://picsum.photos/seed/picsum/1800/900")
}
