import ALProgressView
import InputBarAccessoryView
import MessageKit
import UIKit


class ThreadDetailView: UIView {
    
    // MARK: - Properties
    
    let messagesCollectionView = MessagesCollectionView(frame: .zero, collectionViewLayout: CustomMessagesFlowLayout())
    let messageInputBar = MessagesInputBarAccessoryView()
    let refreshControl = UIRefreshControl()
    let progressRing = ALProgressRing()
    
    
    // MARK: - Initialization

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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
    }
    
    func setupCollectionView() {
        messagesCollectionView.register(ThreadDetailPluginCell.self)
        messagesCollectionView.register(ThreadDetailRichLinkCell.self)
        messagesCollectionView.register(ThreadDetailQuickRepliesCell.self)
        messagesCollectionView.register(ThreadDetailListPickerCell.self)
        messagesCollectionView.register(ThreadDetailLinkCell.self)
        messagesCollectionView.alwaysBounceVertical = true
        messagesCollectionView.refreshControl = refreshControl
        
        let layout = messagesCollectionView.collectionViewLayout as? MessagesCollectionViewFlowLayout
        layout?.sectionInset = UIEdgeInsets(top: 1, left: 8, bottom: 1, right: 8)
        
        // Hide the outgoing avatar and adjust the label alignment to line up with the messages
        layout?.setMessageOutgoingAvatarSize(.zero)
        layout?.setMessageOutgoingMessageTopLabelAlignment(
            LabelAlignment(textAlignment: .right, textInsets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 8))
        )
        layout?.setMessageOutgoingMessageBottomLabelAlignment(
            LabelAlignment(textAlignment: .right, textInsets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 8))
        )
        // Set outgoing avatar to overlap with the message bubble
        layout?.setMessageIncomingMessageTopLabelAlignment(
            LabelAlignment(textAlignment: .left, textInsets: UIEdgeInsets(top: 0, left: 18, bottom: 18, right: 0))
        )
        layout?.setMessageIncomingAvatarSize(CGSize(width: 30, height: 30))
        layout?.setMessageIncomingMessagePadding(UIEdgeInsets(top: -18, left: -18, bottom: 18, right: 18))
        
        layout?.setMessageIncomingAccessoryViewSize(CGSize(width: 30, height: 30))
        layout?.setMessageIncomingAccessoryViewPadding(HorizontalEdgeInsets(left: 8, right: 0))
        layout?.setMessageIncomingAccessoryViewPosition(.messageBottom)
        layout?.setMessageOutgoingAccessoryViewSize(CGSize(width: 30, height: 30))
        layout?.setMessageOutgoingAccessoryViewPadding(HorizontalEdgeInsets(left: 0, right: 8))
    }
    
    func setupConstraints() {
        progressRing.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(80)
        }
    }
}
