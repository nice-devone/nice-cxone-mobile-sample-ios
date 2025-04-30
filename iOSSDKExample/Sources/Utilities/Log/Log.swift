//
// Copyright (c) 2021-2025. NICE Ltd. All rights reserved.
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

import CXoneChatSDK
import CXoneChatUI
import CXoneGuideUtility
import FirebaseCrashlytics
import os
import UIKit

class Log: StaticLogger {
    // MARK: - StaticLogger implementation

    nonisolated(unsafe) public static var instance: LogWriter? = PrintLogWriter()
    public static let category: String? = "Application"

    // MARK: - Properties

    static let logsFolderName = "CXoneChatSampleAppLogs"

    private static var currentLogFileUrl: URL?
    private static let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "H:mm:ss.SS dd.MM.yyyy"

        return formatter
    }()

    // MARK: - Methods

    class func configure(
        format: LogFormatter = .full,
        isPrintEnabled: Bool = true,
        isWriteToFileEnabled: Bool = false,
        isCrashlyticsEnabled: Bool = false,
        isSystemEnabled: Bool = false
    ) {
        var loggers = [any LogWriter]()

        if isPrintEnabled {
            loggers.append(PrintLogWriter())
        }
        
        if isWriteToFileEnabled, let url = getCurrentLogUrl() {
            loggers.append(FileLogWriter(path: url))
        }

        if isCrashlyticsEnabled {
            loggers.append(CrashlyticsLogWriter())
        }

        if isSystemEnabled {
            loggers.append(SystemLogWriter(logger: Logger(
                subsystem: Bundle.main.bundleIdentifier!, // swiftlint:disable:this force_unwrapping
                category: "Application"
            )))
        }

        let instance = loggers.isEmpty ? nil : ForkLogWriter(loggers: loggers).format(format)

        Self.instance = instance
        CXoneChat.logWriter = instance
        CXoneChatUI.LogManager.instance = instance
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
    
    // periphery:ignore - May be used in the future
    class func error(_ error: CommonError, file: StaticString = #file, line: UInt = #line) {
        Self.error(error.localizedDescription, file: file, line: line)
    }

    class func warning(_ error: CommonError, file: StaticString = #file, line: UInt = #line) {
        Self.warning(error.localizedDescription, file: file, line: line)
    }
}

// MARK: - Private methods

private extension Log {

    class func getCurrentLogUrl() -> URL? {
        if let currentLogFileUrl, FileManager.default.fileExists(atPath: currentLogFileUrl.path) {
            return currentLogFileUrl
        }
        
        guard let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("Unable to get document directory")
            return nil
        }
        
        let logsUrl = documents.appendingPathComponent(logsFolderName, isDirectory: true)
        
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
            print(error.localizedDescription)
            return nil
        }
    }
}
