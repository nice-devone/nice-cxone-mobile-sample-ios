//
//  Created by Customer Dynamics Development on 9/2/21.
//

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
	
	// MARK: - Public properties
	/// The `BasicAudioController` control the AVAudioPlayer state (play, pause, stop) and update audio cell UI accordingly.
	lazy var audioController = BasicAudioController(messageCollectionView: messagesCollectionView)
//	var threadIndex: Int
	//var slackInputBar = SlackInputBar()
	var thread: ThreadObject
	var sdkClient = CXOneChat.shared
    private let refreshControl = UIRefreshControl()
	
	public init(thread: ThreadObject) {
		
		self.thread = thread
        print("threadID:",thread.id)
		super.init(nibName: nil, bundle: nil)
	}
    var closure: (()->Void)?
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	
	lazy var editCustomFieldsButton: UIBarButtonItem = {
        var button = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editCustomField))
		return button
	}()
	
	// MARK: - Private properties
	private let formatter: DateFormatter = {
		let formatter = DateFormatter()
		formatter.dateStyle = .medium
		return formatter
	}()
	
	@objc func editCustomField() {
		let popupVC = PopupViewController(contentController: EditCustomFieldsViewController(thread: self.thread.id), popupWidth: 300, popupHeight: 400)

		present(popupVC, animated: true)
	}
	
	// MARK: - Lifecycle
	public override func viewDidLoad() {
		super.viewDidLoad()
		
		title = thread.threadAgent.displayName
		
		configureMessageCollectionView()
		configureMessageInputBar()
		scrollToBottom()
        navigationItem.rightBarButtonItem = editCustomFieldsButton
        refreshControl.addTarget(self, action: #selector(didPullToRefresh(_:)), for: .valueChanged)
        messagesCollectionView.alwaysBounceVertical = true
        messagesCollectionView.refreshControl = refreshControl
//        collectionView.alwaysBounceVertical = true
//        collectionView.refreshControl = refreshControl
		self.scrollToBottom()
		self.navigationItem.rightBarButtonItem = editCustomFieldsButton
		//loadFirstMessages()
        closure?()
        if thread.messages.count < 2 {
            do {
                self.showActivityIndicator(color: .green)
                try sdkClient.loadThread(threadId: thread.idOnExternalPlatform)
            }catch {
                print(error.localizedDescription)
            }
        }
        subscribeToEvents()    
	}
	
	public override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
	}
	
	public override func viewDidDisappear(_ animated: Bool) {
		super.viewDidDisappear(animated)
		audioController.stopAnyOngoingPlaying()
	}
	
	public override var preferredStatusBarStyle: UIStatusBarStyle {
		return .lightContent
	}
	
	/// Configures the `MessagesCollectionView`
	public func configureMessageCollectionView() {
		messagesCollectionView.messagesDataSource = self
		messagesCollectionView.messageCellDelegate = self
		scrollsToLastItemOnKeyboardBeginsEditing = true // default false
//		maintainPositionOnKeyboardFrameChanged = true // default false
		showMessageTimestampOnSwipeLeft = true // default false
		//messagesCollectionView.refreshControl = refreshControl
	}
	
	/// Scrolls to the bottom of the `MessagesCollectionView`
	public func scrollToBottom() {
		DispatchQueue.main.async {
            let lastSection = self.messagesCollectionView.numberOfSections - 1
            guard lastSection > -1 else {return}
			let lastRow = self.messagesCollectionView.numberOfItems(inSection: lastSection)
			let indexPath = IndexPath(row: lastRow - 1, section: lastSection)
			self.messagesCollectionView.scrollToItem(at: indexPath, at: .bottom, animated: true)
		}
	}
	
	// MARK: -  InputView
	func configureMessageInputBar() {
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
		self.sdkClient.reportTypingStart()
	}
	
	/// Calls the `CXOneChat` and tells it the the user ended typing
	///  - NOTE: This should be placed somewhere else
	@objc
	public func textEditingDidEnd() {
		self.sdkClient.reportTypingEnd()
	}
	
	var textInputWaitTime: Int = 0
	var timer: Timer?
	
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
    
    // MARK: - IOSSDKController -
    
    func subscribeToEvents() {
        sdkClient.onData = { [weak self] data in
            self?.parsePluginData(data)
        }
        sdkClient.onAgentChange = { [weak self] in
            guard let self = self else {return}
            DispatchQueue.main.async {
                self.navigationItem.title = self.thread.threadAgent.displayName
            }
        }
        sdkClient.onMessageAddedToChatView = { [weak self] message in
           // self?.insertMessage(message)
            DispatchQueue.main.async {
                self?.hideActivityIndicator()
                guard let nThread = self?.sdkClient.threads.first(where: {
                    $0.id == self?.thread.id
                }) else {return}
                self?.thread = nThread
                self?.messagesCollectionView.reloadData()
                (self?.inputAccessoryView as? InputBarAccessoryView)?.sendButton.stopAnimating()
                (self?.inputAccessoryView as? InputBarAccessoryView)?.inputTextView.placeholder = "Aa"
                self?.scrollToBottom()
            }
        }
        sdkClient.onAgentTypingStart = { [weak self] in
            guard let self = self else {return}
            if self.timer == nil {
                DispatchQueue.main.async {
                    self.setTypingIndicatorViewHidden(false, animated: true, whilePerforming: {
                        self.scrollToBottom()
                    }, completion: nil)
                }
            }
        }
        sdkClient.onAgentTypingEnd = { [weak self] in
            guard let self = self else {return}
            if self.timer == nil {
                DispatchQueue.main.async {
                    self.setTypingIndicatorViewHidden(true, animated: true, whilePerforming: {
                        self.scrollToBottom()
                    }, completion: nil)
                }
            }
        }
        
        sdkClient.onMessageAddedToThread = { [weak self] message in
            DispatchQueue.main.async {
                self?.hideActivityIndicator()
                guard let nThread = self?.sdkClient.threads.first(where: {
                    $0.id == self?.thread.id
                }) else {return}
                self?.thread = nThread
                self?.messagesCollectionView.reloadData()
                self?.scrollToBottom()
            }
        }
        
        sdkClient.onMessageAddedToOtherThread = { [weak self] message in
            self?.onMessageReceivedFromOtherThread(message: message)
        }
        sdkClient.onLoadMoreMessages = { [weak self] in
            DispatchQueue.main.async {
                guard let self = self else {return}
                self.refreshControl.endRefreshing()
                guard let nThread = self.sdkClient.threads.first(where: {
                    $0.id == self.thread.id
                }) else {return}
                self.thread = nThread
                self.messagesCollectionView.reloadData()
            }
        }
        sdkClient.onError = { _ in
            DispatchQueue.main.async {
                self.hideActivityIndicator()
            }
        }
    }
    
    
    
	
	/// Inserts a message into the `MessagesCollectionView`
	///
	/// - Parameters:
	///   - message: The `Message` object to add into the `MessagesCollectionView`
	public func insertMessage(_ message: Message) {
        if let convoIndex = self.sdkClient.threads.firstIndex(where: {$0.idOnExternalPlatform == message.threadId}) {
			// Reload last section to update header/footer labels and insert a new one
            if self.thread.idOnExternalPlatform == message.threadId {
                DispatchQueue.main.async {
                    self.messagesCollectionView.performBatchUpdates({
                        self.messagesCollectionView.insertSections([self.sdkClient.threads[convoIndex].messages.count - 1])
                        if self.sdkClient.threads[convoIndex].messages.count >= 2 {
                            self.messagesCollectionView.reloadSections([self.sdkClient.threads[convoIndex].messages.count - 2])
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
        print("message:", message)
        var messageText = ""
//        if case let .audio(audioItem) = message.kind {
//            durationLabel.text = displayDelegate.audioProgressTextFormat(audioItem.duration, for: self, in: messagesCollectionView)
//        }
        
        if case let .text(text) = message.kind {
            messageText = text
        }
        self.view.makeToast(messageText, duration: 2.0, position: .top, title: "message from: \(message.user.displayName)", image: nil, style: ToastStyle(), completion: nil)
//        let notificationContent = UNMutableNotificationContent()
//        notificationContent.title = "Message from: \(message.user.displayName)"
//        notificationContent.body = messageText
//        
//        
//        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.3,
//                                                        repeats: false)
//        let request = UNNotificationRequest(identifier: "testNotification",
//                                            content: notificationContent,
//                                            trigger: trigger)
//        
//        UNUserNotificationCenter.current().add(request) { (error) in
//            if let error = error {
//                print("Notification Error: ", error)
//            }
//        }
    }
	
	/// Auto scrolls if message is received while user is on the bottom of the view.
	public func isLastSectionVisible() -> Bool {
		guard let convoIndex = sdkClient.threads.firstIndex(where: {$0.id == self.thread.id}) else { return false }
		let lastIndexPath = IndexPath(item: 0, section: sdkClient.threads[convoIndex].messages.count - 1)
		return messagesCollectionView.indexPathsForVisibleItems.contains(lastIndexPath)
	}
	
	/// Determines the current sender.
	public func currentSender() -> SenderType {
        let currentSender: Customer = CXOneChat.shared.customer ?? Customer(senderId: "", displayName: "")
        return currentSender
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
		guard sdkClient.threads.firstIndex(where: {$0.idOnExternalPlatform == self.thread.idOnExternalPlatform}) != nil else {
            return Message(messageType: .text, plugin: [], text: "", user: Customer(senderId: "", displayName: ""), messageId: UUID(), date: Date(), threadId: self.thread.idOnExternalPlatform, isRead: false)
		}
		var message = thread.messages[indexPath.section]
		if message.messageType == .plugin {
			message.kind = .custom(nil)
		}
		return message
	}
	
	
	// MARK: - Labels
	public func cellTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
		if indexPath.section % 3 == 0 {
			return NSAttributedString(string: MessageKitDateFormatter.shared.string(from: message.sentDate), attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 10), NSAttributedString.Key.foregroundColor: UIColor.darkGray])
		}
		return nil
	}
	
	public func cellBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        let index = sdkClient.threads.firstIndex(where: {$0.idOnExternalPlatform == self.thread.idOnExternalPlatform})
        
        let currentMessage = sdkClient.threads[index ?? 0].messages[indexPath.row]
        return NSAttributedString(string: currentMessage.isRead ? "✓✓" : "✓",
                                  attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 10),
                                               NSAttributedString.Key.foregroundColor: currentMessage.isRead ? UIColor.blue : UIColor.darkGray])
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
    public func didReceiveMetaData() { }
}

