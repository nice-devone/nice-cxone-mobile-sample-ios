//
// Copyright (c) 2021-2026. NICE Ltd. All rights reserved.
//
// Licensed under the NICE License;
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    https://github.com/nice-devone/nice-cxone-mobile-sample-ios/blob/main/LICENSE
//
// TO THE EXTENT PERMITTED BY APPLICABLE LAW, THE CXONE MOBILE SDK IS PROVIDED ON
// AN "AS IS" BASIS. NICE HEREBY DISCLAIMS ALL WARRANTIES AND CONDITIONS, EXPRESS
// OR IMPLIED, INCLUDING (WITHOUT LIMITATION) WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE, NON-INFRINGEMENT, AND TITLE.
//

import CXoneChatSDK
import CXoneChatUI
import CXoneGuideUtility
import FirebaseCrashlytics
import os

class Log: StaticLogger {
    
    // MARK: - StaticLogger implementation

    private static let _instance = SafeAccessContainer<LogWriter?>(PrintLogWriter())
    static var instance: LogWriter? {
        get { _instance.content }
        set {
            _instance.mutate { content in
                content = newValue
            }
        }
    }
    static let category: String? = "Application"

    // MARK: - Properties

    static let logsFolderName = "CXoneChatSampleAppLogs"
    static let logFileName = "app.log"

    // MARK: - Methods

    @MainActor
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

        // Unconditional, so a legacy log is removed even when file logging is off or its folder cannot be created.
        removeLegacyDocumentsLogs()

        if isWriteToFileEnabled, let url = makeLogFileUrl() {
            loggers.append(FileLogWriter(path: url))
        }

        if isCrashlyticsEnabled {
            loggers.append(CrashlyticsLogWriter())
        }

        if isSystemEnabled {
            let logger = Logger(
                subsystem: Bundle.main.bundleIdentifier!, // swiftlint:disable:this force_unwrapping
                category: "Application"
            )
            
            loggers.append(SystemLogWriter(logger: logger))
        }

        let instance = loggers.isEmpty ? nil : ForkLogWriter(loggers: loggers).format(format)

        Self.instance = instance
        CXoneChat.logWriter = instance
        CXoneChatUI.LogManager.instance = instance
    }

    /// URL of the single log file, or `nil` if it has not been created yet.
    class var logFileUrl: URL? {
        guard let url = logsFolderUrl?.appendingPathComponent(logFileName) else {
            return nil
        }

        return FileManager.default.fileExists(atPath: url.path) ? url : nil
    }

    class func removeLogs() {
        guard let logFileUrl else {
            return
        }

        do {
            try FileManager.default.removeItem(at: logFileUrl)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    // MARK: - Logging
    
    class func error(_ error: CommonError, file: StaticString = #file, line: UInt = #line) {
        Self.error(error.localizedDescription, file: file, line: line)
    }

    class func warning(_ error: CommonError, file: StaticString = #file, line: UInt = #line) {
        Self.warning(error.localizedDescription, file: file, line: line)
    }
}

// MARK: - Private methods

private extension Log {

    class var logsFolderUrl: URL? {
        // Application Support, not Documents: Documents is exposed through file sharing, and the log records notification payloads.
        FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first?
            .appendingPathComponent(logsFolderName, isDirectory: true)
    }

    /// Deletes logs written by earlier builds into Documents, which is now exposed through file sharing.
    class func removeLegacyDocumentsLogs() {
        guard let legacyUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?
            .appendingPathComponent(logsFolderName, isDirectory: true),
            FileManager.default.fileExists(atPath: legacyUrl.path)
        else {
            return
        }

        do {
            try FileManager.default.removeItem(at: legacyUrl)
        } catch {
            print(error.localizedDescription)
        }
    }

    /// Creates the logs directory if needed and returns the log file URL.
    class func makeLogFileUrl() -> URL? {
        guard let logsUrl = logsFolderUrl else {
            return nil
        }

        do {
            try FileManager.default.createDirectory(at: logsUrl, withIntermediateDirectories: true, attributes: nil)

            return logsUrl.appendingPathComponent(logFileName)
        } catch {
            print(error.localizedDescription)

            return nil
        }
    }
}
