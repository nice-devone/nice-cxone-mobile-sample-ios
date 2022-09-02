import Foundation
import UIKit
import MapKit
import MessageKit
import InputBarAccessoryView
import Kingfisher

final class AdvancedExampleViewController: ChatViewController {
		
	let outgoingAvatarOverlap: CGFloat = 17.5
	
	override func viewDidLoad() {
		messagesCollectionView = MessagesCollectionView(frame: .zero, collectionViewLayout: CustomMessagesFlowLayout())
		messagesCollectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
		super.viewDidLoad()
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
	}
	
	override func configureMessageCollectionView() {
		super.configureMessageCollectionView()
		
		let layout = messagesCollectionView.collectionViewLayout as? MessagesCollectionViewFlowLayout
		layout?.sectionInset = UIEdgeInsets(top: 1, left: 8, bottom: 1, right: 8)
		
		// Hide the outgoing avatar and adjust the label alignment to line up with the messages
		layout?.setMessageOutgoingAvatarSize(.zero)
		layout?.setMessageOutgoingMessageTopLabelAlignment(LabelAlignment(textAlignment: .right, textInsets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 8)))
		layout?.setMessageOutgoingMessageBottomLabelAlignment(LabelAlignment(textAlignment: .right, textInsets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 8)))

		// Set outgoing avatar to overlap with the message bubble
		layout?.setMessageIncomingMessageTopLabelAlignment(LabelAlignment(textAlignment: .left, textInsets: UIEdgeInsets(top: 0, left: 18, bottom: outgoingAvatarOverlap, right: 0)))
		layout?.setMessageIncomingAvatarSize(CGSize(width: 30, height: 30))
		layout?.setMessageIncomingMessagePadding(UIEdgeInsets(top: -outgoingAvatarOverlap, left: -18, bottom: outgoingAvatarOverlap, right: 18))
		
		layout?.setMessageIncomingAccessoryViewSize(CGSize(width: 30, height: 30))
		layout?.setMessageIncomingAccessoryViewPadding(HorizontalEdgeInsets(left: 8, right: 0))
		layout?.setMessageIncomingAccessoryViewPosition(.messageBottom)
		layout?.setMessageOutgoingAccessoryViewSize(CGSize(width: 30, height: 30))
		layout?.setMessageOutgoingAccessoryViewPadding(HorizontalEdgeInsets(left: 0, right: 8))

		messagesCollectionView.messagesLayoutDelegate = self
		messagesCollectionView.messagesDisplayDelegate = self
	}
	
	override func configureMessageInputBar() {
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
		//messageInputBar.sendButton.contentEdgeInsets = UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)
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
	
	// MARK: - Helpers
	
	func isTimeLabelVisible(at indexPath: IndexPath) -> Bool {
		return indexPath.section % 3 == 0 && !isPreviousMessageSameSender(at: indexPath)
	}
	
	func isPreviousMessageSameSender(at indexPath: IndexPath) -> Bool {
		guard indexPath.section - 1 >= 0 else { return false }
        return thread.messages[indexPath.section].sender.senderId.lowercased() == thread.messages[indexPath.section - 1].sender.senderId.lowercased()
	}
	
	func isNextMessageSameSender(at indexPath: IndexPath) -> Bool {
		guard indexPath.section + 1 < thread.messages.count else { return false }
        return thread.messages[indexPath.section].sender.senderId.lowercased() == thread.messages[indexPath.section + 1].sender.senderId.lowercased()
	}
	
	func setTypingIndicatorViewHidden(_ isHidden: Bool, performUpdates updates: (() -> Void)? = nil) {
		setTypingIndicatorViewHidden(isHidden, animated: true, whilePerforming: updates) { [weak self] success in
			if success, self?.isLastSectionVisible() == true {
				self?.messagesCollectionView.scrollToLastItem(animated: true)
			}
		}
	}
	
	private func makeButton(named: String) -> InputBarButtonItem {
		return InputBarButtonItem()
			.configure {
				$0.spacing = .fixed(10)
				$0.image = UIImage(named: named)?.withRenderingMode(.alwaysTemplate)
				$0.setSize(CGSize(width: 25, height: 25), animated: false)
				$0.tintColor = UIColor(white: 0.8, alpha: 1)
			}.onSelected {
				$0.tintColor = .primaryColor
			}.onDeselected {
				$0.tintColor = UIColor(white: 0.8, alpha: 1)
			}.onTouchUpInside {
				let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
				let action = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
				actionSheet.addAction(action)
				if let popoverPresentationController = actionSheet.popoverPresentationController {
					popoverPresentationController.sourceView = $0
					popoverPresentationController.sourceRect = $0.frame
				}
				self.navigationController?.present(actionSheet, animated: true, completion: nil)
		}
	}
	
	// MARK: - UICollectionViewDataSource
	private lazy var textMessageSizeCalculator: CustomTextLayoutSizeCalculator = CustomTextLayoutSizeCalculator(layout: self.messagesCollectionView.messagesCollectionViewFlowLayout)
	
	public override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		
		guard let messagesDataSource = messagesCollectionView.messagesDataSource else {
			fatalError("Ouch. nil data source for messages")
		}

		// Very important to check this when overriding `cellForItemAt`
		// Super method will handle returning the typing indicator cell
		guard !isSectionReservedForTypingIndicator(indexPath.section) else {
			return super.collectionView(collectionView, cellForItemAt: indexPath)
		}

		let message = messagesDataSource.messageForItem(at: indexPath, in: messagesCollectionView)
		let messageData = thread.messages[indexPath.section]
		if case .custom = message.kind {
			let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
			let pluginMessageView = PluginMessageView()
			cell.contentView.addSubview(pluginMessageView)
            pluginMessageView.translatesAutoresizingMaskIntoConstraints = false
            pluginMessageView.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 5).isActive = true
            pluginMessageView.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -5).isActive = true
            pluginMessageView.topAnchor.constraint(equalTo: cell.contentView.topAnchor, constant: 5).isActive = true
            pluginMessageView.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor, constant: -5).isActive = true
            pluginMessageView.configure(elements: messageData.messageContent.payload.elements)
            pluginMessageView.width(constant: 200)
			cell.layoutIfNeeded()
			return cell
		}
		return super.collectionView(collectionView, cellForItemAt: indexPath)
	}

	// MARK: - MessagesDataSource

	override func cellTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
		if isTimeLabelVisible(at: indexPath) {
			return NSAttributedString(string: MessageKitDateFormatter.shared.string(from: message.sentDate), attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 10), NSAttributedString.Key.foregroundColor: UIColor.darkGray])
		}
		return nil
	}
	
	override func messageTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
		if !isPreviousMessageSameSender(at: indexPath) {
			let name = message.sender.displayName
			return NSAttributedString(string: name, attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .caption1)])
		}
		return nil
	}

	override func messageBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
