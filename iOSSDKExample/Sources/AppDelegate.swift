import CXoneChatSDK
import IQKeyboardManagerSwift
import LoginWithAmazon
import UIKit


@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    // MARK: - Properties
    
    var window: UIWindow?
    private var appModule = AppModule()
    private var mainCoordinator: MainCoordinator?
    
    
    // MARK: - Methods
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        print("===== SESSION STARTED =====")
        
        Log.isWriteToFileEnabled = true
        
        CXoneChat.configureLogger(level: .trace, verbosity: .full)
        CXoneChat.shared.logDelegate = self
        
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.disabledDistanceHandlingClasses.append(ThreadDetailViewController.self)
        
        #if !targetEnvironment(simulator)
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { (success, error) in
            error?.logError()
            guard success else {
                Log.error("requestAuthorization failed")
                return
            }
            
            Task { @MainActor in
                application.registerForRemoteNotifications()
            }
        }
        #endif
        
        window = UIWindow(frame: UIScreen.main.bounds)
        
        let navigationController = UINavigationController()
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
        
        self.mainCoordinator = MainCoordinator(
            navigationController: navigationController,
            assembler: appModule.assembler
        )
        mainCoordinator?.start()
        
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        AMZNAuthorizationManager.handleOpen(url, sourceApplication: UIApplication.OpenURLOptionsKey.sourceApplication.rawValue)
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        CXoneChat.shared.customer.setDeviceToken(deviceToken)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        error.logError()
    }
}


// MARK: - LogDelegate

extension AppDelegate: LogDelegate {
    
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
