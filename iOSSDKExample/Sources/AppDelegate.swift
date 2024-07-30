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

import CXoneChatSDK
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
        // Setup local Log manager
        Log.configure(isEnabled: true, isWriteToFileEnabled: true)

        LoginWithAmazonAuthenticator.initialize()
        
        // Setup CXoneChat SDK Log manager
        CXoneChat.configureLogger(level: .trace, verbosity: .full)
        CXoneChat.shared.logDelegate = self
        
        // Setup Crashlytics
        FirebaseApp.configure()
        
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
        guard currentDeviceToken != deviceToken else {
            return
        }
        
        Log.trace("Did register for remote notification")
        
        self.currentDeviceToken = deviceToken
        
        CXoneChat.shared.customer.setDeviceToken(deviceToken)
        
        RemoteNotificationsManager.shared.onRegistrationFinished?()
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        error.logError()
        
        RemoteNotificationsManager.shared.onRegistrationFinished?()
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
        Log.trace("Will present notification: \(notification)")
        
        if CXoneChat.shared.state.isChatAvailable && notification.request.content.userInfo["messageFromDifferentThread"] == nil {
            Log.trace("Unable to present notification - CXone Chat instance is active or received notification for current thread")
            return []
        } else {
            UIApplication.shared.applicationIconBadgeNumber += 1
            
            return [.list, .banner, .badge, .sound]
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse) async {
        let userInfo = response.notification.request.content.userInfo
        Log.trace("Did receive notification with userInfo: \(userInfo)")
        
        UIApplication.shared.applicationIconBadgeNumber = 0
        
        guard let data = userInfo["data"] as? NSDictionary,
              let pinpoint = data["pinpoint"] as? NSDictionary,
              let deeplink = pinpoint["deeplink"] as? String,
              let url = URL(string: deeplink)
        else {
            Log.error(.failed("Unable to get deeplink URL"))
            return
        }
        
        if ThreadsDeeplinkHandler.canOpenUrl(url) {
            CXoneChat.shared.connection.disconnect()
            self.deeplinkOption = ThreadsDeeplinkHandler.handleUrl(url)
            
            loginCoordinator?.start(with: deeplinkOption)
        }
    }
}

// MARK: - LogDelegate

extension AppDelegate: CXoneChatSDK.LogDelegate {
    
    func logError(_ message: String) {
        Log.message("[SDK] \(message)")
    }
    
    func logWarning(_ message: String) {
        Log.message("[SDK] \(message)")
    }
    
    func logInfo(_ message: String) {
        Log.message("[SDK] \(message)")
    }
    
    func logTrace(_ message: String) {
        Log.message("[SDK] \(message)")
    }
}
