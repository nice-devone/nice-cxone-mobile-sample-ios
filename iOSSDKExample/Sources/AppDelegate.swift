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
import CXoneGuideUtility
import Firebase
import LoginWithAmazon
import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    // MARK: - Properties
    
    var window: UIWindow?
    
    private var appModule: AppModule?
    private var loginCoordinator: LoginCoordinator?
    private var deeplinkOption: DeeplinkOption?
    private var currentDeviceToken: Data?
    
    // MARK: - Methods
    
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

        LoginWithAmazonAuthenticator.initialize()
        
        // Reset Badge Number
        UIApplication.shared.applicationIconBadgeNumber = 0
        
        // Setup User Notification Center for real device
        UNUserNotificationCenter.current().delegate = self
        
        window = UIWindow(frame: UIScreen.main.bounds)
        
        let navigationController = UINavigationController()
        navigationController.view.backgroundColor = .systemBackground
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
        
        self.loginCoordinator = LoginCoordinator(navigationController: navigationController)
        // swiftlint:disable:next force_unwrapping
        self.appModule = AppModule(coordinator: loginCoordinator!)
        loginCoordinator?.assembler = appModule?.assembler
        
        loginCoordinator?.start(with: deeplinkOption)
        
        return true
    }
    
    /// Logs build number, version, and git branch information
    private func logBuildInfo() {
        if let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
            Log.trace("Build Number: \(buildNumber)")
        }
        
        // Log device information
        Log.trace("Device Model: \(UIDevice.current.model)")
        Log.trace("iOS Version: \(UIDevice.current.systemVersion)")
        Log.trace("Device Name: \(UIDevice.current.name)")
    }
    
    /// Checks and logs notification permission status
    private func checkAndLogNotificationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            Log.trace("Notification Settings - Authorization Status: \(settings.authorizationStatus.rawValue)")
            Log.trace("Notification Settings - Alert Setting: \(settings.alertSetting.rawValue)")
            Log.trace("Notification Settings - Badge Setting: \(settings.badgeSetting.rawValue)")
            Log.trace("Notification Settings - Sound Setting: \(settings.soundSetting.rawValue)")
            Log.trace("Notification Settings - Notification Center Setting: \(settings.notificationCenterSetting.rawValue)")
            Log.trace("Notification Settings - Lock Screen Setting: \(settings.lockScreenSetting.rawValue)")
            Log.trace("Notification Settings - Announcement Setting: \(settings.announcementSetting.rawValue)")
            
            if settings.authorizationStatus == .authorized {
                DispatchQueue.main.async {
                    Log.trace("Notification permissions granted - registering for remote notifications")
                    
                    UIApplication.shared.registerForRemoteNotifications()
                }
            } else {
                Log.trace("Notification permissions NOT granted - notifications will not work")
            }
        }
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        Log.trace("Handling url: \(url)")
        
        if ThreadsDeeplinkHandler.canOpenUrl(url) {
            Log.trace("Handling remote push notification's deeplink url: \(url)")
            
            CXoneChat.shared.connection.disconnect()
            
            self.deeplinkOption = ThreadsDeeplinkHandler.handleUrl(url)
            
            loginCoordinator?.start(with: deeplinkOption)
            
            return true
        } else if let authenticator = OAuthenticatorsManager.authenticator {
            Log.trace("Checking option to handle URL via OAuth manager")
            
            return authenticator.handleOpen(url: url, sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String)
        } else {
            Log.trace("Unable to handle url: \(url)")
            return false
        }
    }
    
    func application(
        _ application: UIApplication,
        shouldAllowExtensionPointIdentifier extensionPointIdentifier: UIApplication.ExtensionPointIdentifier
    ) -> Bool {
        extensionPointIdentifier != .keyboard
    }
}

// MARK: - UNUserNotificationCenterDelegate

extension AppDelegate: UNUserNotificationCenterDelegate {
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenString = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        Log.trace("Did register for remote notifications with token: \(tokenString)")
        
        guard currentDeviceToken != deviceToken else {
            Log.trace("Device token unchanged - skipping registration")
            return
        }
        
        self.currentDeviceToken = deviceToken
        
        Log.trace("Setting device token in CXoneChat")
        CXoneChat.shared.customer.setDeviceToken(deviceToken)
        
