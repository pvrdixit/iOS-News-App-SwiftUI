//
//  LoggerService.swift
//  NewsApp-SwiftUI-MVVM-Combine
//
//  Created by Vijay Raj Dixit on 26/02/26.
//


import os

public enum LogLevel {
    case debug, info, warning, error

    var osType: OSLogType {
        switch self {
        case .debug:   return .debug
        case .info:    return .info
        case .warning: return .default
        case .error:   return .error
        }
    }
}

public enum LogCategory: String {
    case `default` = "default"
    case core
    case network
    case cache
    case recent
    case bookmark
    case viewModel
    case ui
}

public protocol LoggerService {
    func log(_ level: LogLevel,
             _ message: @autoclosure () -> String,
             category: LogCategory,
             metadata: [String: String]?,
             file: String,
             function: String,
             line: Int)
}

public extension LoggerService {
    func debug(_ msg: @autoclosure () -> String, category: LogCategory = .default,
               metadata: [String: String]? = nil,
               file: String = #fileID, function: String = #function, line: Int = #line) {
        log(.debug, msg(), category: category, metadata: metadata, file: file, function: function, line: line)
    }

    func info(_ msg: @autoclosure () -> String, category: LogCategory = .default,
              metadata: [String: String]? = nil,
              file: String = #fileID, function: String = #function, line: Int = #line) {
        log(.info, msg(), category: category, metadata: metadata, file: file, function: function, line: line)
    }

    func warning(_ msg: @autoclosure () -> String, category: LogCategory = .default,
                 metadata: [String: String]? = nil,
                 file: String = #fileID, function: String = #function, line: Int = #line) {
        log(.warning, msg(), category: category, metadata: metadata, file: file, function: function, line: line)
    }

    func error(_ msg: @autoclosure () -> String, category: LogCategory = .default,
               metadata: [String: String]? = nil,
               file: String = #fileID, function: String = #function, line: Int = #line) {
        log(.error, msg(), category: category, metadata: metadata, file: file, function: function, line: line)
    }
}
