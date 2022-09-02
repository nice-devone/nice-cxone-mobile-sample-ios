import UIKit
import SwiftUI
import MessageKit
import InputBarAccessoryView
import CXOneChatSDK
import Toast
import UserNotifications

/// A base class for the example controllers
@available(iOS 13.0, *)
public class ChatViewController: MessagesViewController, MessagesDataSource {
    
    var observation: NSKeyValueObservation?
    /// Instance for interacting with the CXone SDK.
    var cxOneChat = CXOneChat.shared

    /// The thread that is currently being viewed.
    var thread: ChatThread

    var closure: (()->Void)?
    
    var textInputWaitTime: Int = 0
    var timer: Timer?

    lazy var editCustomFieldsButton: UIBarButtonItem = {
        var button = UIBarButtonItem(image: UIImage(systemName: "pencil") ,style: .plain, target: self, action: #selector(editCustomField))
        return button
    }()
    lazy var editThreadNameButton: UIBarButtonItem = {
        var button = UIBarButtonItem(image: UIImage.init(systemName: "square.and.pencil"), style: .plain, target: self, action: #selector(editThreadName))
        return button
    }()
    
    public override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    private let refreshControl = UIRefreshControl()
    
    private let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()
	
    public init(thread: ChatThread) {
		self.thread = thread
		super.init(nibName: nil, bundle: nil)
	}

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

	public override func viewDidLoad() {
		super.viewDidLoad()
        self.navigationItem.rightBarButtonItem = editCustomFieldsButton
        if !cxOneChat.channelConfig!.settings.hasMultipleThreadsPerEndUser {
            self.navigationItem.hidesBackButton = true
            let signOutButton = UIBarButtonItem(title: "Sign Out", style: .plain, target: self, action: #selector(self.signOut))
            self.navigationItem.leftBarButtonItem = signOutButton
            title = thread.threadAgent?.fullName ?? ""
        } else {
            self.navigationItem.rightBarButtonItems = [editCustomFieldsButton,editThreadNameButton]
            if let threadName =  thread.threadName {
                title = threadName
            } else {
                title = ""
            }
        }

		configureMessageCollectionView()
		configureMessageInputBar()
        refreshControl.addTarget(self, action: #selector(didPullToRefresh(_:)), for: .valueChanged)
        messagesCollectionView.alwaysBounceVertical = true
        messagesCollectionView.refreshControl = refreshControl
//        collectionView.alwaysBounceVertical = true
		scrollToBottom()
		
        
        closure?()
        
        do {
            self.showActivityIndicator(color: .white)
            try cxOneChat.loadThread(threadIdOnExternalPlatform: thread.idOnExternalPlatform)
        } catch {
            print(error.localizedDescription)
        }
        subscribeToEvents()
	}
	
	public override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
        do {
            try cxOneChat.reportPageView(title: "ChatView", uri: "chat-view")
        } catch {
            print(error.localizedDescription)
        }
	}
	
	public override func viewDidDisappear(_ animated: Bool) {
		super.viewDidDisappear(animated)
	}

    @objc func signOut() {
        CXOneChat.signOut()
        let nc = UINavigationController()
        nc.viewControllers.append(ConfigViewController())
        view.window?.rootViewController = nc
    }
    
    /// Configures the `MessagesCollectionView`
    public func configureMessageCollectionView() {
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messageCellDelegate = self
        scrollsToLastItemOnKeyboardBeginsEditing = true // default false
//        maintainPositionOnKeyboardFrameChanged = true // default false
        showMessageTimestampOnSwipeLeft = true // default false
        //messagesCollectionView.refreshControl = refreshControl
    }
    
    public func configureMessageInputBar() {
        //super.configureMessageInputBar()
        
        messageInputBar = CameraInputBarAccessoryView()
        messageInputBar.delegate = self
        messageInputBar.inputTextView.tintColor = .primaryColor
        messageInputBar.sendButton.setTitleColor(.primaryColor, for: .normal)
        messageInputBar.sendButton.setTitleColor(
            UIColor.primaryColor.withAlphaComponent(0.3),
            for: .highlighted)
        
        
        messageInputBar.isTranslucent = true
        messageInputBar.separatorLine.isHidden = true
        messageInputBar.inputTextView.tintColor = .primaryColor
        messageInputBar.inputTextView.backgroundColor = UIColor(red: 245/255, green: 245/255, blue: 245/255, alpha: 1)
        messageInputBar.inputTextView.placeholderTextColor = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1)
        messageInputBar.inputTextView.textContainerInset = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 36)
        messageInputBar.inputTextView.placeholderLabelInsets = UIEdgeInsets(top: 8, left: 20, bottom: 8, right: 36)
        messageInputBar.inputTextView.layer.borderColor = UIColor(red: 200/255, green: 200/255, blue: 200/255, alpha: 1).cgColor
        messageInputBar.inputTextView.layer.borderWidth = 1.0
        messageInputBar.inputTextView.layer.cornerRadius = 16.0
        messageInputBar.inputTextView.layer.masksToBounds = true
        messageInputBar.inputTextView.scrollIndicatorInsets = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        configureInputBarItems()
    }
    
    @objc private func editCustomField() {
        let popupVC = PopupViewController(contentController: EditCustomFieldsViewController(threadId: self.thread.idOnExternalPlatform), popupWidth: 300, popupHeight: 400)
        present(popupVC, animated: true)
    }
    
    @objc func editThreadName() {
        let alert = UIAlertController(title: "Update Thread Name", message: "Enter a name for this thread.", preferredStyle: .alert)
        alert.addTextField(configurationHandler: { (textField : UITextField!) -> Void in
            textField.placeholder = "Thread name"
        })
        let saveAction = UIAlertAction(title: "Confirm", style: .default, handler: {[weak self] action -> Void in
            guard let title = (alert.textFields![0] as UITextField).text else { return }
            guard let self = self else {return}
            do {
                try self.cxOneChat.updateThreadName(threadName: title, threadIdOnExternalPlatform: self.thread.idOnExternalPlatform)
            } catch {
                print(error.localizedDescription)
            }
        })
        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(saveAction)
        alert.addAction(cancel)
        self.present(alert, animated: true)
    }
	
	/// Scrolls to the bottom of the `MessagesCollectionView`
	private func scrollToBottom() {
		DispatchQueue.main.async {
            let lastSection = self.messagesCollectionView.numberOfSections - 1
            guard lastSection > -1 else {return}
			let lastRow = self.messagesCollectionView.numberOfItems(inSection: lastSection)
			let indexPath = IndexPath(row: lastRow - 1, section: lastSection)
			self.messagesCollectionView.scrollToItem(at: indexPath, at: .bottom, animated: true)
		}
	}
    
	private func configureInputBarItems() {
		messageInputBar.setRightStackViewWidthConstant(to: 36, animated: false)
		messageInputBar.sendButton.imageView?.backgroundColor = UIColor(white: 0.85, alpha: 1)
//		messageInputBar.sendButton.contentEdgeInsets = UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)
		messageInputBar.sendButton.setSize(CGSize(width: 36, height: 36), animated: false)
		messageInputBar.sendButton.image = #imageLiteral(resourceName: "ic_up")
		messageInputBar.sendButton.title = nil
		messageInputBar.sendButton.imageView?.layer.cornerRadius = 16
		let charCountButton = InputBarButtonItem()
			.configure {
				$0.title = "0/140"
				$0.contentHorizontalAlignment = .right
				$0.setTitleColor(UIColor(white: 0.6, alpha: 1), for: .normal)
				$0.titleLabel?.font = UIFont.systemFont(ofSize: 10, weight: .bold)
				$0.setSize(CGSize(width: 50, height: 25), animated: false)
			}.onTextViewDidChange { (item, textView) in
				item.title = "\(textView.text.count)/140"
				let isOverLimit = textView.text.count > 140
				item.inputBarAccessoryView?.shouldManageSendButtonEnabledState = !isOverLimit // Disable automated management when over limit
				if isOverLimit {
					item.inputBarAccessoryView?.sendButton.isEnabled = false
				}
				let color = isOverLimit ? .red : UIColor(white: 0.6, alpha: 1)
				item.setTitleColor(color, for: .normal)
			}
		let bottomItems = [.flexibleSpace, charCountButton]
		
		configureInputBarPadding()
		
		messageInputBar.setStackViewItems(bottomItems, forStack: .bottom, animated: false)
		
		// This just adds some more flare
		messageInputBar.sendButton
			.onEnabled { item in
				UIView.animate(withDuration: 0.3, animations: {
					item.imageView?.backgroundColor = .primaryColor
				})
			}.onDisabled { item in
				UIView.animate(withDuration: 0.3, animations: {
					item.imageView?.backgroundColor = UIColor(white: 0.85, alpha: 1)
				})
			}
	}
	
	/// The input bar will autosize based on the contained text, but we can add padding to adjust the height or width if necessary
	/// See the InputBar diagram here to visualize how each of these would take effect:
	/// https://raw.githubusercontent.com/MessageKit/MessageKit/master/Assets/InputBarAccessoryViewLayout.png
	private func configureInputBarPadding() {
		
		// Entire InputBar padding
		messageInputBar.padding.bottom = 8
		
		// or MiddleContentView padding
		messageInputBar.middleContentViewPadding.right = -38
		
		// or InputTextView padding
		messageInputBar.inputTextView.textContainerInset.bottom = 8
		
	}
	
	/// Calls the `CXOneChat` and tells it the the user started typing
	///  - NOTE: This should be placed somewhere else
	@objc
	public func textEditingDidBegin() {
        do {
            try self.cxOneChat.reportTypingStart(threadIdOnExternalPlatform: self.thread.idOnExternalPlatform)
        } catch {
            print(error)
        }
        
	}
	
	/// Calls the `CXOneChat` and tells it the the user ended typing
	///  - NOTE: This should be placed somewhere else
	@objc
	public func textEditingDidEnd() {
        do {
            try self.cxOneChat.reportTypingEnd(threadIdOnExternalPlatform: self.thread.idOnExternalPlatform)
        } catch {
            print(error)
        }
	}
    
    @objc private func didPullToRefresh(_ sender: Any) {
        if thread.hasMoreMessagesToLoad {
            do {
                try cxOneChat.loadMoreMessages(threadIdOnExternalPlatform: self.thread.idOnExternalPlatform)
            } catch {
                print(error.localizedDescription)
            }
        } else {
            self.refreshControl.endRefreshing()
        }
    }

    public func loadedMoreMessage() {
        DispatchQueue.main.async {
            self.refreshControl.endRefreshing()
            self.messagesCollectionView.reloadData()
        }
    }

	
	public func inputBar(_ inputBar: InputBarAccessoryView, textViewTextDidChangeTo text: String) {
		if timer != nil {
			if self.textInputWaitTime >= 5 {
				self.timer?.invalidate()
				self.textInputWaitTime = 0
				self.timer = nil
			}
		} else {
			textEditingDidBegin()
			self.timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
				self.textInputWaitTime += 1

				if self.textInputWaitTime >= 5 {
					self.textInputWaitTime = 0
					timer.invalidate()
					self.timer = nil
					self.textEditingDidEnd()
				}
			}
		}
	}
	
