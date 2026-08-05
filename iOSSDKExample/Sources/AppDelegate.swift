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
import CXoneGuideUtility
import Firebase
import UIKit

/// `@unchecked Sendable` is required because `UIResponder`/`UIApplicationDelegate` predate
/// Swift's `Sendable` annotations. Concurrent usage is safe because:
///
///   1. `currentDeviceToken` is read and written exclusively from UIKit delegate callbacks,
///      which UIKit guarantees fire on the main thread.
///   2. `chatProvider` is written once from `SDKDemoApp.init()` — which SwiftUI runs on the
///      main actor, before `UIApplicationMain` installs this delegate and therefore before any
///      callback can read it — and only read from main-thread delegate callbacks afterwards.
///   3. All other state is set during `application(_:didFinishLaunchingWithOptions:)` and
///      never mutated afterwards.
///
/// Remove this annotation if/when UIKit ships formal `Sendable` conformances.
class AppDelegate: UIResponder, UIApplicationDelegate, @unchecked Sendable {

    // MARK: - Properties

    var chatProvider: ChatProvider?

    private var currentDeviceToken: Data?

    // MARK: - Methods

    @MainActor
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        // Setup Crashlytics
        FirebaseApp.configure()

        // Setup shared Logger
        Log.configure(isWriteToFileEnabled: true)

        // Log build and branch information
        logBuildInfo()

        // Log notification settings at startup
        checkAndLogNotificationStatus()

        // Reset Badge Number
        UIApplication.shared.applicationIconBadgeNumber = 0

        // Setup User Notification Center for real device
        UNUserNotificationCenter.current().delegate = self

        // Register the Google OAuth authenticator for the sample app's sign-in flows
        do {
            OAuthenticatorsManager.register(authenticator: try GoogleAuthenticator())
        } catch {
            error.logError("Failed to set up Google authenticator")
        }

        return true
    }

    func application(
        _ application: UIApplication,
        shouldAllowExtensionPointIdentifier extensionPointIdentifier: UIApplication.ExtensionPointIdentifier
    ) -> Bool {
        extensionPointIdentifier != .keyboard
    }
}

// MARK: - UNUserNotificationCenterDelegate

extension AppDelegate: @preconcurrency UNUserNotificationCenterDelegate {

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenString = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        Log.trace("Did register for remote notifications with token: \(tokenString)")

        guard currentDeviceToken != deviceToken else {
            Log.trace("Device token unchanged - skipping registration")
            return
        }

        self.currentDeviceToken = deviceToken

        Log.trace("Setting device token in CXoneChat")
        chatProvider?.customer.setDeviceToken(deviceToken)
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        error.logError("Failed to register for remote notifications")
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        let identifier = notification.request.identifier
        let userInfo = notification.request.content.userInfo

        // Show remote push notification when chat is not available
        if chatProvider?.state.isChatAvailable != true {
            Log.trace("Will present remote notification with identifier: \(identifier)")
        }
        // Show local push notification when chat is available and the notification name is `threadDeeplinkNotificationName`
        else if chatProvider?.state.isChatAvailable == true, identifier.hasPrefix(NotificationCenter.threadDeeplinkNotificationName) {
            Log.trace("Will present local notification with identifier: \(identifier)")

            // Extract thread information if possible
            if let threadIdString = userInfo["threadId"] as? String {
                Log.trace("Thread ID from notification: \(threadIdString)")
            } else {
                Log.error("Unable to extract threadId from notification userInfo")
            }
        } else {
            completionHandler([])
            return
        }

        Log.trace("Notification content: \(notification.request.content)")
        Log.trace("Notification userInfo: \(userInfo)")

        UIApplication.shared.applicationIconBadgeNumber += 1
        Log.trace("Updated badge count to: \(UIApplication.shared.applicationIconBadgeNumber)")

        completionHandler([.list, .banner, .badge, .sound])
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo
        let identifier = response.notification.request.identifier

        Log.trace("Did receive notification response with identifier: \(identifier)")
        Log.trace("Notification userInfo: \(userInfo)")

        UIApplication.shared.applicationIconBadgeNumber = 0
        Log.trace("Reset badge count to 0")

        // Check if this is a message notification from a different thread
        if processLocalNotificationAndNavigateToThread(notification: response.notification) {
            Log.trace("Successfully posted notification to navigate directly to a CXoneChat's thread")
        } else if processRemoteNotificationAndNavigateToThread(notification: response.notification) {
            Log.trace("Successfully handled application deeplink")
        } else {
            Log.trace("Could not handle notification - neither thread navigation nor deeplink handling succeeded")
        }

