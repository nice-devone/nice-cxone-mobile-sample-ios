import AuthenticationServices
import CXoneChatSDK
import Foundation
import PKCE


class LoginPresenter: BasePresenter<LoginPresenter.Input, LoginPresenter.Navigation, Void, LoginViewState> {

    // MARK: - Structs
    
    struct Input {
        var configuration: Configuration
        var option: DeeplinkOption?
    }

    struct Navigation {
        var navigateToThreads: (Configuration, DeeplinkOption?) -> Void
        var navigateToConfiguration: () -> Void
        var presentController: (UIViewController) -> Void
    }
    
    struct DocumentState {
        var isOAuthHidden = true
    }
    
    
    // MARK: - Properties
    
    lazy var documentState = DocumentState()
    
    
    // MARK: - Init
    
    override func viewDidSubscribe() {
        super.viewDidSubscribe()
        
        Task { @MainActor in
            do {
                let channelConfig: ChannelConfiguration
                
                if let environment = input.configuration.environment {
                    channelConfig = try await CXoneChat.shared.connection.getChannelConfiguration(
                        environment: environment,
                        brandId: input.configuration.brandId,
                        channelId: input.configuration.channelId
                    )
                } else {
                    channelConfig = try await CXoneChat.shared.connection.getChannelConfiguration(
                        chatURL: input.configuration.chatUrl,
                        brandId: input.configuration.brandId,
                        channelId: input.configuration.channelId
                    )
                }
                
                documentState.isOAuthHidden = !channelConfig.isAuthorizationEnabled
                
                if input.option != nil {
                    handleDeeplink()
                } else {
                    viewState.toLoaded(documentState: documentState)
                }
            } catch {
                error.logError()
                
                viewState.toError(title: "Oops!", message: "We couldn't get the configuration for selected channel. Please, try it operation again.")
                
                navigation.navigateToConfiguration()
            }
        }
    }
}


// MARK: - Actions

extension LoginPresenter {
    
    @objc
    func onDisconnectTapped() {
        let controller = UIAlertController(
            title: nil,
            message: "You are about to sign out from selected channel. Do you want to proceed?",
            preferredStyle: .alert
        )
        controller.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        controller.addAction(UIAlertAction(title: "Sign Out", style: .destructive) { [weak self] _ in
            LocalStorageManager.configuration = nil
            CXoneChat.signOut()
            
            self?.navigation.navigateToConfiguration()
        })
        
        navigation.presentController(controller)
    }
    
    @objc
    func onContinueAsGuestTapped() {
        navigation.navigateToThreads(input.configuration, nil)
    }
    
    @objc
    func onLoginTapped() {
        viewState.toLoading()

        handleOAuthLogin()
    }
}


// MARK: - Private methods

private extension LoginPresenter {
    
    func handleDeeplink() {
        if documentState.isOAuthHidden {
            navigation.navigateToThreads(input.configuration, input.option)
        } else {
            handleOAuthLogin()
        }
    }
    
    func handleOAuthLogin() {
        guard let authenticator = OAuthenticators.authenticator else {
            viewState.toError(title: "Oops!", message: "No available authenticators")
            return
        }

        do {
            let verifier = try generateCodeVerifier()
            let challenge = try generateCodeChallenge(for: verifier)

            CXoneChat.shared.customer.setCodeVerifier(verifier)

            authenticator.authorize(withChallenge: challenge) { [weak self] _, result, error in
                guard let self = self else {
                    return
                }

                error?.logError()

                guard let result = result else {
                    Log.error(CommonError.unableToParse("result"))
                    self.viewState.toError(title: "Ops!", message: "Something went wrong.")
                    return
                }

                CXoneChat.shared.customer.setAuthorizationCode(result.challengeResult)

                self.viewState.toLoaded(documentState: self.documentState)

                self.navigation.navigateToThreads(self.input.configuration, self.input.option)
            }
        } catch {
            error.logError()
            
            viewState.toError(title: "Ops!", message: "Something went wrong.")
        }
    }
}