//        let index = cxOneChat.threads.firstIndex(where: {$0.idOnExternalPlatform == self.thread.idOnExternalPlatform})
        let currentMessage = thread.messages[indexPath.section]
        
        return NSAttributedString(string: (currentMessage.userStatistics.readAt != nil) ? "Read" : "Delivered",
                                  attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 10),
                                               NSAttributedString.Key.foregroundColor: UIColor.darkGray])
	}
}

// MARK: - MessagesDisplayDelegate

extension AdvancedExampleViewController: MessagesDisplayDelegate {

	// MARK: - Text Messages

	func textColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
		return isFromCurrentSender(message: message) ? .white : .darkText
	}

	func detectorAttributes(for detector: DetectorType, and message: MessageType, at indexPath: IndexPath) -> [NSAttributedString.Key: Any] {
		switch detector {
		case .hashtag, .mention:
			if isFromCurrentSender(message: message) {
				return [.foregroundColor: UIColor.white]
			} else {
				return [.foregroundColor: UIColor.primaryColor]
			}
        case .url :
            return [ .foregroundColor: UIColor.link, NSAttributedString.Key.underlineColor: UIColor.link, .underlineStyle: NSNumber(value: NSUnderlineStyle.double.rawValue)]
		default: return MessageLabel.defaultAttributes
		}
	}

	func enabledDetectors(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> [DetectorType] {
		return [.url, .address, .phoneNumber, .date, .transitInformation, .mention, .hashtag]
	}

	// MARK: - All Messages
	
	func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
		return isFromCurrentSender(message: message) ? .primaryColor : UIColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 1)
	}

	func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
		
		var corners: UIRectCorner = []
		
		if isFromCurrentSender(message: message) {
			corners.formUnion(.topLeft)
			corners.formUnion(.bottomLeft)
			if !isPreviousMessageSameSender(at: indexPath) {
				corners.formUnion(.topRight)
			}
			if !isNextMessageSameSender(at: indexPath) {
				corners.formUnion(.bottomRight)
			}
		} else {
			corners.formUnion(.topRight)
			corners.formUnion(.bottomRight)
			if !isPreviousMessageSameSender(at: indexPath) {
				corners.formUnion(.topLeft)
			}
			if !isNextMessageSameSender(at: indexPath) {
				corners.formUnion(.bottomLeft)
			}
		}
		
		return .custom { view in
			let radius: CGFloat = 16
			let path = UIBezierPath(roundedRect: view.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
			let mask = CAShapeLayer()
			mask.path = path.cgPath
			view.layer.mask = mask
		}
	}
	
	func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
		
		let avatar = getAvatarFor(sender: message.sender)
		avatarView.set(avatar: avatar)
		avatarView.isHidden = isNextMessageSameSender(at: indexPath)
		avatarView.layer.borderWidth = 2
		avatarView.layer.borderColor = UIColor.primaryColor.cgColor
	}
    
    func getInitialsFromSender(sender: SenderType) -> String {
        let formatter = PersonNameComponentsFormatter()
        if let components = formatter.personNameComponents(from: sender.displayName) {
             formatter.style = .abbreviated
             return formatter.string(from: components)
        }
        return "??"
    }
    
    func getAvatarFor(sender: SenderType) -> Avatar {
        let initials = getInitialsFromSender(sender: sender)
        switch sender.senderId {
        case "000000":
            return Avatar(image: nil, initials: "??")
        default:
            return Avatar(image: nil, initials: initials)
        }
    }
	
