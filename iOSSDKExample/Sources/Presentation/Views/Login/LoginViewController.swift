import AuthenticationServices
import CXoneChatSDK
import SwiftUI
import UIKit


class LoginViewController: BaseViewController, ViewRenderable {
    
    // MARK: - Properties
    
    let presenter: LoginPresenter
    private let myView = LoginView()
    
    
    // MARK: - Init
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(presenter: LoginPresenter) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }


    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter.subscribe(from: self)
    }
    
    override func loadView() {
        super.loadView()
        
        title = "Login"
        view = myView
        
        myView.oAuthButton.addTarget(presenter, action: #selector(presenter.onLoginTapped), for: .touchUpInside)
        myView.guestButton.addTarget(presenter, action: #selector(presenter.onContinueAsGuestTapped), for: .touchUpInside)
        
        let disconnectButton = UIBarButtonItem(
            image: UIImage(systemName: "bolt.slash.fill"),
            style: .plain,
            target: presenter,
            action: #selector(presenter.onDisconnectTapped)
        )
        disconnectButton.tintColor = .primaryColor
        
        navigationItem.leftBarButtonItem = disconnectButton
    }
    
    func render(state: LoginViewState) {
        if !state.isLoading {
            hideLoading()
        }
        
        switch state {
        case .loading:
            showLoading()
        case .loaded(let documentState):
            // OAuth button is hidden if it's hidden by configuration *or* if there's no configured oauth authenticator.
            myView.oAuthButton.isHidden = documentState.isOAuthHidden || OAuthenticators.authenticator == nil
        case .error(let title, let message):
            showAlert(title: title, message: message)
        }
    }
}


// MARK: - ASAuthorizationControllerPresentationContextProviding

extension LoginViewController: ASAuthorizationControllerPresentationContextProviding {
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        guard let window = view.window else {
            Log.error(CommonError.unableToParse("window", from: view))
            return ASPresentationAnchor()
        }
        
        return window
    }
}
