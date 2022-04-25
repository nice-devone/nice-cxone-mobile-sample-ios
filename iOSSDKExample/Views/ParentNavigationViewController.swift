//
//  Created by Customer Dynamics Development on 9/8/21.
//

import Foundation
import UIKit
import CXOneChatSDK

/// A simple `UINavigationController` that hosts the `ThreadViewController`
@available(iOS 13.0, *)
public class ParentNavigationViewController: UINavigationController {
	
	var sdkClient = CXOneChat.shared
	
	override public func viewDidLoad() {
		self.viewControllers = [ThreadViewController()]
	}
}
