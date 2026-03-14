//
//  LoggerService.swift
//  NewsApp-SwiftUI-MVVM-Combine
//
//  Created by Vijay Raj Dixit on 26/02/26.
//


/// Defines the verbosity used by infrastructure logging backends.
public enum LogLevel {
    case debug, info, warning, error
}

/// Groups logs by feature area so production issues are easier to filter and trace.
public enum LogCategory: String {
    case `default` = "default"
    case network
    case cache
    case recent
    case bookmark
}

/// Shared logging contract used across app, data, and presentation layers.
public protocol LoggerService {
    func log(_ level: LogLevel,
             _ message: () -> String,
             category: LogCategory,
             metadata: [String: String]?,
             file: String,
             function: String,
             line: Int)
}

public extension LoggerService {
    /// Records a debug-level log entry.
    func debug(_ msg: @autoclosure () -> String, category: LogCategory = .default,
               metadata: [String: String]? = nil,
               file: String = #fileID, function: String = #function, line: Int = #line) {
        log(.debug, msg, category: category, metadata: metadata, file: file, function: function, line: line)
    }

    /// Records an informational log entry.
    func info(_ msg: @autoclosure () -> String, category: LogCategory = .default,
              metadata: [String: String]? = nil,
              file: String = #fileID, function: String = #function, line: Int = #line) {
        log(.info, msg, category: category, metadata: metadata, file: file, function: function, line: line)
    }

    /// Records a warning-level log entry.
    func warning(_ msg: @autoclosure () -> String, category: LogCategory = .default,
                 metadata: [String: String]? = nil,
                 file: String = #fileID, function: String = #function, line: Int = #line) {
        log(.warning, msg, category: category, metadata: metadata, file: file, function: function, line: line)
    }

    /// Records an error-level log entry.
    func error(_ msg: @autoclosure () -> String, category: LogCategory = .default,
               metadata: [String: String]? = nil,
               file: String = #fileID, function: String = #function, line: Int = #line) {
        log(.error, msg, category: category, metadata: metadata, file: file, function: function, line: line)
    }
}