//	func configureAccessoryView(_ accessoryView: UIView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
//		// Cells are reused, so only add a button here once. For real use you would need to
//		// ensure any subviews are removed if not needed
//		accessoryView.subviews.forEach { $0.removeFromSuperview() }
//		accessoryView.backgroundColor = .clear
//
//		let shouldShow = Int.random(in: 0...10) == 0
//		guard shouldShow else { return }
//
//		let button = UIButton(type: .infoLight)
//		button.tintColor = .primaryColor
//		accessoryView.addSubview(button)
//		button.frame = accessoryView.bounds
//		button.isUserInteractionEnabled = false // respond to accessoryView tap through `MessageCellDelegate`
//		accessoryView.layer.cornerRadius = accessoryView.frame.height / 2
//		accessoryView.backgroundColor = UIColor.primaryColor.withAlphaComponent(0.3)
//	}

	func configureMediaMessageImageView(_ imageView: UIImageView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
		if case MessageKind.photo(let media) = message.kind, let imageURL = media.url {
            if imageURL.pathExtension != "jpg" || imageURL.pathExtension != "png" || imageURL.pathExtension != "heic" {
                imageView.kf.indicatorType = .activity
                imageView.kf.setImage(with: imageURL)
            } else {                
                imageView.kf.setImage(with: AVAssetImageDataProvider(assetURL: imageURL, seconds: 1))
            }
        }
	}
    
	
	// MARK: - Location Messages
	
	func annotationViewForLocation(message: MessageType, at indexPath: IndexPath, in messageCollectionView: MessagesCollectionView) -> MKAnnotationView? {
		let annotationView = MKAnnotationView(annotation: nil, reuseIdentifier: nil)
		let pinImage = #imageLiteral(resourceName: "ic_map_marker")
		annotationView.image = pinImage
		annotationView.centerOffset = CGPoint(x: 0, y: -pinImage.size.height / 2)
		return annotationView
	}
	
	func animationBlockForLocation(message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> ((UIImageView) -> Void)? {
		return { view in
			view.layer.transform = CATransform3DMakeScale(2, 2, 2)
			UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0, options: [], animations: {
				view.layer.transform = CATransform3DIdentity
			}, completion: nil)
		}
	}
	
	func snapshotOptionsForLocation(message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> LocationMessageSnapshotOptions {
		
		return LocationMessageSnapshotOptions(showsBuildings: true, showsPointsOfInterest: true, span: MKCoordinateSpan(latitudeDelta: 10, longitudeDelta: 10))
	}

	// MARK: - Audio Messages

	func audioTintColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
		return self.isFromCurrentSender(message: message) ? .white : .primaryColor
	}
	
}

// MARK: - MessagesLayoutDelegate

extension AdvancedExampleViewController: MessagesLayoutDelegate {

