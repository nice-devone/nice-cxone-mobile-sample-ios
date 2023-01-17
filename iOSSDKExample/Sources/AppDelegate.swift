import CXoneChatSDK
import IQKeyboardManagerSwift
#if HasLWA
    import LoginWithAmazon
#endif
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

        #if HasLWA
        LoginWithAmazonAuthenticator.initialize()
        #endif
        
        // Register feature flags defined in the `Root.plist` of the `Settings.bundle`
        FeatureFlag.registerFeatureFlags()
        
        // Setup local Log manager
        Log.isEnabled = true
        Log.isWriteToFileEnabled = true
        
        // Setup CXoneChat SDK Log manager
        CXoneChat.configureLogger(level: .trace, verbosity: .full)
        CXoneChat.shared.logDelegate = self
        
        // Setup Keyboard manager
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.disabledDistanceHandlingClasses.append(ThreadDetailViewController.self)
        
        // Setup User Notification Center for real device
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
        guard let authenticator = OAuthenticators.authenticator else {
            Log.error(.failed("Could not get OAuth authenticator."))
            return false
        }

        return authenticator.handleOpen(url: url, sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String)
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        CXoneChat.shared.customer.setDeviceToken(deviceToken)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        error.logError()
    }
    
    func application(_ application: UIApplication, shouldAllowExtensionPointIdentifier extensionPointIdentifier: UIApplication.ExtensionPointIdentifier) -> Bool {
        extensionPointIdentifier != .keyboard
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
