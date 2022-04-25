//
//  Created by Customer Dynamics Development on 9/10/21.
//

import UIKit
import SwiftUI
import MessageKit
import InputBarAccessoryView

/// MessageLabelDelegate
@available(iOS 13.0, *)
extension ChatViewController: MessageLabelDelegate {
	// Functions that may or may not be used in the future.
	// Ignore for now.
	public func didSelectAddress(_ addressComponents: [String: String]) {
		print("Address Selected: \(addressComponents)")
	}
	
	public func didSelectDate(_ date: Date) {
		print("Date Selected: \(date)")
	}
	
	public func didSelectPhoneNumber(_ phoneNumber: String) {
		print("Phone Number Selected: \(phoneNumber)")
	}
	
	public func didSelectURL(_ url: URL) {
		print("URL Selected: \(url)")
	}
	
	public func didSelectTransitInformation(_ transitInformation: [String: String]) {
		print("TransitInformation Selected: \(transitInformation)")
	}

	public func didSelectHashtag(_ hashtag: String) {
		print("Hashtag selected: \(hashtag)")
	}

	public func didSelectMention(_ mention: String) {
		print("Mention selected: \(mention)")
	}

	public func didSelectCustom(_ pattern: String, match: String?) {
		print("Custom data detector patter selected: \(pattern)")
	}
}
