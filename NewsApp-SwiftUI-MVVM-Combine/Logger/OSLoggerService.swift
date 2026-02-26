//
//  OSLoggerService.swift
//  NewsApp-SwiftUI-MVVM-Combine
//
//  Created by Vijay Raj Dixit on 26/02/26.
//

import Foundation
import os

public final class OSLoggerService: LoggerService {
    private let logger: Logger
    public init(subsystem: String = Bundle.main.bundleIdentifier ?? "com.pvrdixit.NewsApp-SwiftUI-MVVM-Combine",
                category: LogCategory = .default) {
        self.logger = Logger(subsystem: subsystem, category: category.rawValue)
    }

    public func log(_ level: LogLevel,
                    _ message: @autoclosure () -> String,
                    category: LogCategory,
                    file: String,
                    function: String,
                    line: Int) {
        // Single logger instance; category is appended to message (simple).
        let rendered = "[\(category)] \(message()) (\(file):\(line) \(function))"
        logger.log(level: level.osType, "\(rendered, privacy: .public)")
    }
}