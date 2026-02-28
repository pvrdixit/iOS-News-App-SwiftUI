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
    public init(subsystem: String, category: LogCategory) {
        self.logger = Logger(subsystem: subsystem, category: category.rawValue)
    }

    public func log(_ level: LogLevel,
                    _ message: @autoclosure () -> String,
                    category: LogCategory,
                    metadata: [String: String]?,
                    file: String,
                    function: String,
                    line: Int) {
        // Single logger instance; category is appended to message (simple).
        let metadataText = Self.render(metadata)
        let rendered = "[\(category)] \(message())\(metadataText) (\(file):\(line) \(function))"
        logger.log(level: level.osType, "\(rendered, privacy: .public)")
    }

    private static func render(_ metadata: [String: String]?) -> String {
        guard let metadata, !metadata.isEmpty else { return "" }
        let renderedPairs = metadata
            .sorted(by: { $0.key < $1.key })
            .map { "\($0.key)=\($0.value)" }
            .joined(separator: " ")
        return " [\(renderedPairs)]"
    }
}
