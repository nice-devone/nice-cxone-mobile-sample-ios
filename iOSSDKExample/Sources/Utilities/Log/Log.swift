//
// Copyright (c) 2021-2024. NICE Ltd. All rights reserved.
//
// Licensed under the NICE License;
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    https://github.com/nice-devone/nice-cxone-mobile-sample-ios/blob/main/LICENSE
//
// TO THE EXTENT PERMITTED BY APPLICABLE LAW, THE CXONE MOBILE SDK IS PROVIDED ON
// AN “AS IS” BASIS. NICE HEREBY DISCLAIMS ALL WARRANTIES AND CONDITIONS, EXPRESS
// OR IMPLIED, INCLUDING (WITHOUT LIMITATION) WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE, NON-INFRINGEMENT, AND TITLE.
//

import FirebaseCrashlytics
import os
import UIKit

class Log {
    
    // MARK: - Sub Objects
    
    enum LogType: String {
        case error = "ERROR"
        case warning = "WARNING"
        case info = "INFO"
        case trace = "TRACE"
    }
    
    // MARK: - Properties
    
    private static var isEnabled = false
    private static var isWriteToFileEnabled = false
    private static var currentLogFileUrl: URL?
    
    private static let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "H:mm:ss.SS dd.MM.yyyy"
        
        return formatter
    }()
    
    // swiftlint:disable:next force_unwrapping
    static let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "Application")
    static let logsFolderName = "CXoneChatSampleAppLogs"
    
    // MARK: - Methods
    
    class func configure(isEnabled: Bool, isWriteToFileEnabled: Bool) {
        self.isEnabled = isEnabled
        self.isWriteToFileEnabled = isWriteToFileEnabled
        
        message("===== SESSION STARTED =====")
        message(String(format: "iOS Version %@", UIDevice.current.systemVersion))
        message(String(format: "App Version %@", Bundle.main.version))
    }
    
    class func getLogShareDialog() throws -> UIActivityViewController {
        guard let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            throw CommonError.unableToParse("Unable to get document directory")
        }
        
        let logsUrl = documentDirectory.appendingPathComponent(logsFolderName, isDirectory: true)
        let filePaths = try FileManager.default.contentsOfDirectory(at: logsUrl, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles])
        
        guard !filePaths.isEmpty else {
            throw CommonError.failed("No log files available")
        }
        
        return UIActivityViewController(activityItems: filePaths, applicationActivities: nil)
    }
    
    class func removeLogs() throws {
        guard let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            throw CommonError.unableToParse("Unable to get document directory")
        }
        
        let logsUrl = documentDirectory.appendingPathComponent(logsFolderName, isDirectory: true)
        let filePaths = try FileManager.default.contentsOfDirectory(at: logsUrl, includingPropertiesForKeys: nil, options: [])
        
        for filePath in filePaths {
            do {
                try FileManager.default.removeItem(at: filePath)
            } catch {
                error.logError()
            }
        }
    }
    
    // MARK: - Logging
    
    class func message(_ message: String) {
        guard isEnabled else {
            return
        }
        
        writeToFile(message)
        logger.notice("\(message, privacy: .public)")
        Crashlytics.crashlytics().log(message)
    }
    
    class func error(_ error: CommonError, fun: StaticString = #function, file: StaticString = #file, line: UInt = #line) {
        Self.error(error.localizedDescription, fun: fun, file: file, line: line)
    }
    
    class func error(_ message: String, fun: StaticString = #function, file: StaticString = #file, line: UInt = #line) {
        guard isEnabled else {
            return
        }
        
        logMessage(message, type: .error, fun: fun, file: file, line: line)
    }
    
    class func warning(_ error: CommonError, fun: StaticString = #function, file: StaticString = #file, line: UInt = #line) {
        Self.warning(error.localizedDescription, fun: fun, file: file, line: line)
    }
    
    class func warning(_ message: String, fun: StaticString = #function, file: StaticString = #file, line: UInt = #line) {
        guard isEnabled else {
            return
        }
        
        logMessage(message, type: .warning, fun: fun, file: file, line: line)
    }
    
    class func info(_ message: String, fun: StaticString = #function, file: StaticString = #file, line: UInt = #line) {
        guard isEnabled else {
            return
        }
        
        logMessage(message, type: .info, fun: fun, file: file, line: line)
    }
    
    class func trace(_ message: String, fun: StaticString = #function, file: StaticString = #file, line: UInt = #line) {
        guard isEnabled else {
            return
        }
        
        logMessage(message, type: .trace, fun: fun, file: file, line: line)
    }
}

