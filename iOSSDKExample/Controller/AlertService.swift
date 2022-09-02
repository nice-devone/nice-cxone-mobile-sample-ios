import Foundation
import UIKit


/// Used for choosing which type of photo system we want to use when sending a message.
class AlertService {
	static func showAlert(style: UIAlertController.Style, title: String?, message: String?, actions: [UIAlertAction] = [UIAlertAction(title: "Ok", style: .cancel, handler: nil)], completion: (() -> Swift.Void)? = nil) {
		let alert = UIAlertController(title: title, message: message, preferredStyle: style)
		for action in actions {
			alert.addAction(action)
		}
		guard let rootViewController = (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.window?.rootViewController else {
			return
		}
		rootViewController.present(alert, animated: true, completion: completion)
	}
}
