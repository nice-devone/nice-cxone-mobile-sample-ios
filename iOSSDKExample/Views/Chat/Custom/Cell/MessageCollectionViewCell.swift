//
//  CustomCell.swift
//  iOSSDKExample
//
//  Created by Customer Dynamics Development on 12/2/21.
//

import Foundation
import UIKit
import MessageKit
import CXOneChatSDK

class CustomMessageContentCell: MessageCollectionViewCell {
	func callBackFirstDisplayView(_ stackView: UIStackView, _ url: [MessagePayloadElement?], _ index: Int) {
		
	}
	
	func downloadImages(_ url: String, _ index: Int) {
		
	}
	
	
	/// The `MessageCellDelegate` for the cell.
	weak var delegate: MessageCellDelegate?
	
	/// The container used for styling and holding the message's content view.
	var messageContainerView: UIView = {
		let containerView = UIView()
		containerView.clipsToBounds = true
		containerView.layer.masksToBounds = true
		return containerView
	}()

	/// The top label of the cell.
	var cellTopLabel: UILabel = {
		let label = UILabel()
		label.numberOfLines = 0
		label.textAlignment = .center
		return label
	}()
	
	var cellDateLabel: UILabel = {
		let label = UILabel()
		label.numberOfLines = 0
		label.textAlignment = .right
		return label
	}()
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		self.contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
		self.setupSubviews()
	}

	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		self.contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
		self.setupSubviews()
	}

	override func prepareForReuse() {
		super.prepareForReuse()
		self.cellTopLabel.text = nil
		self.cellTopLabel.attributedText = nil
		self.cellDateLabel.text = nil
		self.cellDateLabel.attributedText = nil
	}
	
	/// Handle tap gesture on contentView and its subviews.
	override func handleTapGesture(_ gesture: UIGestureRecognizer) {
		let touchLocation = gesture.location(in: self)

		switch true {
		case self.messageContainerView.frame.contains(touchLocation) && !self.cellContentView(canHandle: convert(touchLocation, to: messageContainerView)):
			self.delegate?.didTapMessage(in: self)
		case self.cellTopLabel.frame.contains(touchLocation):
			self.delegate?.didTapCellTopLabel(in: self)
		case self.cellDateLabel.frame.contains(touchLocation):
			self.delegate?.didTapMessageBottomLabel(in: self)
		default:
			self.delegate?.didTapBackground(in: self)
		}
	}

	/// Handle long press gesture, return true when gestureRecognizer's touch point in `messageContainerView`'s frame
	override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
		let touchPoint = gestureRecognizer.location(in: self)
		guard gestureRecognizer.isKind(of: UILongPressGestureRecognizer.self) else { return false }
		return self.messageContainerView.frame.contains(touchPoint)
	}
	
	func setupSubviews() {
		self.messageContainerView.layer.cornerRadius = 5
		
		self.contentView.addSubview(self.cellTopLabel)
		self.contentView.addSubview(self.messageContainerView)
		self.messageContainerView.addSubview(self.cellDateLabel)
	}
	
	func configure(with message: MessageType,
				   with fullMessage: Message,
				   at indexPath: IndexPath,
				   in messagesCollectionView: MessagesCollectionView,
				   dataSource: MessagesDataSource,
				   and sizeCalculator: CustomLayoutSizeCalculator) {
		guard let displayDelegate = messagesCollectionView.messagesDisplayDelegate else {
			return
		}
		self.cellTopLabel.frame = sizeCalculator.cellTopLabelFrame(for: message,
																   at: indexPath)
		self.cellDateLabel.frame = sizeCalculator.cellMessageBottomLabelFrame(for: message,
																	 at: indexPath)
		self.messageContainerView.frame = sizeCalculator.messageContainerFrame(for: message,
																			   at: indexPath,
																			   fromCurrentSender: dataSource.isFromCurrentSender(message: message))
		self.cellTopLabel.attributedText = dataSource.cellTopLabelAttributedText(for: message,
																				 at: indexPath)
		self.cellDateLabel.attributedText = dataSource.messageBottomLabelAttributedText(for: message,
																						at: indexPath)
		self.messageContainerView.backgroundColor = displayDelegate.backgroundColor(for: message,
																					at: indexPath,
																					in: messagesCollectionView)
		
	}

	/// Handle `ContentView`'s tap gesture, return false when `ContentView` doesn't needs to handle gesture
	func cellContentView(canHandle touchPoint: CGPoint) -> Bool {
		false
	}
}

class CustomTextMessageContentCell: CustomMessageContentCell {
	
	/// The label used to display the message's text.
	var messageLabel: UILabel = {
		let label = UILabel()
		label.numberOfLines = 0
		label.font = UIFont.preferredFont(forTextStyle: .body)
		
		return label
	}()
	
	var stackView: UIStackView = {
		var stackView = UIStackView()
		stackView.axis = .vertical
		stackView.spacing = 5
		stackView.distribution = .fillEqually
		return stackView
	}()

