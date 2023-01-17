import ALProgressView
import AVKit
import MessageKit


extension ThreadDetailViewController: MessageCellDelegate {
    
    public func didTapAvatar(in cell: MessageCollectionViewCell) {
        Log.info("Avatar tapped")
    }
    
    public func didTapMessage(in cell: MessageCollectionViewCell) {
        Log.info("Message tapped")
        
        guard let indexPath = messagesCollectionView.indexPath(for: cell) else {
            Log.error(CommonError.unableToParse("indexPath", from: messagesCollectionView))
            return
        }
        guard let message = presenter.documentState.thread.messages[safe: indexPath.section] else {
            Log.error(CommonError.unableToParse("message", from: messagesCollectionView))
            return
        }
        
        if let attachment = message.attachments.first, let url = URL(string: attachment.url) {
            present(WkWebViewController(url: url), animated: true)
        } else if case .plugin = message.contentType {
            UIAlertController.show(.alert, title: "Alert", message: "Plugin has been tapped")
        } else {
            Log.warning(.failed("Did tap on unsupported message type."))
        }
    }
    
    public func didTapImage(in cell: MessageCollectionViewCell) {
        Log.info("image tapped")
        
        guard let mediaCell = cell as? MediaMessageCell else {
            Log.error(CommonError.unableToParse("mediaCell", from: cell))
            return
        }
        
        if !mediaCell.playButtonView.isHidden {
            guard let index = messagesCollectionView.indexPath(for: cell) else {
                Log.error(CommonError.unableToParse("index", from: messagesCollectionView))
                return
            }
            guard let message = presenter.documentState.thread.messages[safe: index.section],
                  let urlString = message.attachments.first?.url,
                  let url = URL(string: urlString)
            else {
                Log.error(CommonError.unableToParse("url", from: presenter.documentState.thread.messages[index.section].attachments))
                return
            }
            
            DispatchQueue.main.async {
                self.myView.progressRing.isHidden = false
                try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            }
            
            let task = handleAttachmentTask(with: url)
            
            observation = task.progress.observe(\.fractionCompleted) { progress, _ in
                print("progress: ", progress.fractionCompleted)
                
                DispatchQueue.main.async {
                    self.myView.progressRing.setProgress(Float(progress.fractionCompleted), animated: true)
                }
            }
            
            task.resume()
        } else if let image = mediaCell.imageView.image {
            let newImageView = UIImageView(image: image)
            newImageView.frame = UIScreen.main.bounds
            newImageView.backgroundColor = .black
            newImageView.contentMode = .scaleAspectFit
            newImageView.isUserInteractionEnabled = true
            
            let tap = UITapGestureRecognizer(target: self, action: #selector(dismissFullscreenImage))
            newImageView.addGestureRecognizer(tap)
            
            view.addSubview(newImageView)
            
            messageInputBar.isHidden = true
            navigationController?.isNavigationBarHidden = true
        }
    }
    
    public func didTapCellTopLabel(in cell: MessageCollectionViewCell) {
        Log.info("Top cell label tapped")
    }
    
    public func didTapCellBottomLabel(in cell: MessageCollectionViewCell) {
        Log.info("Bottom cell label tapped")
    }
    
    public func didTapMessageTopLabel(in cell: MessageCollectionViewCell) {
        Log.info("Top message label tapped")
    }
    
    public func didTapMessageBottomLabel(in cell: MessageCollectionViewCell) {
        Log.info("Bottom label tapped")
    }
    
    public func didStartAudio(in cell: AudioMessageCell) {
        Log.info("Did start playing audio sound")
    }
    
    public func didPauseAudio(in cell: AudioMessageCell) {
        Log.info("Did pause audio sound")
    }
    
    public func didStopAudio(in cell: AudioMessageCell) {
        Log.info("Did stop audio sound")
    }
    
    public func didTapAccessoryView(in cell: MessageCollectionViewCell) {
        Log.info("Accessory view tapped")
    }
    
    /// Play audio from an `AudioMessageCell`
    /// - Parameter cell: The current `AudioMessageCell`
    public func didTapPlayButton(in cell: AudioMessageCell) {
        Log.info("Play button tapped")
    }
}


// MARK: - Actions

private extension ThreadDetailViewController {
    
    @objc
    func dismissFullscreenImage(_ sender: UITapGestureRecognizer) {
        navigationController?.isNavigationBarHidden = false
        messageInputBar.isHidden = false
        
        sender.view?.removeFromSuperview()
    }
}


// MARK: - Private methods

private extension ThreadDetailViewController {

    func handleAttachmentTask(with url: URL) -> URLSessionDownloadTask {
        URLSession.shared.downloadTask(with: url) { [weak self] url, _, _ in
            let documentURL = try? FileManager.default
                .url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            
            guard let url = url, let savedURL = documentURL?.appendingPathComponent("video.mp4") else {
                Log.error(CommonError.unableToParse("savedURL", from: documentURL))
                return
            }
            
            do {
                try FileManager.default.moveItem(at: url, to: savedURL)
                
                DispatchQueue.main.async {
                    let player = AVPlayerViewController()
                    let avPlayer = AVPlayer(url: savedURL)
                    avPlayer.volume = 1.0
                    avPlayer.isMuted = false
                    
                    player.player = avPlayer
                    player.player?.play()
                    self?.myView.progressRing.removeFromSuperview()
                    
                    self?.present(player, animated: true) {
                        try? FileManager.default.removeItem(at: savedURL)
                    }
                }
            } catch {
                error.logError()
            }
        }
    }
}
