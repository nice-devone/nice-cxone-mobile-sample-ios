//
//  Extension.swift
//  iOSSDKExample
//
//  Created by Customer Dynamics Development on 11/11/21.
//

import Foundation
import UIKit

extension NSObject {
	func smSearch(text: String, action: Selector, afterDelay: Double = 0.5) {
		NSObject.cancelPreviousPerformRequests(withTarget: self)
		perform(action, with: text, afterDelay: afterDelay)
	}
}

extension UIImageView {
	func load(url: URL, completion: @escaping (_ image: UIImage) -> ()) {
		DispatchQueue.global().async { [weak self] in
			if let data = try? Data(contentsOf: url) {
				if let image = UIImage(data: data) {
					DispatchQueue.main.async {
						self?.image = image
						completion(image)
					}
				}
			}
		}
	}
}
