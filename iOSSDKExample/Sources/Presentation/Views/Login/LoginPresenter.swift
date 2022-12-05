import AuthenticationServices
import CXoneChatSDK
import Foundation
import LoginWithAmazon
import PKCE


class LoginPresenter: BasePresenter<LoginPresenter.Input, LoginPresenter.Navigation, Void, LoginViewState> {

    // MARK: - Structs
    
    struct Input {
        var connectionConfig: ConnectionConfiguration
        var channelConfig: ChannelConfiguration
    }

    struct Navigation {
        var navigateToThreads: (ConnectionConfiguration) -> Void
    }
    
    struct DocumentState {
        var isOAuthHidden: Bool
    }
    
    
    // MARK: - Properties
    
    lazy var documentState = DocumentState(
        isOAuthHidden: !input.channelConfig.isAuthorizationEnabled
    )
    
    
    // MARK: - Init
    
    override func viewDidSubscribe() {
        super.viewDidSubscribe()
        
        viewState.toLoaded(isOAuthHidden: documentState.isOAuthHidden)
    }
}


// MARK: - Actions

extension LoginPresenter {
    
    @objc
    func onContinueAsGuestTapped() {
        navigation.navigateToThreads(input.connectionConfig)
    }
    
    @objc
    func onLoginTapped() {
        viewState.toLoading()
        
        let request = AMZNAuthorizeRequest()
        request.scopes = [AMZNProfileScope.userID(), AMZNProfileScope.profile()]
        request.codeChallengeMethod = "S256"
        request.grantType = .code
        
        do {
            let codeVerifier = try generateCodeVerifier()
            request.codeChallenge = try generateCodeChallenge(for: codeVerifier)
            
            CXoneChat.shared.customer.setCodeVerifier(codeVerifier)
        } catch {
            error.logError()
            viewState.toError(title: "Ops!", message: "Something went wrong.")
            return
        }
        
        AMZNAuthorizationManager.shared().authorize(request) { [weak self] result, _, error in
            guard let self = self else {
                return
            }
            
            error?.logError()
            
            guard let result = result else {
                Log.error(CommonError.unableToParse("result"))
                self.viewState.toError(title: "Ops!", message: "Something went wrong.")
                return
            }
            
            CXoneChat.shared.customer.setAuthorizationCode(result.authorizationCode)
            
            self.viewState.toLoaded(isOAuthHidden: self.documentState.isOAuthHidden)
            
            self.navigation.navigateToThreads(self.input.connectionConfig)
        }
    }
}
