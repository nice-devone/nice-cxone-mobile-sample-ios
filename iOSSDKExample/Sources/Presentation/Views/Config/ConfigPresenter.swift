import CXoneChatSDK
import Foundation


class ConfigPresenter: BasePresenter<Void, ConfigPresenter.Navigation, Void, ConfigViewState> {

    // MARK: - Structs

    struct Navigation {
        var navigateToLogin: (ConnectionConfiguration, ChannelConfiguration) -> Void
    }
    
    struct DocumentState {
        let configurations: [ConnectionConfiguration] = [
            .init(connectionConfigurationType: .LS),
            .init(connectionConfigurationType: .CD),
            .init(connectionConfigurationType: .MJ),
            .init(connectionConfigurationType: .Sales)
        ]
        let environmnets: [ConnectionConfiguration] = [
            .init(connectionEnvironmentType: .QA),
            .init(connectionEnvironmentType: .NA1)
        ]
        var defaultConfiguration = ConnectionConfiguration(connectionConfigurationType: .LS)
        var customConfiguration = ConnectionConfiguration(connectionEnvironmentType: .NA1)
        var isCustomConfigurationHidden = true
        
        var currentConfiguration: ConnectionConfiguration {
            isCustomConfigurationHidden ? defaultConfiguration : customConfiguration
        }
    }
    
    
    // MARK: - Properties
    
    private lazy var documentState = DocumentState()
    
    
    // MARK: - Init
    
    override func viewDidSubscribe() {
        super.viewDidSubscribe()
        
        viewState.toLoaded(documentState: documentState)
    }
}


// MARK: - Actions

extension ConfigPresenter {
    
    @MainActor
    func onContinueButtonTapped() async {
        guard isValid() else {
            viewState.toError(title: "All Fields Required", message: "Please provide a value for all fields.")
            return
        }
        
        viewState.toLoading(title: "Getting channel configuration...")
        
        do {
            let channelConfig: ChannelConfiguration
            
            if documentState.currentConfiguration.isCustomEnvironment {
                channelConfig = try await CXoneChat.shared.connection.getChannelConfiguration(
                    chatURL: documentState.currentConfiguration.chatUrl,
                    brandId: documentState.currentConfiguration.brandId,
                    channelId: documentState.currentConfiguration.channelId
                )
            } else {
                guard let environment = documentState.currentConfiguration.environment else {
                    Log.error(CommonError.unableToParse("environment"))
                    return
                }
                
                channelConfig = try await CXoneChat.shared.connection.getChannelConfiguration(
                    environment: environment,
                    brandId: documentState.currentConfiguration.brandId,
                    channelId: documentState.currentConfiguration.channelId
                )
            }
            
            navigation.navigateToLogin(documentState.currentConfiguration, channelConfig)
            
            viewState.toLoaded(documentState: documentState)
        } catch {
            error.logError()
            
            viewState.toError(
                title: "Channel Configuration Error",
                message: "Something went wrong - We couldn't get the configuration for channel. Please check your selection and try again."
            )
        }
    }
    
    func onConfigurationChanged(_ configuration: ConnectionConfiguration) {
        documentState.isCustomConfigurationHidden = configuration.connectionConfigurationType != nil
        
        if documentState.isCustomConfigurationHidden {
            documentState.defaultConfiguration = configuration
        } else {
            documentState.customConfiguration = configuration
        }

        viewState.toLoaded(documentState: documentState)
    }
    
    func onBrandIdChanged(_ brandId: String?) {
        if let brandId, let brandId = Int(brandId) {
            documentState.customConfiguration.brandId = Int(brandId)
        }
    }
    
    func onChannelIdChanged(_ channelId: String?) {
        if let channelId {
            documentState.customConfiguration.channelId = channelId
        }
    }
    
    func onToggleCustomConfiguration(isHidden: Bool) {
        documentState.isCustomConfigurationHidden = isHidden
        
        viewState.toLoaded(documentState: documentState)
    }
}


// MARK: - Private methods

private extension ConfigPresenter {
    
    func isValid() -> Bool {
        // Check if current configuration is on predefined
        guard documentState.isCustomConfigurationHidden else {
            return true
        }
        
        return documentState.currentConfiguration.brandId != 0 && !documentState.currentConfiguration.channelId.isEmpty
    }
}
