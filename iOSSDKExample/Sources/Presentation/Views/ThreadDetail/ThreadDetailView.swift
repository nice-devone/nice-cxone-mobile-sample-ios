import ALProgressView
import InputBarAccessoryView
import MessageKit
import UIKit


class ThreadDetailView: UIView {
    
    // MARK: - Properties
    
    let messagesCollectionView = MessagesCollectionView(frame: .zero, collectionViewLayout: CustomMessagesFlowLayout())
    let messageInputBar = AttachmentsInputBarAccessoryView()
    let refreshControl = UIRefreshControl()
    let progressRing = ALProgressRing()
    
    
    // MARK: - Initialization

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    init() {
        super.init(frame: .zero)

        addSubview(progressRing)
        setupSubviews()
        setupConstraints()
    }
}


// MARK: - Private methods

private extension ThreadDetailView {

    func setupSubviews() {
        progressRing.isHidden = true
        progressRing.startColor = .cyan
        progressRing.grooveColor = .green
        progressRing.endColor = .blue
        
        setupCollectionView()
        setupInputBar()
    }
    
    func setupCollectionView() {
        messagesCollectionView.register(ThreadDetailPluginCell.self)
        messagesCollectionView.register(ThreadDetailLinkCell.self)
        messagesCollectionView.alwaysBounceVertical = true
        messagesCollectionView.refreshControl = refreshControl
        
        let layout = messagesCollectionView.collectionViewLayout as? MessagesCollectionViewFlowLayout
        layout?.sectionInset = .init(top: 1, left: 8, bottom: 1, right: 8)
        
        // Hide the outgoing avatar and adjust the label alignment to line up with the messages
        layout?.setMessageOutgoingAvatarSize(.zero)
        layout?.setMessageOutgoingMessageTopLabelAlignment(
            .init(textAlignment: .right, textInsets: .init(top: 0, left: 0, bottom: 0, right: 8))
        )
        layout?.setMessageOutgoingMessageBottomLabelAlignment(
            .init(textAlignment: .right, textInsets: .init(top: 0, left: 0, bottom: 0, right: 8))
        )
        // Set outgoing avatar to overlap with the message bubble
        layout?.setMessageIncomingMessageTopLabelAlignment(
            .init(textAlignment: .left, textInsets: .init(top: 0, left: 18, bottom: 18, right: 0))
        )
        layout?.setMessageIncomingAvatarSize(.init(width: 30, height: 30))
        layout?.setMessageIncomingMessagePadding(.init(top: -18, left: -18, bottom: 18, right: 18))
        
        layout?.setMessageIncomingAccessoryViewSize(.init(width: 30, height: 30))
        layout?.setMessageIncomingAccessoryViewPadding(.init(left: 8, right: 0))
        layout?.setMessageIncomingAccessoryViewPosition(.messageBottom)
        layout?.setMessageOutgoingAccessoryViewSize(.init(width: 30, height: 30))
        layout?.setMessageOutgoingAccessoryViewPadding(.init(left: 0, right: 8))
    }
    
    func setupInputBar() {
        messageInputBar.isTranslucent = true
        messageInputBar.setRightStackViewWidthConstant(to: 36, animated: false)
        messageInputBar.padding.bottom = 8
        messageInputBar.middleContentViewPadding.right = -36

        messageInputBar.sendButton.setTitleColor(.primaryColor, for: .normal)
        messageInputBar.sendButton.setTitleColor(.primaryColor.withAlphaComponent(0.3), for: .highlighted)
        messageInputBar.sendButton.setSize(CGSize(width: 38, height: 38), animated: false)
        messageInputBar.sendButton.image = Assets.icUp
        messageInputBar.sendButton.imageView?.backgroundColor = UIApplication.isDarkModeActive ? UIColor.darkGray : UIColor.lightGray
        messageInputBar.sendButton.imageView?.layer.cornerRadius = 19
        
        setupInputTextView()
        
        messageInputBar.sendButton
            .onEnabled { item in
                UIView.animate(withDuration: 0.3) {
                    item.imageView?.backgroundColor = .primaryColor
                }
            }
            .onDisabled { item in
                UIView.animate(withDuration: 0.3) {
                    item.imageView?.backgroundColor = UIApplication.isDarkModeActive ? UIColor.darkGray : UIColor.lightGray
                }
            }
        messageInputBar.separatorLine.isHidden = true

        let charCountButton = InputBarButtonItem()
            .configure {
                $0.title = "0/140"
                $0.contentHorizontalAlignment = .right
                $0.setTitleColor(UIColor(white: 0.6, alpha: 1), for: .normal)
                $0.titleLabel?.font = UIFont.systemFont(ofSize: 10, weight: .bold)
                $0.setSize(CGSize(width: 50, height: 25), animated: false)
            }
            .onTextViewDidChange { item, textView in
                item.title = "\(textView.text.count)/140"
                let isOverLimit = textView.text.count > 140
                // Disable automated management when over limit
                item.inputBarAccessoryView?.shouldManageSendButtonEnabledState = !isOverLimit

                if isOverLimit {
                    item.inputBarAccessoryView?.sendButton.isEnabled = false
                }

                item.setTitleColor(isOverLimit ? .red : UIColor(white: 0.6, alpha: 1), for: .normal)
            }
        messageInputBar.setStackViewItems([.flexibleSpace, charCountButton], forStack: .bottom, animated: false)
    }
    
    func setupInputTextView() {
        messageInputBar.inputTextView.textContainerInset = .init(top: 8, left: 16, bottom: 8, right: 36)
        messageInputBar.inputTextView.placeholderLabelInsets = .init(top: 8, left: 16, bottom: 8, right: 36)
        messageInputBar.inputTextView.layer.borderColor = UIApplication.isDarkModeActive ? UIColor.darkGray.cgColor : UIColor.lightGray.cgColor
        messageInputBar.inputTextView.layer.borderWidth = 1
        messageInputBar.inputTextView.layer.cornerRadius = 18
        messageInputBar.inputTextView.layer.masksToBounds = true
        messageInputBar.inputTextView.scrollIndicatorInsets = .init(top: 8, left: 0, bottom: 8, right: 0)
        messageInputBar.inputTextView.textContainerInset.bottom = 8
    }
    
    func setupConstraints() {
        progressRing.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(80)
        }
    }
}
