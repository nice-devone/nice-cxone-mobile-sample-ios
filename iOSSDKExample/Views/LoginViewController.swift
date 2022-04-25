//
//  LoginViewController.swift
//  iOSSDKExample
//
//  Created by kjoe on 2/17/22.
//

import UIKit
import AuthenticationServices
import CXOneChatSDK
import LoginWithAmazon
import PKCE
import SwiftUI
import KeychainSwift
class LoginViewController: UIViewController {

    @IBOutlet weak var guestButton: UIButton!
    var config: ChannelConfiguration? {
        didSet {
            print("set config")
        }
    }
    var closure: ((ChannelConfiguration)->Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let authorizationButton = ASAuthorizationAppleIDButton()
        authorizationButton.translatesAutoresizingMaskIntoConstraints = false
        authorizationButton.addTarget(self, action: #selector(handleAuthorizationAppleIDButtonPress), for: .touchUpInside)
        view.addSubview(authorizationButton)
        authorizationButton.topAnchor.constraint(equalTo: guestButton.bottomAnchor, constant: 20).isActive = true
        authorizationButton.centerXAnchor.constraint(equalTo: guestButton.centerXAnchor).isActive = true
    }
    
//    func saveConfig(config: ChannelConfiguration) {
//        self.config = config
//    }
    
    func gotToMain() {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController()
        view.window?.rootViewController = vc
    }
    
    
}

extension LoginViewController {
    @objc func handleAuthorizationAppleIDButtonPress() {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
}
extension LoginViewController: ASAuthorizationControllerDelegate {
    fileprivate func saveToken(_ idTokenString: String) {
        KeychainSwift().set(idTokenString, forKey: "token")
    }
    
    fileprivate func saveUser(name: String) {
        let user = Customer(senderId: UUID().uuidString, displayName: name)
        let data = try? JSONEncoder().encode(user)
        guard let data = data else {return}
        KeychainSwift().set(data, forKey: "user")
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            guard let appleIDToken = appleIDCredential.identityToken else {
                print("Unable to fetch identity token")
                return
            }
            
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
                return
            }
            saveToken(idTokenString)
            
            let name: String
            if #available(iOS 15, *) {
                name = appleIDCredential.fullName?.formatted() ?? ""
            }else {
                name = "\(appleIDCredential.fullName?.givenName ?? "")  \(appleIDCredential.fullName?.familyName ?? "" )"
            }
            saveUser(name: name)
            DispatchQueue.main.async {
                self.continueAsGuest(self)
            }
        }
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        guard let error = error as? ASAuthorizationError else {
            return
        }

        switch error.code {
        case .canceled:
            print("Canceled")
        case .unknown:
            print("Unknown")
        case .invalidResponse:
            print("Invalid Respone")
        case .notHandled:
            print("Not handled")
        case .failed:
            print("Failed")
        case .notInteractive:
            print("failed")
        @unknown default:
            print("Default")
        }
    }
}

extension LoginViewController: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
}
extension LoginViewController {
    @IBAction func continueAsGuest(_ sender: Any) {
        KeychainSwift().delete("accessToken")
        KeychainSwift().delete("visitorId")
        KeychainSwift().delete("customer")
        self.gotToMain()
    }
}

extension LoginViewController {
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
            self.saveToken(result.token)
            self.saveUser(name: result.user?.name ?? "")
            UserDefaults.standard.set(true, forKey: "run")
            DispatchQueue.main.async {
                self.gotToMain()
            }
        })
    }
}
//extension LoginViewController: LoginButtonDelegate {
    
//
//
//  func setupLoginButton() {
//      let loginButton = FBLoginButton()
//      loginButton.permissions = ["public_profile"]
//      //loginButton.center = view.center
//      loginButton.delegate = self
//      loginButton.translatesAutoresizingMaskIntoConstraints = false
//      view.addSubview(loginButton)
//      loginButton.bottomAnchor.constraint(equalTo: guestButton.topAnchor, constant: -20).isActive = true
//      loginButton.centerXAnchor.constraint(equalTo: guestButton.centerXAnchor).isActive = true
//      loginButton.heightAnchor.constraint(equalTo: guestButton.heightAnchor).isActive = true
//      loginButton.widthAnchor.constraint(equalTo: guestButton.widthAnchor).isActive = true
//  }
//
//  func loginButton( _ loginButton: FBLoginButton, didCompleteWith potentialResult: LoginManagerLoginResult?, error potentialError: Error?) {
//      if let error = potentialError {
//          print(error.localizedDescription)
//      }
//
//      guard let result = potentialResult else {
//          return
//      }
//
//      guard !result.isCancelled else {
//       return
//      }
//
//      let tokenString = AuthenticationToken.current?.tokenString ?? ""
//      print(tokenString)
//      //self.saveToken(tokenString)
//      CXOneChat.shared.setAuthCode(code: tokenString)
//      let name  = Profile.current?.name ?? ""
//      print("the name got:", name, Profile.current.debugDescription)
//      self.saveUser(name: name)
//      DispatchQueue.main.async {
//          self.continueAsGuest(self)
//      }
//  }
//    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
//        UserDefaults.standard.removeObject(forKey: "user")
//    }
//}
