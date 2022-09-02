import Foundation
import UIKit
import CXOneChatSDK

/// A simple `UINavigationController` that hosts the `ThreadViewController`
@available(iOS 13.0, *)
public class ParentNavigationViewController: UINavigationController {
	
	var cxOneChat = CXOneChat.shared
	
	override public func viewDidLoad() {
		self.viewControllers = [ThreadViewController()]
	}
}
