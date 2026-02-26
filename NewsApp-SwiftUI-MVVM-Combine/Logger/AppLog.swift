//
//  AppLog.swift
//  NewsApp-SwiftUI-MVVM-Combine
//
//  Created by Vijay Raj Dixit on 26/02/26.
//


public enum AppLog {
    /// Swap this in one place.
    public static let shared: LoggerService = {
        let os = OSLoggerService()
        #if DEBUG
        return os
        #else
        let remote = RemoteLoggerService()
        return remote
        #endif
    }()
}