	var button1: PressableButton = {
		var button = PressableButton()
		button.colors = .init(
				button: UIColor(red: 52/255, green: 152/255, blue: 219/255, alpha: 1),
				shadow: UIColor(red: 41/255, green: 128/255, blue: 185/255, alpha: 1)
		)
		button.setTitle("Hello World", for: .normal)
        button.addTarget(CustomTextMessageContentCell.self, action: #selector(doSomething), for: .touchUpInside)
		return button
	}()
	
	var button2: PressableButton = {
		var button = PressableButton()
		button.setTitle("Hello World", for: .normal)
        button.addTarget(CustomTextMessageContentCell.self, action: #selector(doSomething), for: .touchUpInside)
		return button
	}()
	
	var button3: PressableButton = {
		var button = PressableButton()
		button.setTitle("Hello World", for: .normal)
        button.addTarget(CustomTextMessageContentCell.self, action: #selector(doSomething), for: .touchUpInside)
		return button
	}()

	override func prepareForReuse() {
		super.prepareForReuse()
		
		self.messageLabel.attributedText = nil
		self.messageLabel.text = nil
	}

	override func setupSubviews() {
		super.setupSubviews()
		
		self.messageContainerView.addSubview(stackView)

		stackView.translatesAutoresizingMaskIntoConstraints = false
		stackView.leadingAnchor.constraint(equalTo: self.messageContainerView.leadingAnchor, constant: 5).isActive = true
		stackView.trailingAnchor.constraint(equalTo: self.messageContainerView.trailingAnchor, constant: -5).isActive = true
		stackView.topAnchor.constraint(equalTo: self.messageContainerView.topAnchor, constant: 5).isActive = true
		stackView.bottomAnchor.constraint(equalTo: self.messageContainerView.bottomAnchor, constant: -5).isActive = true
		
		self.messageLabel.height(constant: 40)

	}
	
	var configured: Bool = false
	
	override func configure(with message: MessageType,
							with fullMessage: Message,
							at indexPath: IndexPath,
							in messagesCollectionView: MessagesCollectionView,
							dataSource: MessagesDataSource,
							and sizeCalculator: CustomLayoutSizeCalculator) {
		super.configure(with: message,
						with: fullMessage,
						at: indexPath,
						in: messagesCollectionView,
						dataSource: dataSource,
						and: sizeCalculator)
		if configured {} else {
			configured = true
            guard messagesCollectionView.messagesDisplayDelegate != nil else {
				return
			}

			let calculator = sizeCalculator as? CustomTextLayoutSizeCalculator
			self.messageLabel.frame = calculator?.messageLabelFrame(for: message,
																	at: indexPath) ?? .zero
			print(self.messageLabel.frame)
			
			print("CUSTOM", fullMessage)
			for plugin in fullMessage.plugin {
				if plugin?.type == "MENU" {
					guard let elements = plugin?.elements else { return }
//					if fullMessage.plugin.count > 1 {
//						for plugin in fullMessage.plugin {
//							var pathArray: [String] = []
//							for element in fullMessage.plugin {
//								pathArray.append(element?.elements.first?.url ?? "")
//							}
//							carouselView.delegate = self
//							carouselView.setCarouselData(paths: fullMessage.plugin,  describedTitle: [], isAutoScroll: false, timer: nil, defaultImage: "defaultImage")
//							carouselView.setCarouselOpaque(layer: true, describedTitle: true, pageIndicator: false)
//							carouselView.setCarouselLayout(displayStyle: 0, pageIndicatorPositon: 0, pageIndicatorColor: nil, describedTitleColor: nil, layerColor: nil)
//							self.stackView.addArrangedSubview(carouselView)
//						}
//					} else {
					for element in elements {
						if element.type == "TEXT" {
							let label = UILabel()
							label.numberOfLines = 0
							label.font = UIFont.preferredFont(forTextStyle: .body)
							label.text = element.text
							label.height(constant: 40)
							self.stackView.addArrangedSubview(label)
						} else if element.type == "BUTTON" {
                            let button = PressableButton()
							button.colors = .init(
									button: UIColor(red: 52/255, green: 152/255, blue: 219/255, alpha: 1),
									shadow: UIColor(red: 41/255, green: 128/255, blue: 185/255, alpha: 1)
							)
							button.setTitle(element.text, for: .normal)
							button.addTarget(self, action: #selector(doSomething), for: .touchUpInside)
							button.height(constant: 40)
							self.stackView.addArrangedSubview(button)
						} else if element.type == "FILE" {
							if let url = element.url {
                                let imageView = UIImageView()
								imageView.contentMode = .scaleToFill
								imageView.load(url: URL(string: url)!, completion: {
									image in
								})
								imageView.layer.cornerRadius = 5
								imageView.height(constant: 60)
								self.stackView.addArrangedSubview(imageView)
							}
						}
					}
				}
			}
		}
	}
	
//	let carouselView: AACarousel = AACarousel()
//
//	func downloadImages(_ url: String, _ index: Int) {
//		let imageView = UIImageView()
//		imageView.load(url: URL(string: url)!, completion: {
//			image in
//			self.carouselView.images[index] = imageView.image ?? UIImage()
//		})
//	}
	
	@objc func doSomething() {
		print("Do Something")
	}
}
