//
//  Alert+Extension.swift
//  NewsApp-SwiftUI-MVVM-Combine
//
//  Created by Vijay Raj Dixit on 30/01/26.
//

import SwiftUI

extension View {
    func showAlert(title: String? = nil, message: String, isPresented: Binding<Bool>,
                   primaryRightButton: (title: String, action: () -> Void)? = nil,
                   secondaryCancelButton: (title: String, action: () -> Void)? = nil,
                   destructiveAction: (() -> Void)? = nil) -> some View {
        
        alert(title ?? "Error", isPresented: isPresented) {            
            if let primaryRightButton {
                Button(primaryRightButton.title) {
                    primaryRightButton.action()
                }
            }
            
            if let secondaryCancelButton {
                Button(secondaryCancelButton.title, role: .cancel) {
                    secondaryCancelButton.action()
                }
            } else {
                Button("Cancel", role: .cancel) {}
            }
            
            if let destructiveAction {
                Button(role: .destructive) {
                    destructiveAction()
                }
            }
        } message: {
            Text(message)
        }
    }
}