public enum pluginTypes {
	case menu
}


extension UIColor {
	static let primaryColor = UIColor(red: 69/255, green: 193/255, blue: 89/255, alpha: 1)
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
            try self.sdkClient.sendMessage(message: text)
        }catch {
            print(error.localizedDescription)
        }
        
//		DispatchQueue.global(qos: .default).async {
//			sleep(1)
//			DispatchQueue.main.async { [weak self] in
//                guard let self = self else {return}
//
//                self.sdkClient.sendMessage(message: text)//sendMessage(message: text, thread: self.thread.idOnExternalPlatform)
//			}
//		}
	}
	
	func sendImageMessage(message: String, photos : [UIImage], completion: @escaping(_ didSend: Bool) -> ())  {
        self.sdkClient.sendAttachments(with: photos)
        
//        send(message: message, with: photos, in: thread.idOnExternalPlatform) //sendMessageWithAttachments(message: message, images: photos, thread: self.thread.idOnExternalPlatform)
		completion(true)
	}
}

extension ChatViewController {
    public func loadedMoreMessage() {
        DispatchQueue.main.async {
            self.refreshControl.endRefreshing()
            self.messagesCollectionView.reloadData()
        }
    }
}

extension MessagesDataSource {
    public func isFromCurrentSender(message: MessageType) -> Bool {
       return message.sender.senderId.lowercased() == currentSender().senderId.lowercased()
    }
}

extension ChatViewController {
    @objc private func didPullToRefresh(_ sender: Any) {
        if sdkClient.hasMoreMessagesInThread {
            do {
                try sdkClient.loadMoreMessages()
            }catch {
                print(error.localizedDescription)
            }
        }else {
            self.refreshControl.endRefreshing()
        }
    }
}
