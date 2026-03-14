//
//  String+Extension.swift
//  NewsApp-SwiftUI
//
//  Created by Vijay Raj Dixit on 14/03/26.
//

extension String {
    var firstCapitalized: String {
        guard let first = self.first else { return self }
        return first.uppercased() + self.dropFirst().lowercased()
    }
}
