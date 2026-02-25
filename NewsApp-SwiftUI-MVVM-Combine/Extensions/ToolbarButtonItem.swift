//
//  ToolbarButtonItem.swift
//  NewsApp-SwiftUI-MVVM-Combine
//
//  Created by Vijay Raj Dixit on 30/01/26.
//


import SwiftUI

public struct ToolbarButtonItem: ToolbarContent {
    private let title: String
    private let placement: ToolbarItemPlacement
    private let isDisabled: Bool
    private let action: () -> Void
    
    public init(title: String,
                placement: ToolbarItemPlacement,
                isDisabled: Bool = false,
                action: @escaping () -> Void) {
        self.title = title
        self.placement = placement
        self.isDisabled = isDisabled
        self.action = action
    }
    
    public var body: some ToolbarContent {
        ToolbarItem(placement: placement) {
            Button(title, action: action)
                .disabled(isDisabled)
        }
    }
}
