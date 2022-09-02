import Foundation
import UIKit

public extension UIViewController {
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        self.showDetailViewController(alert, sender: self)
    }
    
    // TODO: Handle this in a message cell instead
    func parsePluginMessage(_ data: [Any]) {
        var messages = ""
        let object = data[0] as! [String: Any]
        let variables = object["variables"] as! NSDictionary
        for (key,val)in variables {
            messages.append("\(key): \(val) \n ")
        }
        DispatchQueue.main.async {[weak self] in
            self?.showAlert(title: "Plugin received:", message: messages)
        }
    }
}
