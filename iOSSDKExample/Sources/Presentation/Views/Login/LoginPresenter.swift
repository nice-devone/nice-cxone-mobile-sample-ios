import AuthenticationServices
import CXoneChatSDK
import Foundation
import PKCE


class LoginPresenter: BasePresenter<LoginPresenter.Input, LoginPresenter.Navigation, Void, LoginViewState> {

    // MARK: - Structs
    
    struct Input {
        var configuration: Configuration
        var isAuthorizationEnabled: Bool
    }

    struct Navigation {
        var navigateToThreads: (Configuration) -> Void
    }
    
    struct DocumentState {
        var isOAuthHidden: Bool
    }
    
    
    // MARK: - Properties
    
    lazy var documentState = DocumentState(isOAuthHidden: !input.isAuthorizationEnabled)
    
    
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
        navigation.navigateToThreads(input.configuration)
    }
    
    @objc
    func onLoginTapped() {
        viewState.toLoading()

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

                self.viewState.toLoaded(isOAuthHidden: self.documentState.isOAuthHidden)

                self.navigation.navigateToThreads(self.input.configuration)
            }
        } catch {
            error.logError()
            viewState.toError(title: "Ops!", message: "Something went wrong.")
            return
        }
    }
}
