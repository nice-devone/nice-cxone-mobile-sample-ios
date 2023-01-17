import Foundation
import LoginWithAmazon


class LoginWithAmazonAuthenticator: OAuthenticator {

    // MARK: - Properties

    private let manager: AMZNAuthorizationManager

    /// authenticator name
    let authenticatorName = "Amazon"


    // MARK: - Initialization

    static func initialize() {
        let authenticator = LoginWithAmazonAuthenticator(manager: AMZNAuthorizationManager.shared())
        OAuthenticators.register(authenticator: authenticator)
    }

    init(manager: AMZNAuthorizationManager) {
        self.manager = manager
    }


    // MARK: - Methods

    /// attempt OAuth authentication using this authenticator
    ///
    /// - parameters:
    ///     - withChallenge: Challenge string
    ///     - onCompletion: routine to invoke on completion of request
    func authorize(withChallenge: String, onCompletion: @escaping OAAuthenticationHandler) {
        let request = AMZNAuthorizeRequest()
        request.scopes = [AMZNProfileScope.userID(), AMZNProfileScope.profile()]
        request.codeChallengeMethod = "S256"
        request.grantType = .code
        request.codeChallenge = withChallenge

        manager.authorize(request) { result, cancelled, error in
            if let result = result {
                onCompletion(cancelled, OAResult(challengeResult: result.authorizationCode), error)
            } else {
                onCompletion(cancelled, nil, error)
            }
        }
    }

    /// attempt to clear OAuth login status of this authenticator
    ///
    /// - parameters:
    ///     - onCompletion: routine to invoke on completion of request
    func signOut(onCompletion: @escaping OASignoutHandler) {
        manager.signOut(onCompletion)
    }

    /// handle an open url request from the application, this may be required to complete
    /// some varieties of OAuth
    ///
    /// - parameters:
    ///     - url: url being opened
    ///     - sourceApplication: name of application originating request
    func handleOpen(url: URL, sourceApplication: String?) -> Bool {
        AMZNAuthorizationManager.handleOpen(url, sourceApplication: sourceApplication)
    }
}
