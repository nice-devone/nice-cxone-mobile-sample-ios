import UIKit
import SwiftUI
import MessageKit
import InputBarAccessoryView
import AVKit
import ALProgressView
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
		let message = thread.messages[indexPath.section]
        if message.messageContent.type == .plugin {
			AlertService.showAlert(style: .alert, title: "Alert", message: "Plugin has been tapped")
		}
	}
	
	public func didTapImage(in cell: MessageCollectionViewCell) {
        print("image tapped")
        let mediaCell = (cell as? MediaMessageCell)
        if !(mediaCell?.playButtonView.isHidden ?? false) {
            if let index = messagesCollectionView.indexPath(for: cell) {
                guard let urlString = thread.messages[index.section].attachments.first?.url else {return}
                let url = URL(string: urlString)!
                let progressRing = ALProgressRing(frame: CGRect(origin: view.center, size: CGSize(width: 80, height: 80)))
                progressRing.center = view.center
                progressRing.endColor = .blue
                progressRing.startColor = .systemCyan
                progressRing.grooveColor = .green
                DispatchQueue.main.async {
                    self.view.addSubview(progressRing)
                    try! AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
                }
                let task = URLSession.shared.downloadTask(with: url, completionHandler: { [weak self] url, response, error in
                    guard let url = url else { return }
                    guard let documentsURL = try? FileManager.default.url(for: .documentDirectory,in: .userDomainMask,appropriateFor: nil,create: false) else {return}
                    let savedURL = documentsURL.appendingPathComponent("video.mp4")
                    debugPrint("Saved URl: \(savedURL)")
                    do {
                        try FileManager.default.moveItem(at: url, to: savedURL)
                        DispatchQueue.main.async {
                            let player = AVPlayerViewController()
                            let avPlayer = AVPlayer(url: savedURL)
                            avPlayer.volume = 1.0
                            avPlayer.isMuted = false
                            
                            player.player = avPlayer
                            player.player?.play()
                            progressRing.removeFromSuperview()
                            self?.present(player, animated: true, completion: {
                                try? FileManager.default.removeItem(at: savedURL)
                            })
                        }
                    } catch {
                        print(error.localizedDescription)
                    }
                })
                
                observation = task.progress.observe(\.fractionCompleted) { progress, _ in
                    print("progress: ", progress.fractionCompleted)
                    DispatchQueue.main.async {
                        progressRing.setProgress(Float(progress.fractionCompleted ) ,animated: true)
                    }
                }
                
                task.resume()

                
            }
        } else if let image = mediaCell?.imageView.image {
            let newImageView = UIImageView(image: image)
            newImageView.frame = UIScreen.main.bounds
            newImageView.backgroundColor = .black
            newImageView.contentMode = .scaleAspectFit
            newImageView.isUserInteractionEnabled = true
            let tap = UITapGestureRecognizer(target: self, action: #selector(dismissFullscreenImage))
            newImageView.addGestureRecognizer(tap)
            self.view.addSubview(newImageView)
            self.navigationController?.isNavigationBarHidden = true
        }
	}
    
    @objc func dismissFullscreenImage(_ sender: UITapGestureRecognizer) {
        self.navigationController?.isNavigationBarHidden = false
        self.tabBarController?.tabBar.isHidden = false
        sender.view?.removeFromSuperview()
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
        print("Play button tapped")
	}
}