	func cellTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
		if isTimeLabelVisible(at: indexPath) {
			return 18
		}
		return 0
	}
	
	func messageTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
		if isFromCurrentSender(message: message) {
			return !isPreviousMessageSameSender(at: indexPath) ? 20 : 0
		} else {
			return !isPreviousMessageSameSender(at: indexPath) ? (20 + outgoingAvatarOverlap) : 0
		}
	}

	func messageBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
		return (!isNextMessageSameSender(at: indexPath) && isFromCurrentSender(message: message)) ? 16 : 0
	}

}

open class CustomMessagesFlowLayout: MessagesCollectionViewFlowLayout {
	
	open lazy var customMessageSizeCalculator = CustomMessageSizeCalculator(layout: self)
	
	open override func cellSizeCalculatorForItem(at indexPath: IndexPath) -> CellSizeCalculator {
		if isSectionReservedForTypingIndicator(indexPath.section) {
			return typingIndicatorSizeCalculator
		}
		let message = messagesDataSource.messageForItem(at: indexPath, in: messagesCollectionView)
		if case .custom = message.kind {
			return customMessageSizeCalculator
		}
		return super.cellSizeCalculatorForItem(at: indexPath)
	}
	
	open override func messageSizeCalculators() -> [MessageSizeCalculator] {
		var superCalculators = super.messageSizeCalculators()
		// Append any of your custom `MessageSizeCalculator` if you wish for the convenience
		// functions to work such as `setMessageIncoming...` or `setMessageOutgoing...`
		superCalculators.append(customMessageSizeCalculator)
		return superCalculators
	}
}

open class CustomMessageSizeCalculator: MessageSizeCalculator {
	
	public override init(layout: MessagesCollectionViewFlowLayout? = nil) {
		super.init()
		self.layout = layout
	}
	
	open override func sizeForItem(at indexPath: IndexPath) -> CGSize {
		guard let layout = layout else { return .zero }
		let collectionViewWidth = layout.collectionView?.bounds.width ?? 0
		let contentInset = layout.collectionView?.contentInset ?? .zero
		let inset = layout.sectionInset.left + layout.sectionInset.right + contentInset.left + contentInset.right
		return CGSize(width: collectionViewWidth - inset, height: 300)
	}
  
}

class CustomTextLayoutSizeCalculator: CustomLayoutSizeCalculator {

	var messageLabelFont = UIFont.preferredFont(forTextStyle: .body)
	var cellMessageContainerRightSpacing: CGFloat = 16

	override func messageContainerSize(for message: MessageType,
									   at indexPath: IndexPath) -> CGSize {
		let size = super.messageContainerSize(for: message,
											  at: indexPath)
		let labelSize = self.messageLabelSize(for: message,
											  at: indexPath)
		let selfWidth = labelSize.width +
			self.cellMessageContentHorizontalPadding +
			self.cellMessageContainerRightSpacing
		let width = max(selfWidth, size.width)
        let height = size.height + labelSize.height
	
		return CGSize(width: width,
					  height: height)
	}
	
	func messageLabelSize(for message: MessageType, at indexPath: IndexPath) -> CGSize {
		let attributedText: NSAttributedString

		let textMessageKind = message.kind
		switch textMessageKind {
		case .custom(_):
			return CGSize(width: 200, height: 200)
		case .attributedText(let text):
			attributedText = text
		case .text(let text), .emoji(let text):
			attributedText = NSAttributedString(string: text, attributes: [.font: messageLabelFont])
		default:
			fatalError("messageLabelSize received unhandled MessageDataType: \(message.kind)")
		}
        let size = attributedText.size()
		return size
	}
	
	func messageLabelFrame(for message: MessageType, at indexPath: IndexPath) -> CGRect {
		let origin = CGPoint(x: self.cellMessageContentHorizontalPadding / 2,
							 y: self.cellMessageContentVerticalPadding / 2)
        let size = self.messageLabelSize(for: message,
										 at: indexPath)
		
		return CGRect(origin: origin,
					  size: size)
	}
}

class CustomLayoutSizeCalculator: CellSizeCalculator {
	
	var cellTopLabelVerticalPadding: CGFloat = 32
	var cellTopLabelHorizontalPadding: CGFloat = 32
	var cellMessageContainerHorizontalPadding: CGFloat = 48
	var cellMessageContainerExtraSpacing: CGFloat = 16
	var cellMessageContentVerticalPadding: CGFloat = 16
	var cellMessageContentHorizontalPadding: CGFloat = 16
	var cellDateLabelHorizontalPadding: CGFloat = 24
	var cellDateLabelBottomPadding: CGFloat = 8
	
	var messagesLayout: MessagesCollectionViewFlowLayout {
		self.layout as! MessagesCollectionViewFlowLayout
	}
	