	@objc func delaySearch(with: String) {	}
        
    private func subscribeToEvents() {
        cxOneChat.onCustomPluginMessage = { [weak self] pluginMessage in
            self?.parsePluginMessage(pluginMessage)
        }

        cxOneChat.onAgentChange = { [weak self] agent, _ in
            guard let self = self else {return}
            self.thread.threadAgent = agent
            if !(CXOneChat.shared.channelConfig?.settings.hasMultipleThreadsPerEndUser ?? true) {
                DispatchQueue.main.async {
                    self.navigationItem.title = agent.fullName
                }
            }
        }

        cxOneChat.onAgentTypingStart = { [weak self] threadId in
            guard let self = self else { return }
            if threadId == self.thread.idOnExternalPlatform {
                if self.timer == nil {
                    DispatchQueue.main.async {
                        self.setTypingIndicatorViewHidden(false, animated: true, whilePerforming: {
                            self.scrollToBottom()
                        }, completion: nil)
                    }
                }

            }
        }

        cxOneChat.onAgentTypingEnd = { [weak self] threadId in
            guard let self = self else { return }
            if threadId == self.thread.idOnExternalPlatform {
                if self.timer == nil {
                    DispatchQueue.main.async {
                        self.setTypingIndicatorViewHidden(true, animated: true)
                    }
                }

            }
        }
        
        cxOneChat.onThreadLoad = { [weak self] _ in
            DispatchQueue.main.async {
                self?.updateThreadData()
                self?.hideActivityIndicator()
                self?.scrollToBottom()
            }
        }
        
        cxOneChat.onNewMessage = { [weak self] message in
            if message.threadIdOnExternalPlatform == self?.thread.idOnExternalPlatform {
                DispatchQueue.main.async {
                    self?.updateThreadData()
                    (self?.inputAccessoryView as? InputBarAccessoryView)?.sendButton.stopAnimating()
                    (self?.inputAccessoryView as? InputBarAccessoryView)?.inputTextView.placeholder = "Aa"
                    self?.scrollToBottom()
                }
            } else {
                self?.onMessageReceivedFromOtherThread(message: message)
            }
        }
        cxOneChat.onLoadMoreMessages = { [weak self] _ in
            DispatchQueue.main.async {
                guard let self = self else {return}
                self.refreshControl.endRefreshing()
                self.updateThreadData()
            }
        }
        cxOneChat.onError = {[weak self] error in
            DispatchQueue.main.async {
//                print(error)
                self?.hideActivityIndicator()
            }
        }
        cxOneChat.onAgentReadMessage = { [weak self] _ in
            DispatchQueue.main.async {
                self?.updateThreadData()
            }
        }
        cxOneChat.onThreadUpdate = { [weak self] in
            guard let self = self else {return }
            DispatchQueue.main.async {
                guard let index = self.cxOneChat.threads.firstIndex(where: {
                    $0.idOnExternalPlatform == self.thread.idOnExternalPlatform
                }) else { return }
                self.thread = self.cxOneChat.threads[index]
                self.title = self.thread.threadName
            }
        }
    }
    
