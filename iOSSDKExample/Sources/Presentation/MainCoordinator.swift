// swiftlint:disable trailing_closure

import CXoneChatSDK
import Swinject
import Toast
import UIKit


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
    
    func start() {
        showConfig()
    }
}


// MARK: - Navigation

private extension MainCoordinator {
    
    func showConfig() {
        let navigation = ConfigPresenter.Navigation(
            navigateToLogin: { [weak self] in self?.showLogin(connectionConfig: $0, channelConfig: $1) }
        )
        let presenter = ConfigPresenter(input: (), navigation: navigation, services: ())
        let controller = ConfigViewController(presenter: presenter)
        
        navigationController.show(controller, sender: self)
    }
    
    func showLogin(connectionConfig: ConnectionConfiguration, channelConfig: ChannelConfiguration) {
        let input = LoginPresenter.Input(connectionConfig: connectionConfig, channelConfig: channelConfig)
        let navigation = LoginPresenter.Navigation(
            navigateToThreads: { [weak self] config in self?.showThreadList(configuration: config) }
        )
        let presenter = LoginPresenter(input: input, navigation: navigation, services: ())
        let controller = LoginViewController(presenter: presenter)
        
        navigationController.show(controller, sender: self)
    }
    
    func showThreadList(configuration: ConnectionConfiguration) {
        let input = ThreadListPresenter.Input(connectionConfiguration: configuration)
        let navigation = ThreadListPresenter.Navigation(
            presentController: { [weak self] controller in self?.navigationController.present(controller, animated: true) },
            navigateToThread: { [weak self] thread in self?.showThread(thread) },
            navigateToLogin: { [weak self] in self?.navigationController.popViewController(animated: true) },
            navigateToConfiguration: { [weak self] in self?.navigationController.popToRootViewController(animated: true) },
            showProactiveActionPopup: { [weak self] data, actionId in self?.showProactiveActionPopup(data: data, actionId: actionId) }
        )
        let presenter = ThreadListPresenter(input: input, navigation: navigation, services: ())
        let controller = ThreadListViewController(presenter: presenter)
        
        navigationController.show(controller, sender: self)
    }
    
    func showProactiveActionPopup(data: [String: Any], actionId: UUID) {
        let controller = UIViewController()
        controller.view = ProActiveActionPopup(data: data, actionId: actionId)
        
        navigationController.show(controller, sender: self)
    }
    
    func showThread(_ thread: ChatThread) {
        let input = ThreadDetailPresenter.Input(thread: thread)
        let navigation = ThreadDetailPresenter.Navigation(
            showToast: { title, message in
                UIApplication.shared.rootViewController?.view.makeToast(message, duration: 2, position: .top, title: title, style: .init())
            },
            showController: { [weak self] controller in self?.navigationController.present(controller, animated: true) }
        )
        let presenter = ThreadDetailPresenter(input: input, navigation: navigation, services: ())
        let controller = ThreadDetailViewController(presenter: presenter)
        
        navigationController.show(controller, sender: self)
    }
}


// MARK: - Setup Bar Appereance

private extension MainCoordinator {
    
    func setupNavigationBar() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .white
        appearance.titleTextAttributes = [.foregroundColor: UIColor.black]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.black]
        appearance.shadowImage = nil
        appearance.shadowColor = nil

        UINavigationBar.appearance().tintColor = .black
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        navigationController.navigationBar.prefersLargeTitles = true
    }
}
