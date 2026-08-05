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
    
    private lazy var notificationCenter: UNUserNotificationCenter = .current()
    
    // MARK: - Init
    
    private override init() {
        super.init()
    }
    
    // MARK: - Methods
    
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