        Log.trace("Calling registration finished callback")
        RemoteNotificationsManager.shared.onRegistrationFinished?()
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        error.logError("Failed to register for remote notifications")
        
        RemoteNotificationsManager.shared.onRegistrationFinished?()
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
        let identifier = notification.request.identifier
        let userInfo = notification.request.content.userInfo
        
        // Show remote push notification when chat is not available
        if !CXoneChat.shared.state.isChatAvailable {
            Log.trace("Will present remote notification with identifier: \(identifier)")
        }
        // Show local push notification when chat is available and the notification name is `threadDeeplinkNotificationName`
        else if CXoneChat.shared.state.isChatAvailable, identifier.hasPrefix(NotificationCenter.threadDeeplinkNotificationName) {
            Log.trace("Will present local notification with identifier: \(identifier)")
            
            // Extract thread information if possible
            if let threadIdString = userInfo["threadId"] as? String {
                Log.trace("Thread ID from notification: \(threadIdString)")
            } else {
                Log.error("Unable to extract threadId from notification userInfo")
            }
        } else {
            return []
        }
        
        Log.trace("Notification content: \(notification.request.content)")
        Log.trace("Notification userInfo: \(userInfo)")
        
        UIApplication.shared.applicationIconBadgeNumber += 1
        Log.trace("Updated badge count to: \(UIApplication.shared.applicationIconBadgeNumber)")
        
        return [.list, .banner, .badge, .sound]
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse) async {
        let userInfo = response.notification.request.content.userInfo
        let identifier = response.notification.request.identifier
        
        Log.trace("Did receive notification response with identifier: \(identifier)")
        Log.trace("Notification userInfo: \(userInfo)")
        
        UIApplication.shared.applicationIconBadgeNumber = 0
        Log.trace("Reset badge count to 0")
        
        // Check if this is a message notification from a different thread
        if processNotificationAndNavigateToThread(notification: response.notification) {
            Log.trace("Successfully posted notification to navigate directly to a CXoneChat's thread")
        } else if handleDeeplinkIfNeeded(userInfo: userInfo) {
            Log.trace("Successfully handled application deeplink")
        } else {
            Log.trace("Could not handle notification - neither thread navigation nor deeplink handling succeeded")
        }
    }
}

// MARK: - Helpers

private extension AppDelegate {
    
    func processNotificationAndNavigateToThread(notification: UNNotification) -> Bool {
        let identifier = notification.request.identifier
        
        Log.trace("Checking if notification is for chat inactive thread: \(identifier)")
        
        guard identifier.hasPrefix(NotificationCenter.threadDeeplinkNotificationName) else {
            Log.trace("Notification identifier doesn't have expected prefix: \(NotificationCenter.threadDeeplinkNotificationName)")
            return false
        }
        
        let userInfo = notification.request.content.userInfo
        
        Log.trace("Notification userInfo for thread navigation: \(userInfo)")
        
        guard let threadIdString = userInfo["threadId"] as? String,
              let threadId = UUID(uuidString: threadIdString)
        else {
            Log.error("Unable to extract threadId from notification userInfo: \(userInfo)")
            return false
        }
        
        Log.trace("Found valid threadId: \(threadId). Posting thread deeplink notification.")
        
        NotificationCenter.default.postThreadDeeplinkNotification(threadId: threadId)
        
        return true
    }
    
    func handleDeeplinkIfNeeded(userInfo: [AnyHashable: Any]) -> Bool {
        Log.trace("Attempting to handle deeplink from userInfo: \(userInfo)")
        
        // Existing deeplink handling
        guard let data = userInfo["data"] as? NSDictionary else {
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
        
        let canOpenUrl = ThreadsDeeplinkHandler.canOpenUrl(url)
        
        Log.trace("Can open URL: \(canOpenUrl)")
        
        if canOpenUrl {
            Log.trace("Disconnecting from CXoneChat and handling URL")
            
            CXoneChat.shared.connection.disconnect()
            
            self.deeplinkOption = ThreadsDeeplinkHandler.handleUrl(url)
            
            loginCoordinator?.start(with: deeplinkOption)
        }
        
        return canOpenUrl
    }
}
