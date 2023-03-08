import CXoneChatSDK
import Foundation
import UIKit


class ConfigPresenter: BasePresenter<Void, ConfigPresenter.Navigation, Void, ConfigViewState> {

    // MARK: - Structs

    struct Navigation {
        var navigateToLogin: (Configuration, _ isAuthorizationEnabled: Bool) -> Void
        var showController: (UIViewController) -> Void
    }
    
    struct DocumentState {
        var configurations = [Configuration]()
        var isCustomConfigurationHidden = true
        
        var defaultConfiguration = Configuration(brandId: 0, channelId: "", environment: .NA1)
        var customConfiguration = Configuration(title: "", brandId: 0, channelId: "", environmentName: "", chatUrl: "", socketUrl: "")
        
        var currentConfiguration: Configuration {
            isCustomConfigurationHidden ? defaultConfiguration : customConfiguration
        }
    }
    
    
    // MARK: - Properties
    
    private lazy var documentState = DocumentState()
    
    
    // MARK: - Init
    
    override func viewDidSubscribe() {
        super.viewDidSubscribe()
        
        Task { @MainActor in
            await fetchConfigurations()
            
            viewState.toLoaded(documentState: documentState)
        }
    }
}


// MARK: - Actions

extension ConfigPresenter {
    
    @objc
    func onDebugTapped() {
        let shareLogs = UIAlertAction(title: "Share Logs", style: .default) { _ in
            do {
                self.navigation.showController(try Log.getLogShareDialog())
            } catch {
                error.logError()
            }
        }
        let removeLogs = UIAlertAction(title: "Remove Logs", style: .destructive) { _ in
            do {
                try Log.removeLogs()
            } catch {
                error.logError()
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        UIAlertController.show(.actionSheet, title: "Options", message: nil, actions: [shareLogs, removeLogs, cancelAction])
    }
    
    @MainActor
    func onContinueButtonTapped() async {
        guard isConfigurationValid() else {
            viewState.toError(title: "All Fields Required", message: "Please provide a value for all fields.")
            return
        }
        
        viewState.toLoading(title: "Getting channel configuration...")
        
        do {
            let channelConfig: ChannelConfiguration
            
            if documentState.isCustomConfigurationHidden {
                guard let environment = documentState.defaultConfiguration.environment else {
                    viewState.toError(title: "Ops!", message: "Something went wrong! Try it again later.")
                    return
                }
                
                channelConfig = try await CXoneChat.shared.connection.getChannelConfiguration(
                    environment: environment,
                    brandId: documentState.defaultConfiguration.brandId,
                    channelId: documentState.defaultConfiguration.channelId
                )
            } else {
                channelConfig = try await CXoneChat.shared.connection.getChannelConfiguration(
                    chatURL: documentState.customConfiguration.chatUrl,
                    brandId: documentState.customConfiguration.brandId,
                    channelId: documentState.customConfiguration.channelId
                )
            }
            
            navigation.navigateToLogin(documentState.currentConfiguration, channelConfig.isAuthorizationEnabled)
            
            viewState.toLoaded(documentState: documentState)
        } catch {
            error.logError()
            
            viewState.toError(
                title: "Channel Configuration Error",
                message: "Something went wrong - We couldn't get the configuration for channel. Please check your selection and try again."
            )
        }
    }
    
    func onConfigurationChanged(_ configuration: Configuration) {
        documentState.customConfiguration = configuration
        
        viewState.toLoaded(documentState: documentState)
    }
    
    func onEnvironmentChanged(_ environment: CXoneChatSDK.Environment) {
        documentState.defaultConfiguration.title = environment.rawValue
        documentState.defaultConfiguration.environmentName = environment.rawValue
        documentState.defaultConfiguration.socketUrl = environment.socketURL
        documentState.defaultConfiguration.chatUrl = environment.chatURL
        
        viewState.toLoaded(documentState: documentState)
    }
    
    func onBrandIdChanged(_ brandId: String?) {
        if let brandId, let brandId = Int(brandId) {
            documentState.defaultConfiguration.brandId = brandId
        }
    }
    
    func onChannelIdChanged(_ channelId: String?) {
        if let channelId {
            documentState.defaultConfiguration.channelId = channelId
        }
    }
    
    func onToggleCustomConfiguration(isHidden: Bool) {
        documentState.isCustomConfigurationHidden = isHidden
        
        viewState.toLoaded(documentState: documentState)
    }
}


// MARK: - Private methods

private extension ConfigPresenter {

    func isConfigurationValid() -> Bool {
        guard documentState.isCustomConfigurationHidden else {
            return true
        }
        
        return documentState.defaultConfiguration.brandId != 0 && !documentState.defaultConfiguration.channelId.isEmpty
    }
    
    @MainActor
    func fetchConfigurations() async {
        guard let filePath = Bundle.main.path(forResource: "environment", ofType: "json") else {
            Log.error(.failed("Could not get file with configurations."))
            return
        }
        
        do {
            guard let data = try String(contentsOfFile: filePath).data(using: .utf8) else {
                Log.error(.failed("Could not get data from file."))
                return
            }

            guard let configurations = try JSONDecoder().decode(Configurations.self, from: data).configurations else {
                Log.error(.failed("Could not get configuration from data."))
                return
            }

            documentState.configurations = configurations

            if let configuration = configurations.first {
                documentState.customConfiguration = configuration
            }
        } catch {
            Log.error(.error(error))
        }
    }
}
