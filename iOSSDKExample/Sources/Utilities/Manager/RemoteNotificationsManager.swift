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

import UIKit
import UserNotifications

@MainActor
public class RemoteNotificationsManager: NSObject {
    
    // MARK: - Properties
    
    public static let shared = RemoteNotificationsManager()
    
    /// The launch environment variable that suppresses the notification permission prompt.
    ///
    /// Exists for UI-test automation on simulators: on iOS 26 the system prompt is invisible to WebDriverAgent, so
    /// it cannot be dismissed and blocks every interaction beneath it. Appium passes it the same way as the
    /// predefined channel configuration — see `sample/docs/cs-predefined-configuration.md`.
    nonisolated static let skipPromptEnvironmentVariableName = "CXONE_SKIP_NOTIFICATION_PROMPT"
    
    private lazy var notificationCenter: UNUserNotificationCenter = .current()
    
    // MARK: - Init
    
    private override init() {
        super.init()
    }
    
    // MARK: - Methods
    
    /// Whether the launch environment asks to skip the notification permission prompt.
    ///
    /// The environment is injected (defaulting to the process environment) so the parsing can be unit-tested,
    /// the same way as ``LaunchConfigurationReader/read(environment:)``.
    ///
    /// - Parameter environment: The launch environment to inspect.
    /// - Returns: `true` when ``skipPromptEnvironmentVariableName`` is set to `1` or `true` (case-insensitive,
    ///   surrounding whitespace ignored).
    nonisolated static func isPromptSkipped(in environment: [String: String] = ProcessInfo.processInfo.environment) -> Bool {
        let value = environment[skipPromptEnvironmentVariableName]?
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
        
        return value == "1" || value == "true"
    }
    
    public func unregister() {
        Log.trace("Unregistering for remote notifications")

        UIApplication.shared.unregisterForRemoteNotifications()
    }

    public func registerIfNeeded() async throws {
        guard !UIApplication.shared.isRegisteredForRemoteNotifications else {
            Log.trace("Skip registering for remote notifications: already registered")
            return
        }

        Log.trace("The app is not registered for remote notifications: attempt to register with a prompt for user permissions")

        let settings = await notificationCenter.notificationSettings()
        
        if settings.authorizationStatus == .notDetermined {
            guard !Self.isPromptSkipped() else {
                Log.trace("Skip requesting notification permission: '\(Self.skipPromptEnvironmentVariableName)' is set")
                return
            }
            
            Log.trace("Notification permission was not determined, requesting")
            
            guard try await self.notificationCenter.requestAuthorization(options: [.alert, .badge, .sound]) else {
                Log.error("requestAuthorization failed")
                return
            }
            
            Log.trace("Notification permission was granted")
            
            UIApplication.shared.registerForRemoteNotifications()
        } else if settings.authorizationStatus == .denied {
            Log.warning(.failed("Notification permission was previously denied, go to settings & privacy to re-enable"))
        } else if settings.authorizationStatus == .authorized {
            Log.trace("Notification permission was previously granted")
            
            UIApplication.shared.registerForRemoteNotifications()
        }
    }
}
