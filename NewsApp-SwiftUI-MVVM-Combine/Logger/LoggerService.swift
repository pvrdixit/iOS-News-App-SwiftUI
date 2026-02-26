//
//  LoggerService.swift
//  NewsApp-SwiftUI-MVVM-Combine
//
//  Created by Vijay Raj Dixit on 26/02/26.
//


public protocol LoggerService {
    func log(_ level: LogLevel,
             _ message: @autoclosure () -> String,
             category: LogCategory,
             file: String,
             function: String,
             line: Int)
}

public extension LoggerService {
    func debug(_ msg: @autoclosure () -> String, category: LogCategory = .default,
               file: String = #fileID, function: String = #function, line: Int = #line) {
        log(.debug, msg(), category: category, file: file, function: function, line: line)
    }

    func info(_ msg: @autoclosure () -> String, category: LogCategory = .default,
              file: String = #fileID, function: String = #function, line: Int = #line) {
        log(.info, msg(), category: category, file: file, function: function, line: line)
    }

    func warning(_ msg: @autoclosure () -> String, category: LogCategory = .default,
                 file: String = #fileID, function: String = #function, line: Int = #line) {
        log(.warning, msg(), category: category, file: file, function: function, line: line)
    }

    func error(_ msg: @autoclosure () -> String, category: LogCategory = .default,
               file: String = #fileID, function: String = #function, line: Int = #line) {
        log(.error, msg(), category: category, file: file, function: function, line: line)
    }
}