	/// Inserts a message into the `MessagesCollectionView`
	///
	/// - Parameters:
	///   - message: The `Message` object to add into the `MessagesCollectionView`
	public func insertMessage(_ message: Message) {
        if let convoIndex = self.cxOneChat.threads.firstIndex(where: {$0.idOnExternalPlatform == message.threadIdOnExternalPlatform}) {
			// Reload last section to update header/footer labels and insert a new one
            if self.thread.idOnExternalPlatform == message.threadIdOnExternalPlatform {
                DispatchQueue.main.async {
                    self.messagesCollectionView.performBatchUpdates({
                        self.messagesCollectionView.insertSections([self.cxOneChat.threads[convoIndex].messages.count - 1])
                        if self.cxOneChat.threads[convoIndex].messages.count >= 2 {
                            self.messagesCollectionView.reloadSections([self.cxOneChat.threads[convoIndex].messages.count - 2])
                        }
                    }, completion: { [weak self] _ in
                        if self?.isLastSectionVisible() == true {
                            self?.messagesCollectionView.scrollToLastItem(animated: true)
                        }
                    })
                }
			}
		}
		
	}
    
    public func onMessageReceivedFromOtherThread(message: Message) {
        var messageText = ""        
        if case let .text(text) = message.kind {
            messageText = text
        }
        self.view.makeToast(messageText, duration: 2.0, position: .top, title: "New message from \(message.senderInfo.fullName)", image: nil, style: ToastStyle(), completion: nil)
    }
	
