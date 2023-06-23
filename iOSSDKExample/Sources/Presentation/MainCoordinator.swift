import CXoneChatSDK
import Swinject
import Toast
import UIKit


/// The main app navigator.
///
/// It setups main navigation controller and handles user navigation through top level screens, e.g. Config, Login, Thread List.
/// In case of TabBar integration to the app, each tab should has its own coordinator.
class MainCoordinator: Coordinator {
    
    // MARK: - Properties
    
    private let navigationController: UINavigationController
    
    
    // MARK: - Init
    
    
    init(navigationController: UINavigationController, assembler: Assembler) {
        self.navigationController = navigationController
        super.init(assembler: assembler)
        
        setupNavigationBar()
    }
    
    
    // MARK: - Methods
    
    func start(with option: DeeplinkOption?) {
        switch option {
        case .thread:
            if let storedConfiguration = LocalStorageManager.configuration {
                navigationController.setViewControllers([loginViewController(configuration: storedConfiguration, option: option)], animated: false)
            } else {
                navigationController.setViewControllers([configViewController(option: option)], animated: false)
            }
        default:
            if let storedConfiguration = LocalStorageManager.configuration {
                navigationController.show(loginViewController(configuration: storedConfiguration), sender: self)
            } else {
                navigationController.show(configViewController(), sender: self)
            }
        }
    }
}


// MARK: - Navigation

private extension MainCoordinator {
    
    func showConfig(option: DeeplinkOption? = nil) {
        navigationController.show(configViewController(option: option), sender: self)
    }

    func showLogin(configuration: Configuration, option: DeeplinkOption? = nil) {
        navigationController.show(loginViewController(configuration: configuration, option: option), sender: self)
    }

    func showThreadList(configuration: Configuration, option: DeeplinkOption? = nil) {
        navigationController.show(threadListViewController(configuration: configuration, option: option), sender: self)
    }
    
    func showProactiveActionPopup(data: [String: Any], actionId: UUID) {
        let controller = UIViewController()
        controller.view = ProActiveActionPopup(data: data, actionId: actionId)
        
        navigationController.show(controller, sender: self)
    }

    func showThread(_ thread: ChatThread, channelConfiguration: Configuration) {
        navigationController.show(threadViewController(thread, channelConfiguration: channelConfiguration), sender: self)
    }
}


// MARK: - Scenes

private extension MainCoordinator {
    
    func configViewController(option: DeeplinkOption? = nil) -> UIViewController {
        let input = ConfigPresenter.Input(option: option)
        let navigation = ConfigPresenter.Navigation(
            navigateToLogin: { [weak self] in self?.showLogin(configuration: $0, option: $1) },
            showController: { [weak navigationController] controller in navigationController?.present(controller, animated: true) }
        )
        let presenter = ConfigPresenter(input: input, navigation: navigation, services: ())
        
        return ConfigViewController(presenter: presenter)
    }
    
    func loginViewController(configuration: Configuration, option: DeeplinkOption? = nil) -> UIViewController {
        let input = LoginPresenter.Input(configuration: configuration, option: option)
        let navigation = LoginPresenter.Navigation(
            navigateToThreads: { [weak self] config, option in self?.showThreadList(configuration: config, option: option) },
            navigateToConfiguration: { [weak self] in
                guard let self else {
                    return
                }
                
                self.navigationController.setViewControllers([self.configViewController()], animated: true)
            },
            presentController: { [weak self] controller in self?.navigationController.present(controller, animated: true) }
        )
        let presenter = LoginPresenter(input: input, navigation: navigation, services: ())
        
        return LoginViewController(presenter: presenter)
    }
    
    func threadListViewController(configuration: Configuration, option: DeeplinkOption? = nil) -> UIViewController {
        let input = ThreadListPresenter.Input(configuration: configuration, option: option)
        let navigation = ThreadListPresenter.Navigation(
            presentController: { [weak self] controller in self?.navigationController.present(controller, animated: true) },
            navigateToThread: { [weak self] thread in self?.showThread(thread, channelConfiguration: configuration) },
            navigateToLogin: { [weak self] in self?.navigationController.popViewController(animated: true) },
            navigateToConfiguration: { [weak self] in
                guard let self else {
                    return
                }
                
                self.navigationController.setViewControllers([self.configViewController()], animated: true)
            },
            showProactiveActionPopup: { [weak self] data, actionId in self?.showProactiveActionPopup(data: data, actionId: actionId) }
        )
        let presenter = ThreadListPresenter(input: input, navigation: navigation, services: ())
        
        return ThreadListViewController(presenter: presenter)
    }
    
    func threadViewController(_ thread: ChatThread, channelConfiguration: Configuration) -> UIViewController {
        let input = ThreadDetailPresenter.Input(configuration: channelConfiguration, thread: thread)
        let navigation = ThreadDetailPresenter.Navigation(
            showToast: { title, message in
                UIApplication.shared.rootViewController?.view.makeToast(message, duration: 2, position: .top, title: title)
            },
            showController: { [weak self] controller in
                controller.popoverPresentationController?.sourceView = self?.navigationController.view
                
                self?.navigationController.present(controller, animated: true) },
            popToThreadList: { [weak self] in
                self?.navigationController.popViewController(animated: true)
            }
        )
        let presenter = ThreadDetailPresenter(input: input, navigation: navigation, services: ())
        
        return ThreadDetailViewController(presenter: presenter)
    }
}


// MARK: - Setup Bar Appereance

private extension MainCoordinator {
    
    func setupNavigationBar() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.shadowImage = nil
        appearance.shadowColor = nil

        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        navigationController.navigationBar.prefersLargeTitles = true
    }
}