	var messageContainerMaxWidth: CGFloat {
		self.messagesLayout.itemWidth -
			self.cellMessageContainerHorizontalPadding -
			self.cellMessageContainerExtraSpacing
	}
	
	var messagesDataSource: MessagesDataSource {
		self.messagesLayout.messagesDataSource
	}
	
	init(layout: MessagesCollectionViewFlowLayout? = nil) {
		super.init()
		
		self.layout = layout
	}
	
	override func sizeForItem(at indexPath: IndexPath) -> CGSize {
		let dataSource = self.messagesDataSource
		let message = dataSource.messageForItem(at: indexPath,
												in: self.messagesLayout.messagesCollectionView)
		let itemHeight = self.cellContentHeight(for: message,
												at: indexPath)
		return CGSize(width: self.messagesLayout.itemWidth,
					  height: itemHeight)
	}

	func cellContentHeight(for message: MessageType, at indexPath: IndexPath) -> CGFloat {
        let cellToplabelSize: CGSize = cellTopLabelSize(for: message, at: indexPath)
        let cellMessageBottomLabelSize =  cellMessageBottomLabelSize(for: message, at: indexPath)
        let  messageContainerSize = messageContainerSize(for: message, at: indexPath)
        return cellToplabelSize.height + cellMessageBottomLabelSize.height  + messageContainerSize.height
	}
	
	// MARK: - Top cell Label

	func cellTopLabelSize(for message: MessageType, at indexPath: IndexPath) -> CGSize {
		guard let attributedText = self.messagesDataSource.cellTopLabelAttributedText(for: message,
																					  at: indexPath) else {
			return .zero
		}
		
		let maxWidth = self.messagesLayout.itemWidth - self.cellTopLabelHorizontalPadding
		let size = attributedText.size()
		let height = size.height + self.cellTopLabelVerticalPadding
		
		return CGSize(width: maxWidth,
					  height: height)
	}
	
	func cellTopLabelFrame(for message: MessageType, at indexPath: IndexPath) -> CGRect {
		let size = self.cellTopLabelSize(for: message, at: indexPath)
		guard size != .zero else {
			return .zero
		}
		
		let origin = CGPoint(x: self.cellTopLabelHorizontalPadding / 2, y: 0)
		return CGRect(origin: origin, size: size)
	}
	
	func cellMessageBottomLabelSize(for message: MessageType, at indexPath: IndexPath) -> CGSize {
		guard let attributedText = self.messagesDataSource.messageBottomLabelAttributedText(for: message,
																							at: indexPath) else {
			return .zero
		}
		return attributedText.size()
	}
	
	func cellMessageBottomLabelFrame(for message: MessageType, at indexPath: IndexPath) -> CGRect {
		let messageContainerSize = self.messageContainerSize(for: message,
															 at: indexPath)
		let labelSize = self.cellMessageBottomLabelSize(for: message,
														at: indexPath)
		let x = messageContainerSize.width - labelSize.width - (self.cellDateLabelHorizontalPadding / 2)
		let y = messageContainerSize.height - labelSize.height - self.cellDateLabelBottomPadding
		let origin = CGPoint(x: x,
							 y: y)
		
		return CGRect(origin: origin, size: labelSize)
	}
	
	// MARK: - MessageContainer

	func messageContainerSize(for message: MessageType, at indexPath: IndexPath) -> CGSize {
		let labelSize = self.cellMessageBottomLabelSize(for: message,
											   at: indexPath)
		let width = labelSize.width +
			self.cellMessageContentHorizontalPadding +
			self.cellDateLabelHorizontalPadding
        let height = labelSize.height +
			self.cellMessageContentVerticalPadding +
			self.cellDateLabelBottomPadding
		return CGSize(width: width,
					  height: height)
	}
	
	func messageContainerFrame(for message: MessageType, at indexPath: IndexPath, fromCurrentSender: Bool) -> CGRect {
		let y = self.cellTopLabelSize(for: message,
									  at: indexPath).height
		let size = self.messageContainerSize(for: message,
											 at: indexPath)
		let origin: CGPoint
		if fromCurrentSender {
			let x = self.messagesLayout.itemWidth - size.width - (self.cellMessageContainerHorizontalPadding / 2)
			origin = CGPoint(x: x, y: y)
		} else {
			origin = CGPoint(x: self.cellMessageContainerHorizontalPadding / 2, y: y)
		}
		
		return CGRect(origin: origin, size: size)
	}
}