	/// Auto scrolls if message is received while user is on the bottom of the view.
	public func isLastSectionVisible() -> Bool {
		guard let convoIndex = cxOneChat.threads.firstIndex(where: {$0.idOnExternalPlatform == self.thread.idOnExternalPlatform}) else { return false }
		let lastIndexPath = IndexPath(item: 0, section: cxOneChat.threads[convoIndex].messages.count - 1)
		return messagesCollectionView.indexPathsForVisibleItems.contains(lastIndexPath)
	}
	
	/// Determines the current sender.
	public func currentSender() -> SenderType {
        let customer = CXOneChat.shared.customer ?? Customer(id: "", firstName: "", lastName: "")
        return customer
	}
	
	/// Determines the `numberOfSections` based on the messages in a thread.
	///
	/// - Parameters:
	///   - messagesCollectionView: The current `CollectionView`
	public func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
		return thread.messages.count
	}
	
	/// Determines the information in the cell.
	public func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
		let message = thread.messages[indexPath.section]
		return message
	}
	
	
	// MARK: - Labels
	public func cellTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
		if indexPath.section % 3 == 0 {
			return NSAttributedString(string: MessageKitDateFormatter.shared.string(from: message.sentDate), attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 10), NSAttributedString.Key.foregroundColor: UIColor.darkGray])
		}
		return nil
	}
	
	public func messageTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
		let name = message.sender.displayName
		return NSAttributedString(string: name, attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .caption1)])
	}
	
	public func messageBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
		let dateString = formatter.string(from: message.sentDate)
		return NSAttributedString(string: dateString, attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .caption2)])
	}
	
	public func textCell(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UICollectionViewCell? {
		return nil
	}
    
    /// Find the updated thread in the SDK and updates the thread for the view.
    private func updateThreadData() {
        guard let updatedThread = self.cxOneChat.threads.first(where: {
            $0.idOnExternalPlatform == self.thread.idOnExternalPlatform
        }) else {
            print("Unable to find updated thread for \(self.thread.idOnExternalPlatform)")
            return
        }
        var messages = [Message]()
        for message in updatedThread.messages {
            if message.attachments.isEmpty {
                messages.append(message)
            } else {
                if !message.messageContent.payload.text.isEmpty {
                    messages.append(message)
                    let newImageMessage = Message(idOnExternalPlatform: UUID(), threadIdOnExternalPlatform: message.threadIdOnExternalPlatform, messageContent: message.messageContent, createdAt: message.createdAt, attachments: [], direction: message.direction, userStatistics: message.userStatistics, authorUser: message.authorUser, authorEndUserIdentity: message.authorEndUserIdentity)
                    messages.append(newImageMessage)
                } else {
                    for attachment in message.attachments {
                        let newMessage = Message(idOnExternalPlatform: UUID(), threadIdOnExternalPlatform: message.threadIdOnExternalPlatform, messageContent: message.messageContent, createdAt: message.createdAt, attachments: [attachment], direction: message.direction, userStatistics: message.userStatistics, authorUser: message.authorUser, authorEndUserIdentity: message.authorEndUserIdentity)
                        messages.append(newMessage)
                    }
                }
            }
        }
        self.thread = updatedThread
        self.thread.messages = messages
        self.messagesCollectionView.reloadData()
    }
}

