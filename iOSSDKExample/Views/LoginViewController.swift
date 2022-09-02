import UIKit
import AuthenticationServices
import CXOneChatSDK
import LoginWithAmazon
import PKCE
import SwiftUI
import CXOneChatSDK

class LoginViewController: UIViewController {
    @IBOutlet weak var guestButton: UIButton!
    @IBOutlet weak var oAuthButton: UIButton!
    public var channelConfig: ChannelConfiguration!

    override func viewDidLoad() {
        super.viewDidLoad()
//        let signInWithAppleButton = ASAuthorizationAppleIDButton()
//        signInWithAppleButton.translatesAutoresizingMaskIntoConstraints = false
//        signInWithAppleButton.addTarget(self, action: #selector(handleAuthorizationAppleIDButtonPress), for: .touchUpInside)
//        view.addSubview(signInWithAppleButton)
//        signInWithAppleButton.topAnchor.constraint(equalTo: guestButton.bottomAnchor, constant: 20).isActive = true
//        signInWithAppleButton.centerXAnchor.constraint(equalTo: guestButton.centerXAnchor).isActive = true
        
        if channelConfig.isAuthorizationEnabled {
            self.guestButton.isHidden = true
            self.oAuthButton.isHidden = false
        } else {
            self.oAuthButton.isHidden = true
            self.guestButton.isHidden = false
        }
    }
    
    func goToMain() {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController()
        view.window?.rootViewController = vc
    }
    
//    @objc func handleAuthorizationAppleIDButtonPress() {
//        let appleIDProvider = ASAuthorizationAppleIDProvider()
//        let request = appleIDProvider.createRequest()
//        request.requestedScopes = [.fullName, .email]
//
//        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
//        authorizationController.delegate = self
//        authorizationController.presentationContextProvider = self
//        authorizationController.performRequests()
//    }
    
    @IBAction func continueAsGuest(_ sender: Any) {
        self.goToMain()
    }
    
    @IBAction func login(_ sender: Any) {
        let request = AMZNAuthorizeRequest()
        request.scopes = [AMZNProfileScope.userID(),AMZNProfileScope.profile()]
        request.grantType = AMZNAuthorizationGrantType.code
        do {
            let codeVerifier = try generateCodeVerifier()
            request.codeChallenge = try generateCodeChallenge(for: codeVerifier)
            request.codeChallengeMethod = "S256"
            CXOneChat.shared.setCodeVerifier(codeVerifier: codeVerifier)
        } catch {
            _ = Alert(title: Text("Unable to login with Amazon"))
        }
        
        AMZNAuthorizationManager.shared().authorize(request, withHandler: {[unowned self] result, userDidCancel, error in
            if let error = error {
                print(error.localizedDescription)
            }
            guard let result = result else {return}
            CXOneChat.shared.setAuthCode(authCode: result.authorizationCode)
            UserDefaults.standard.set(true, forKey: "run")
            DispatchQueue.main.async {
                self.goToMain()
            }
        })
    }
}

//extension LoginViewController: ASAuthorizationControllerDelegate {
//
//    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
//        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
//            guard let appleIDToken = appleIDCredential.identityToken else {
//                print("Unable to fetch identity token")
//                return
//            }
//
//            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
//                print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
//                return
//            }
//
//            // Name should be given from OAuth
////            let name: String
////            if #available(iOS 15, *) {
////                name = appleIDCredential.fullName?.formatted() ?? ""
////            }else {
////                name = "\(appleIDCredential.fullName?.givenName ?? "")  \(appleIDCredential.fullName?.familyName ?? "" )"
////            }
//            DispatchQueue.main.async {
//                self.continueAsGuest(self)
//            }
//        }
//    }
//
//    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
//        guard let error = error as? ASAuthorizationError else {
//            return
//        }
//
//        switch error.code {
//        case .canceled:
//            print("Canceled")
//        case .unknown:
//            print("Unknown")
//        case .invalidResponse:
//            print("Invalid Response")
//        case .notHandled:
//            print("Not handled")
//        case .failed:
//            print("Failed")
//        case .notInteractive:
//            print("Failed")
//        @unknown default:
//            print("Default")
//        }
//    }
//}

extension LoginViewController: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
}
