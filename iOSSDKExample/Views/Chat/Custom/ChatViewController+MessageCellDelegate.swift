//
//  Created by Customer Dynamics Development on 9/10/21.
//

import UIKit
import SwiftUI
import MessageKit
import InputBarAccessoryView

// MARK: - MessageCellDelegate
@available(iOS 13.0, *)
extension ChatViewController: MessageCellDelegate {
	// Functions that may or may not be used in the future.
	// Ignore for now.
	public func didTapAvatar(in cell: MessageCollectionViewCell) {
		print("Avatar tapped")
	}
	
	public func didTapMessage(in cell: MessageCollectionViewCell) {
		guard let indexPath = messagesCollectionView.indexPath(for: cell) else {
				print("Failed to identify message when audio cell receive tap gesture")
				return
		}
		let message = sdkClient.threads[threadIndex].messages[indexPath.section]
		if message.messageType == .plugin {
			AlertService.showAlert(style: .alert, title: "Alert", message: "Plugin has been tapped")
		}
	}
	
	public func didTapImage(in cell: MessageCollectionViewCell) {
		print("Image tapped")
	}
	
	public func didTapCellTopLabel(in cell: MessageCollectionViewCell) {
		print("Top cell label tapped")
	}
	
	public func didTapCellBottomLabel(in cell: MessageCollectionViewCell) {
		print("Bottom cell label tapped")
	}
	
	public func didTapMessageTopLabel(in cell: MessageCollectionViewCell) {
		print("Top message label tapped")
	}
	
	public func didTapMessageBottomLabel(in cell: MessageCollectionViewCell) {
		print("Bottom label tapped")
	}
	
	public func didStartAudio(in cell: AudioMessageCell) {
		print("Did start playing audio sound")
	}

	public func didPauseAudio(in cell: AudioMessageCell) {
		print("Did pause audio sound")
	}

	public func didStopAudio(in cell: AudioMessageCell) {
		print("Did stop audio sound")
	}

	public func didTapAccessoryView(in cell: MessageCollectionViewCell) {
		print("Accessory view tapped")
	}
	
	/// Play audio from an `AudioMessageCell`
	/// - Parameter cell: The current `AudioMessageCell`
	public func didTapPlayButton(in cell: AudioMessageCell) {
		guard let indexPath = messagesCollectionView.indexPath(for: cell),
			let message = messagesCollectionView.messagesDataSource?.messageForItem(at: indexPath, in: messagesCollectionView) else {
				print("Failed to identify message when audio cell receive tap gesture")
				return
		}
		guard audioController.state != .stopped else {
			// There is no audio sound playing - prepare to start playing for given audio message
			audioController.playSound(for: message, in: cell)
			return
		}
		if audioController.playingMessage?.messageId == message.messageId {
			// tap occur in the current cell that is playing audio sound
			if audioController.state == .playing {
				audioController.pauseSound(for: message, in: cell)
			} else {
				audioController.resumeSound()
			}
		} else {
			// tap occur in a difference cell that the one is currently playing sound. First stop currently playing and start the sound for given message
			audioController.stopAnyOngoingPlaying()
			audioController.playSound(for: message, in: cell)
		}
	}
}
