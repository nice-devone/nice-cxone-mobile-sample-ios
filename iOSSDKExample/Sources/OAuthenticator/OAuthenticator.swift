import Foundation


/// an object capable of performing OAuth authentication
protocol OAuthenticator {

    // MARK: - Type Aliases

    /// Invoked when an authentication request completes
    ///
    /// - parameters:
    ///     - cancelled: true iff the request was cancelled
    ///     - result: if the request was successful, will contain details of the success
    ///     - error: if the request was unsuccessful will contain details of the failure
    typealias OAAuthenticationHandler = (_ cancelled: Bool, _ result: OAResult?, _ error: Error?) -> Void

    /// Invoked when an signOut request completes
    ///
    /// - parameters:
    ///     - error: if the request was unsuccessful will contain details of the failure
    typealias OASignoutHandler = (_ error: Error?) -> Void


    // MARK: - Properties

    /// user presentable name of authenticator
    var authenticatorName: String { get }

    // MARK: - Methods

    /// attempt OAuth authentication using this authenticator
    ///
    /// - parameters:
    ///     - withChallenge: Challenge string
    ///     - onCompletion: routine to invoke on completion of request
    func authorize(withChallenge: String, onCompletion: @escaping OAAuthenticationHandler)

    /// attempt to logout any cached user results
    ///
    /// - parameters:
    ///     - onCompletion: routine to invoke on completion of request
    func signOut(onCompletion: @escaping OASignoutHandler)

    /// handle an open url request from the application, this may be required to complete
    /// some varieties of OAuth
    ///
    /// - parameters:
    ///     - url: url being opened
    ///     - sourceApplication: name of application originating request
    func handleOpen(url: URL, sourceApplication: String?) -> Bool
}
