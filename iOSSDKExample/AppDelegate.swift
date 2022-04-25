//
//  AppDelegate.swift
//  iOSSDKExample
//
//  Created by Customer Dynamics Development on 9/2/21.
//

import UIKit
import CXOneChatSDK
import IQKeyboardManagerSwift

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var CXOneChatClient = CXOneChat.shared
    
	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
		// Override point for customization after application launch.
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.disabledDistanceHandlingClasses.append(ChatViewController.self)
        IQKeyboardManager.shared.disabledDistanceHandlingClasses.append(AdvancedExampleViewController.self)
        CXOneChatClient.configurePinpoint(launchOptions: launchOptions)
        CXOneChatClient.connect(environment: .NA1, brandId: 1386, channelId: "chat_51eafb4e-8829-4efe-b58c-3bc9febf18c4")

        
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .badge, .sound]) { (success, error) in
            if error == nil {
                if success {
                    DispatchQueue.main.async {
                        application.registerForRemoteNotifications()
                    }
                }
            } 
        }
        
		return true
	}

	// MARK: UISceneSession Lifecycle

	func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
		// Called when a new scene session is being created.
		// Use this method to select a configuration to create the new scene with.
		return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
	}

	func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
		// Called when the user discards a scene session.
		// If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
		// Use this method to release any resources that were specific to the discarded scenes, as they will not return.
	}

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        CXOneChatClient.registerDeviceToken(deviceToken: deviceToken)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("error registering for remote notificatinos")
    }

}

