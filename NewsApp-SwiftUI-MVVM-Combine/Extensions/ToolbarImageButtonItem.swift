//
//  ToolbarImageButtonItem.swift
//  NewsApp-SwiftUI-MVVM-Combine
//
//  Created by Vijay Raj Dixit on 30/01/26.
//


import SwiftUI

public struct ToolbarImageButtonItem: ToolbarContent {
    private let systemImage: String
    private let placement: ToolbarItemPlacement
    private let isDisabled: Bool
    private let action: () -> Void
    
    public init(systemImage: String,
                placement: ToolbarItemPlacement,
                isDisabled: Bool = false,
                action: @escaping () -> Void) {
        self.systemImage = systemImage
        self.placement = placement
        self.isDisabled = isDisabled
        self.action = action
    }
    
    public var body: some ToolbarContent {
        ToolbarItem(placement: placement) {
            Button(action: action) {
                Image(systemName: systemImage)
            }
            .disabled(isDisabled)
        }
    }
}