        completionHandler()
    }
}

// MARK: - Helpers

private extension AppDelegate {

    func processLocalNotificationAndNavigateToThread(notification: UNNotification) -> Bool {
        let identifier = notification.request.identifier

        Log.trace("Checking if notification is for chat inactive thread")

        guard identifier.hasPrefix(NotificationCenter.threadDeeplinkNotificationName) else {
            Log.trace("Notification identifier doesn't have expected prefix: \(NotificationCenter.threadDeeplinkNotificationName)")
            return false
        }

        let userInfo = notification.request.content.userInfo

        Log.trace("Notification userInfo for thread navigation: \(userInfo)")

        guard let threadId = userInfo["threadId"] as? String else {
            Log.error("Unable to extract threadId from notification userInfo: \(userInfo)")
            return false
        }

        Log.trace("Found valid threadId: \(threadId). Posting cxone deeplink notification.")

        // Post on the host-app channel (`cxoneDeeplinkNotification`) so `AppRouter` decides
        // *what* to do with the deeplink:
        //   - chat already presented → AppRouter forwards via the SDK's internal
        //     `postThreadDeeplinkNotification` to switch threads in place
        //   - at the store → opens chat at the deeplinked thread
        //   - elsewhere → queues onto `pendingDeeplink` for after login
        //
        // Posting `postThreadDeeplinkNotification` directly here would shortcut the dispatch
        // and silently drop the deeplink in the latter two cases (no observer until the chat
        // UI is mounted).
        NotificationCenter.default.post(
            name: .cxoneDeeplinkNotification,
            object: DeeplinkOption.thread(threadId)
        )

        return true
    }

    func processRemoteNotificationAndNavigateToThread(notification: UNNotification) -> Bool {
        Log.trace("Attempting to handle deeplink")

        guard let data = notification.request.content.userInfo["data"] as? NSDictionary else {
            Log.error("No 'data' found in userInfo")
            return false
        }
        guard let pinpoint = data["pinpoint"] as? NSDictionary else {
            Log.error("No 'pinpoint' found in data")
            return false
        }
        guard let deeplink = pinpoint["deeplink"] as? String else {
            Log.error("No 'deeplink' found in pinpoint")
            return false
        }
        guard let url = URL(string: deeplink) else {
            Log.error("Could not create URL from deeplink: \(deeplink)")
            return false
        }

        Log.trace("Found deeplink URL: \(url)")

        guard let deeplinkOption = ThreadsDeeplinkHandler.handleUrl(url) else {
            Log.trace("URL is not a recognised CXone deeplink: \(url)")
            return false
        }

        NotificationCenter.default.post(name: .cxoneDeeplinkNotification, object: deeplinkOption)

        return true
    }

    /// Logs build number, version, and git branch information
    func logBuildInfo() {
        if let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
            Log.trace("Build Number: \(buildNumber)")
        }

        // Log device information
        Log.trace("Device Model: \(UIDevice.current.model)")
        Log.trace("iOS Version: \(UIDevice.current.systemVersion)")
        Log.trace("Device Name: \(UIDevice.current.name)")
    }

    /// Checks and logs notification permission status
    func checkAndLogNotificationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            Log.trace("Notification Settings - Authorization Status: \(settings.authorizationStatus.rawValue)")
            Log.trace("Notification Settings - Alert Setting: \(settings.alertSetting.rawValue)")
            Log.trace("Notification Settings - Badge Setting: \(settings.badgeSetting.rawValue)")
            Log.trace("Notification Settings - Sound Setting: \(settings.soundSetting.rawValue)")
            Log.trace("Notification Settings - Notification Center Setting: \(settings.notificationCenterSetting.rawValue)")
            Log.trace("Notification Settings - Lock Screen Setting: \(settings.lockScreenSetting.rawValue)")
            Log.trace("Notification Settings - Announcement Setting: \(settings.announcementSetting.rawValue)")

            if settings.authorizationStatus == .authorized {
                Task { @MainActor in
                    Log.trace("Notification permissions granted - registering for remote notifications")

                    UIApplication.shared.registerForRemoteNotifications()
                }
            } else {
                Log.trace("Notification permissions NOT granted - notifications will not work")
            }
        }
    }
}
