import AuthenticationServices
import CXoneChatSDK
import LoginWithAmazon
import SwiftUI
import UIKit


internal class LoginViewController: BaseViewController, ViewRenderable {
    
    // MARK: - Properties
    
    let presenter: LoginPresenter
    private let myView = LoginView()
    
    
    // MARK: - Init
    
    internal required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
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
    }
    
    func render(state: LoginViewState) {
        if !state.isLoading {
            hideLoading()
        }
        
        switch state {
        case .loading:
            showLoading()
        case .loaded(let isOAuthHidden):
            myView.oAuthButton.isHidden = isOAuthHidden
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