// MARK: - Private methods

private extension Log {
    
    class func logMessage(
        _ message: String,
        type: LogType,
        toFile: Bool = true,
        toLogger: Bool = true,
        toCrashlytics: Bool = true,
        fun: StaticString = #function,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let formattedMessage = getFormattedMessage(message, type: type, fun: fun, file: file, line: line)
        
        if toFile {
            writeToFile(formattedMessage)
        }
        if toCrashlytics {
            Crashlytics.crashlytics().log(formattedMessage)
        }
        if toLogger {
            switch type {
            case .error:
                logger.error("\(formattedMessage, privacy: .public)")
            case .warning:
                logger.warning("\(formattedMessage, privacy: .public)")
            case .info:
                logger.info("\(formattedMessage, privacy: .public)")
            case .trace:
                logger.trace("\(formattedMessage, privacy: .public)")
            }
        }
    }
    
    class func writeToFile(_ message: String) {
        guard isWriteToFileEnabled else {
            return
        }
        
        DispatchQueue.main.async {
            guard let logUrl = getCurrentLogUrl() else {
                return
            }
            
            do {
                let data = Data("\(message)\n".utf8)
                
                if let outputStream = OutputStream(url: logUrl, append: true) {
                    outputStream.open()
                    
                    let bytesWritten = try data.withUnsafeBytes { pointer -> Int in
                        guard let rawPointer = pointer.baseAddress else {
                            throw CommonError.unableToParse("baseAddress")
                        }
                        
                        return outputStream.write(rawPointer, maxLength: data.count)
                    }
                    
                    if bytesWritten < 0 {
                        outputStream.streamError?.logError()
                    }
                    
                    outputStream.close()
                } else {
                    try data.write(to: logUrl)
                }
            } catch {
                logMessage("Unable to write into file", type: .error, toFile: false)
            }
        }
    }
    
    class func getCurrentLogUrl() -> URL? {
        if let currentLogFileUrl, FileManager.default.fileExists(atPath: currentLogFileUrl.path) {
            return currentLogFileUrl
        }
        
        guard let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            logMessage("Unable to get document directory", type: .error)
            return nil
        }
        
        let logsUrl = documentDirectory.appendingPathComponent(logsFolderName, isDirectory: true)
        
        do {
            try FileManager.default.createDirectory(at: logsUrl, withIntermediateDirectories: true, attributes: nil)
            
            return (formatter.copy() as? DateFormatter).map { copy in
                copy.dateFormat = "dd.MM.yyyy"
                let logFile = copy.string(from: Date()) + ".txt"
                let logUrl = logsUrl.appendingPathComponent(logFile)
                
                self.currentLogFileUrl = logUrl
                
                return logUrl
            }
        } catch {
            logMessage(error.localizedDescription, type: .error)
            return nil
        }
    }
    
    class func getFormattedMessage(_ message: String, type: LogType, fun: StaticString = #function, file: StaticString = #file, line: UInt = #line) -> String {
        String(
            format: "%@ [%@:%d]: %@ %@: %@",
            formatter.string(from: Date()),
            file.description.lastPathComponent,
            line,
            type.rawValue,
            fun.description.withoutParameters,
            message
        )
    }
}

// MARK: - Helpers

private extension String {
    
    var lastPathComponent: String {
        URL(string: self)?.lastPathComponent ?? self
    }
    
    var withoutParameters: String {
        guard let substring = substring(from: "(", to: ")"), !substring.isEmpty else {
            return self
        }
        guard let lhs = firstIndex(of: "("), let rhs = firstIndex(of: ")") else {
            return self
        }
        
        let startIndex = index(after: lhs)
        let endIndex = index(before: rhs)
        
        let range = startIndex...endIndex
        var result = self
        
        result.removeSubrange(range)
        return result
    }
}
