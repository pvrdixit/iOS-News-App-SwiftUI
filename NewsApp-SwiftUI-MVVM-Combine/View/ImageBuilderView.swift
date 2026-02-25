//
//  ImageBuilderView.swift
//  NewsApp-SwiftUI-MVVM-Combine
//
//  Created by Vijay Raj Dixit on 29/01/26.
//

import SwiftUI
import Kingfisher

struct ImageBuilderView: View {
    let imageURL: String?
    let placeholderImage: some View = Image("newsPlaceholder")
        .resizable()
        .scaledToFit()
    
    var body: some View {
        if let imageURL {
            KFImage(URL(string: imageURL))
                .placeholder {
                    placeholderImage
                }
                .onFailure { error in
                    print("Image load failed, \(error.localizedDescription)")
                }
                .resizable()
                .scaledToFit()
                .frame(maxHeight: 200)
        } else {
            placeholderImage
        }
    }
}

#Preview {
    ImageBuilderView(imageURL: "https://picsum.photos/seed/picsum/1800/900")
}