extension ChatViewController: CameraInputBarAccessoryViewDelegate {
	func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith attachments: [AttachmentManager.Attachment]) {
		let finalAttachments = attachments.map { attachment -> UIImage in
			switch attachment {
			case .image(let image):
				return image
			default:
				return UIImage()
			}
		}
		let attributedText = inputBar.inputTextView.attributedText!.string
		self.sendImageMessage(message: attributedText, photos: finalAttachments, completion: {
			didSend in
			if didSend {
				DispatchQueue.main.async {
					inputBar.invalidatePlugins()
					inputBar.inputTextView.text = String()
					inputBar.inputTextView.resignFirstResponder()
					inputBar.invalidatePlugins()
					inputBar.sendButton.startAnimating()
					inputBar.inputTextView.placeholder = "Sending..."
					DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
						inputBar.sendButton.stopAnimating()
						inputBar.inputTextView.placeholder = "Aa"
					}
				}
			}
		})
	}
	
	@objc public func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
		inputBar.inputTextView.text = String()
		inputBar.inputTextView.resignFirstResponder()
		inputBar.invalidatePlugins()
		inputBar.sendButton.startAnimating()
		inputBar.inputTextView.placeholder = "Sending..."
        inputBar.sendButton.stopAnimating()
        do {
            try self.cxOneChat.sendMessage(message: text, threadIdOnExternalPlatform: self.thread.idOnExternalPlatform)
        }catch {
            print(error.localizedDescription)
        }
	}
	
	func sendImageMessage(message: String, photos : [UIImage], completion: @escaping(_ didSend: Bool) -> ())  {
        var attachments: [AttachmentUpload] = []
        for photo in photos {
            let data = photo.jpegData(compressionQuality: 0.7) ?? Data()
            let mime = data.mimeType
            let attachUpload: AttachmentUpload = AttachmentUpload(attachmentData: data, mimeType: mime, fileName: UUID().uuidString + ".\(data.fileExtension)")
            attachments.append(attachUpload)
        }
        Task {
            try await self.cxOneChat.sendMessageWithAttachments(message: message, at: thread.idOnExternalPlatform, with: attachments)
            completion(true)
        }
	}
}
extension Data {
    private static let mimeTypeSignatures: [UInt8 : String] = [
        0xFF : "image/jpeg",
        0x89 : "image/png",
        0x47 : "image/gif",
        0x49 : "image/tiff",
        0x4D : "image/tiff",
        0x25 : "application/pdf",
        0xD0 : "application/vnd",
        0x46 : "text/plain",
        ]

    var mimeType: String {
        var c: UInt8 = 0
        copyBytes(to: &c, count: 1)
        return Data.mimeTypeSignatures[c] ?? "application/octet-stream"
    }
    var fileExtension: String {
            switch mimeType {
            case "image/jpeg":
                return "jpeg"
            case "image/png":
                return "png"
            case "image/gif":
                return "gif"
            case "image/tiff":
                return "tiff"
            case "application/pdf":
                return "pdf"
            case "application/vnd":
                return "vnd"
            case "text/plain":
                return "txt"
            default:
                return "uknown"
            }
        }
}
