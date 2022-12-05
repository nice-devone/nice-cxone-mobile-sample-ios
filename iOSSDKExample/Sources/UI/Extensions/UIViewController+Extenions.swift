import Foundation
import UIKit


extension UIViewController {
        
    func showAlert(title: String, message: String? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        
        present(alert, animated: true) 
    }
    
    func showLoading(title: String? = nil) {
        let loadingViewController = LoadingViewController()
        loadingViewController.modalPresentationStyle = .overCurrentContext
        loadingViewController.modalTransitionStyle = .crossDissolve
        
        if let title {
            loadingViewController.titleLabel.isHidden = false
            loadingViewController.titleLabel.text = title
        } else {
            loadingViewController.titleLabel.isHidden = true
        }
        
        DispatchQueue.main.async {
            self.present(loadingViewController, animated: true)
        }
    }
    
    func hideLoading() {
        DispatchQueue.main.async {
            guard let controller = self.presentedViewController, controller is LoadingViewController else {
                return
            }
            
            controller.dismiss(animated: true, completion: nil)
        }
    }
}
