// swiftlint:disable file_length

import CXoneChatSDK
import InputBarAccessoryView
import Kingfisher
import MapKit
import MessageKit
import SafariServices
import Toast
import UIKit


class ThreadDetailViewController: MessagesViewController, ViewRenderable {
    
    // MARK: - Properties
    
    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }
    
    let presenter: ThreadDetailPresenter
    let myView = ThreadDetailView()
    
    var observation: NSKeyValueObservation?
    
    var timer: Timer?
    var textInputWaitTime: Int = 0
    
    
    // MARK: - Init
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    init(presenter: ThreadDetailPresenter) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }
    
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        messagesCollectionView = myView.messagesCollectionView
        messageInputBar = myView.messageInputBar
        super.viewDidLoad()
        
        presenter.subscribe(from: self)
        
        setupSubviews()
        
        scrollToBottomIfNeeded()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        presenter.onViewWillAppear()
    }
    
    override func loadView() {
        super.loadView()
        
        view = myView
        
        navigationItem.rightBarButtonItems = [
            .init(image: Assets.pencil, style: .plain, target: presenter, action: #selector(presenter.onEditCustomField)),
            .init(image: Assets.squareAndPencil, style: .plain, target: presenter, action: #selector(presenter.onEditThreadName))
        ]
        
        myView.refreshControl.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)
        
        title = presenter.documentState.thread.name?.mapNonEmpty { $0 }
            ?? presenter.documentState.thread.assignedAgent?.fullName.mapNonEmpty { $0 }
            ?? "No Agent"
    }
    
    func render(state: ThreadDetailViewState) {
        if !state.isLoading {
            hideLoading()
        }
        
        switch state {
        case .loading:
            showLoading()
        case .loaded:
            break
        case .error(let title, let message):
            showAlert(title: title, message: message)
        }
    }
    
    
    // MARK: - UICollectionViewDataSource
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let messagesDataSource = messagesCollectionView.messagesDataSource else {
            Log.error(CommonError.unableToParse("messagesDataSource", from: messagesCollectionView))
            return UICollectionViewCell()
        }
        guard !isSectionReservedForTypingIndicator(indexPath.section) else {
            return super.collectionView(collectionView, cellForItemAt: indexPath)
        }
        
        let item = messagesDataSource.messageForItem(at: indexPath, in: messagesCollectionView)
        
        switch item.kind {
        case .custom:
            return collectionView.dequeue(for: indexPath) as ThreadDetailPluginCell
        case .linkPreview:
            return collectionView.dequeue(for: indexPath) as ThreadDetailLinkCell
        default:
            return super.collectionView(collectionView, cellForItemAt: indexPath)
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        switch cell {
        case let cell as ThreadDetailPluginCell:
            guard let messageData = presenter.documentState.thread.messages[safe: indexPath.section]
            else {
                Log.error(CommonError.unableToParse("messageData", from: presenter.documentState.thread))
                return
            }
            
            cell.pluginDelegate = self
            cell.configure(with: messageData, at: indexPath, and: messagesCollectionView)
        case let cell as ThreadDetailLinkCell:
            guard let messageData = presenter.documentState.thread.messages[safe: indexPath.section] else {
                Log.error(CommonError.unableToParse("messageData", from: presenter.documentState.thread))
                return
            }
            
            cell.configure(with: messageData, at: indexPath, and: messagesCollectionView)
        default:
            super.collectionView(collectionView, willDisplay: cell, forItemAt: indexPath)
        }
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        contextMenuConfigurationForItemsAt indexPaths: [IndexPath],
        point: CGPoint
    ) -> UIContextMenuConfiguration? {
        guard let indexPath = indexPaths.first, let cell = collectionView.cellForItem(at: indexPath) else {
            Log.warning(.failed("Could not get first IndexPath or selected cell."))
            return nil
        }
        
        return .init(identifier: nil, previewProvider: nil) { [weak presenter] _ -> UIMenu? in
            var menuOptions = [UIAction]()
            
            switch cell {
            case let mediaCell as MediaMessageCell where cell is MediaMessageCell:
                let share = UIAction(title: "Share", image: .init(systemName: "square.and.arrow.up")) { _ in
                    presenter?.onShareCellContent(mediaCell.imageView.image)
                }
                let copy = UIAction(title: "Copy", image: .init(systemName: "doc.on.doc")) { _ in
                    presenter?.onCopyCellContent(mediaCell.imageView.image)
                }
                
                menuOptions = [share, copy]
            case let textCell as TextMessageCell where cell is TextMessageCell:
                let share = UIAction(title: "Share", image: .init(systemName: "square.and.arrow.up")) { _ in
                    presenter?.onShareCellContent(textCell.messageLabel.text)
                }
                let copy = UIAction(title: "Copy", image: .init(systemName: "doc.on.doc")) { _ in
                    presenter?.onCopyCellContent(textCell.messageLabel.text)
                }
                
                menuOptions = [share, copy]
            default:
                Log.warning(.failed("Unsupported cell content."))
                return nil
            }
            
            return UIMenu(options: .displayInline, children: menuOptions)
        }
    }
}


// MARK: - Actions

private extension ThreadDetailViewController {
    
    @objc
    func didPullToRefresh() {
        if presenter.documentState.thread.hasMoreMessagesToLoad {
            do {
                try CXoneChat.shared.threads.messages.loadMore(for: presenter.documentState.thread)
            } catch {
                error.logError()
                myView.refreshControl.endRefreshing()
            }
        } else {
            myView.refreshControl.endRefreshing()
        }
    }
}


// MARK: - PluginMessageDelegate

extension ThreadDetailViewController: PluginMessageDelegate {

    func pluginMessageView(_ view: PluginMessageView, subElementDidTap subElement: PluginMessageSubElementType) {
        switch subElement {
        case .button(let entity):
            if let postback = entity.postback {
                try? CXoneChat.shared.analytics.customVisitorEvent(data: .custom(postback))
            }
            guard let url = entity.url else {
                return
            }
            
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            } else {
                UIApplication.shared.rootViewController?.present(SFSafariViewController(url: url), animated: true)
            }
        default:
            break
        }
    }
    
    func pluginMessageView(_ view: PluginMessageView, quickReplySelected text: String) {
        try? CXoneChat.shared.analytics.customVisitorEvent(data: .custom("Quick Reply tapped."))
        
        inputBar(myView.messageInputBar, didPressSendButtonWith: text)
    }
}

// MARK: - AttachmentsInputBarAccessoryViewDelegate

extension ThreadDetailViewController: AttachmentsInputBarAccessoryViewDelegate {
    
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith attachments: [ChatAttachmentManager.Attachment]) {
        let message = inputBar.inputTextView.attributedText.string
        let attachments = attachments.compactMap { attachment -> AttachmentUpload? in
            switch attachment {
            case .image(let image):
                guard let data = image.jpegData(compressionQuality: 0.7) else {
                    return nil
                }
                
                return .init(data: data, mimeType: data.mimeType, fileName: "\(UUID().uuidString).\(data.fileExtension)")
            case .data(let data):
                return .init(data: data, mimeType: data.mimeType, fileName: "\(UUID().uuidString).\(data.fileExtension)")
            default:
                return nil
            }
        }
        
        Task { @MainActor in
            do {
                try await sendMessage(message, with: attachments, for: inputBar)
            } catch {
                error.logError()
                showAlert(title: "Ops!", message: error.localizedDescription)
            }
        }
    }
    
    @objc
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        Task { @MainActor in
            do {
                try await sendMessage(text, for: inputBar)
            } catch {
                error.logError()
                showAlert(title: "Ops!", message: error.localizedDescription)
            }
        }
    }
    
    func inputBar(_ inputBar: InputBarAccessoryView, textViewTextDidChangeTo text: String) {
        if timer != nil {
            if textInputWaitTime >= 5 {
                timer?.invalidate()
                textInputWaitTime = 0
                timer = nil
            }
        } else {
            do {
                try CXoneChat.shared.threads.reportTypingStart(true, in: presenter.documentState.thread)
            } catch {
                error.logError()
            }
            
            self.timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
                self?.textInputWaitTime += 1
                
                if let self = self, self.textInputWaitTime >= 5 {
                    self.textInputWaitTime = 0
                    timer.invalidate()
                    self.timer = nil
                    
                    do {
                        try CXoneChat.shared.threads.reportTypingStart(false, in: self.presenter.documentState.thread)
                    } catch {
                        error.logError()
                    }
                }
            }
        }
    }
}


// MARK: - MessagesDataSource

extension ThreadDetailViewController: MessagesDataSource {
    
    var currentSender: MessageKit.SenderType {
        CXoneChat.shared.customer.get() ?? CustomerIdentity(id: UUID().uuidString, firstName: "", lastName: "")
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        presenter.documentState.thread.messages.count
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        presenter.documentState.thread.messages[safe: indexPath.section] ?? presenter.documentState.thread.messages[0]
    }
    
    
    // MARK: - Labels
    
    func cellTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        guard indexPath.section % 3 == 0 && !presenter.isPreviousMessageSameSender(at: indexPath) else {
            return nil
            
        }
        
        return NSAttributedString(
            string: MessageKitDateFormatter.shared.string(from: message.sentDate),
            attributes: [
                NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 10),
                NSAttributedString.Key.foregroundColor: UIColor.darkGray
            ]
        )
    }
    
    func messageTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        guard !presenter.isPreviousMessageSameSender(at: indexPath) else {
            return nil
        }
        
        return NSAttributedString(
            string: message.sender.displayName,
            attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .caption1)]
        )
    }
    
    func messageBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        let currentMessage = presenter.documentState.thread.messages[indexPath.section]
        
        return NSAttributedString(
            string: (currentMessage.userStatistics.readAt != nil) ? "Read" : "Delivered",
            attributes: [
                NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 10),
                NSAttributedString.Key.foregroundColor: UIColor.darkGray
            ]
        )
    }
}

    
// MARK: - MessagesDisplayDelegate

extension ThreadDetailViewController: MessagesDisplayDelegate {
    
    // MARK: - Text Messages
    
    func textColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        isFromCurrentSender(message: message) ? .white : .darkText
    }
    
    func detectorAttributes(for detector: DetectorType, and message: MessageType, at indexPath: IndexPath) -> [NSAttributedString.Key: Any] {
        switch detector {
        case .hashtag, .mention:
            let color: UIColor = isFromCurrentSender(message: message) ? .white : .primaryColor
            
            return [.foregroundColor: color]
        case .url:
            let color: UIColor = isFromCurrentSender(message: message) ? .white : .link
            
            return [
                .foregroundColor: color,
                .underlineColor: color,
                .underlineStyle: NSNumber(value: NSUnderlineStyle.double.rawValue)
            ]
        default:
            return MessageLabel.defaultAttributes
        }
    }
    
    func enabledDetectors(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> [DetectorType] {
        [.url, .address, .phoneNumber, .date, .transitInformation, .mention, .hashtag]
    }
    
    // MARK: - All Messages
    
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        isFromCurrentSender(message: message) ? .primaryColor : UIColor(rgb: 230, 230, 230, alpha: 1)
    }
    
    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        var corners: UIRectCorner = []
        
        if isFromCurrentSender(message: message) {
            corners.formUnion(.topLeft)
            corners.formUnion(.bottomLeft)
            
            if !presenter.isPreviousMessageSameSender(at: indexPath) {
                corners.formUnion(.topRight)
            }
            if !presenter.isNextMessageSameSender(at: indexPath) {
                corners.formUnion(.bottomRight)
            }
        } else {
            corners.formUnion(.topRight)
            corners.formUnion(.bottomRight)
            
            if !presenter.isPreviousMessageSameSender(at: indexPath) {
                corners.formUnion(.topLeft)
            }
            if !presenter.isNextMessageSameSender(at: indexPath) {
                corners.formUnion(.bottomLeft)
            }
        }
        
        return .custom { view in
            let mask = CAShapeLayer()
            mask.path = UIBezierPath(roundedRect: view.bounds, byRoundingCorners: corners, cornerRadii: .init(width: 16, height: 16)).cgPath
            view.layer.mask = mask
        }
    }
    
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        let formatter = PersonNameComponentsFormatter()
        let initials = message.sender.senderId == "000000"
            ? "??"
            : formatter.personNameComponents(from: message.sender.displayName).map { components in
                formatter.style = .abbreviated
            
                return formatter.string(from: components)
            } ?? "??"
        
        avatarView.set(avatar: Avatar(image: nil, initials: initials))
        avatarView.isHidden = presenter.isNextMessageSameSender(at: indexPath)
        avatarView.layer.borderWidth = 2
        avatarView.layer.borderColor = UIColor.primaryColor.cgColor
    }
    
    func configureMediaMessageImageView(
        _ imageView: UIImageView,
        for message: MessageType,
        at indexPath: IndexPath,
        in messagesCollectionView: MessagesCollectionView
    ) {
        switch message.kind {
        case .photo(let media):
            guard let imageURL = media.url else {
                Log.error(CommonError.unableToParse("url", from: media))
                return
            }
            
            if imageURL.pathExtension != "jpg" || imageURL.pathExtension != "png" || imageURL.pathExtension != "heic" {
                imageView.kf.indicatorType = .activity
                imageView.kf.setImage(with: imageURL, placeholder: media.placeholderImage)
            } else {
                imageView.kf.setImage(with: AVAssetImageDataProvider(assetURL: imageURL, seconds: 1), placeholder: media.placeholderImage)
            }
        default:
            Log.warning(.failed("Unsupported media message type."))
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
    
    func animationBlockForLocation(
        message: MessageType,
        at indexPath: IndexPath,
        in messagesCollectionView: MessagesCollectionView
    ) -> ((UIImageView) -> Void)? {
        { view in
            view.layer.transform = CATransform3DMakeScale(2, 2, 2)
            
            UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0) {
                view.layer.transform = CATransform3DIdentity
            }
        }
    }
    
    func snapshotOptionsForLocation(
        message: MessageType,
        at indexPath: IndexPath,
        in messagesCollectionView: MessagesCollectionView
    ) -> LocationMessageSnapshotOptions {
        .init(showsBuildings: true, showsPointsOfInterest: true, span: MKCoordinateSpan(latitudeDelta: 10, longitudeDelta: 10))
    }
    
    
    // MARK: - Audio Messages
    
    func audioTintColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        isFromCurrentSender(message: message) ? .white : .primaryColor
    }
}


// MARK: - MessagesLayoutDelegate

extension ThreadDetailViewController: MessagesLayoutDelegate {
    
    func cellTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        let isTimeLabelVisible = indexPath.section % 3 == 0 && !presenter.isPreviousMessageSameSender(at: indexPath)
        
        return isTimeLabelVisible ? 18 : 0
    }
    
    func messageTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        if isFromCurrentSender(message: message) {
            return !presenter.isPreviousMessageSameSender(at: indexPath) ? 20 : 0
        } else {
            return !presenter.isPreviousMessageSameSender(at: indexPath) ? (20 + 18) : 0
        }
    }
    
    func messageBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        (!presenter.isNextMessageSameSender(at: indexPath) && isFromCurrentSender(message: message)) ? 16 : 0
    }
}


// MARK: - CXoneChatDelegate

extension ThreadDetailViewController: CXoneChatDelegate {
    
    func onAgentChange(_ agent: Agent, for threadId: UUID) {
        presenter.documentState.thread.assignedAgent = agent
        
        guard self.presenter.documentState.thread.name.isNilOrEmpty else {
            return
        }
        
        DispatchQueue.main.async {
            self.navigationItem.title = agent.fullName.mapNonEmpty { $0 } ?? "No Name"
        }
    }
    
    func onAgentTyping(_ isTyping: Bool, threadId: UUID) {
        guard threadId == presenter.documentState.thread.id else {
            Log.error("Did start typing in unknown thread.")
            return
        }
        guard timer == nil else {
            Log.error("Could not handle typing indicator because timer is not nil.")
            return
        }
        
        if isTyping {
            setTypingIndicatorViewHidden(false) {
                self.scrollToBottomIfNeeded()
            }
        } else {
            setTypingIndicatorViewHidden(true, performUpdates: nil)
        }
    }
    
    func onThreadLoad(_ thread: ChatThread) {
        DispatchQueue.main.async {
            self.hideLoading()
            
            self.updateThreadData()
            
            self.scrollToBottomIfNeeded()
        }
    }
    
    func onNewMessage(_ message: Message) {
        self.hideLoading()
        
        if message.threadId == presenter.documentState.thread.id {
            DispatchQueue.main.async {
                self.updateThreadData()
                (self.inputAccessoryView as? InputBarAccessoryView)?.sendButton.stopAnimating()
                (self.inputAccessoryView as? InputBarAccessoryView)?.inputTextView.placeholder = "Aa"
                
                self.scrollToBottomIfNeeded()
            }
        } else {
            presenter.onMessageReceivedFromOtherThread(message)
        }
    }
    
    func onLoadMoreMessages(_ messages: [Message]) {
        DispatchQueue.main.async {
            self.myView.refreshControl.endRefreshing()
        }
        
        updateThreadData()
    }
    
    func onAgentReadMessage(threadId: UUID) {
        updateThreadData()
    }
    
    func onThreadUpdate() {
        guard let index = CXoneChat.shared.threads.get().index(of: presenter.documentState.thread.id) else {
            Log.error(CommonError.unableToParse("index", from: CXoneChat.shared.threads))
            return
        }

        DispatchQueue.main.async {
            let thread = CXoneChat.shared.threads.get()[index]
            
            self.presenter.documentState.thread = thread
            self.title = thread.name?.mapNonEmpty { $0 }
                ?? thread.assignedAgent?.fullName.mapNonEmpty { $0 }
                ?? "No Agent"
        }
    }
    
    func onError(_ error: Error) {
        error.logError()
        
        DispatchQueue.main.async {
            self.hideLoading()
            
            self.myView.refreshControl.endRefreshing()
        }
    }
}


// MARK: - Private methods

private extension ThreadDetailViewController {
    
    @MainActor
    func sendMessage(_ message: String, with attachments: [AttachmentUpload] = [], for inputBar: InputBarAccessoryView) async throws {
        inputBar.invalidatePlugins()
        inputBar.inputTextView.text = String()
        inputBar.inputTextView.resignFirstResponder()
        inputBar.sendButton.startAnimating()
        inputBar.inputTextView.placeholder = "Sending..."
        
        if attachments.isEmpty {
            try await CXoneChat.shared.threads.messages.send(message, for: presenter.documentState.thread)
        } else {
            try await CXoneChat.shared.threads.messages.send(message, with: attachments, for: presenter.documentState.thread)
        }
        
        await Task.sleep(seconds: 1)
        
        inputBar.sendButton.stopAnimating()
        inputBar.inputTextView.placeholder = "Aa"
    }
    
    func updateThreadData() {
        presenter.updateThreadData()
        
        DispatchQueue.main.async {
            self.title = self.presenter.documentState.thread.name?.mapNonEmpty { $0 }
                ?? self.presenter.documentState.thread.assignedAgent?.fullName.mapNonEmpty { $0 }
                ?? "No Agent"
            
            self.messagesCollectionView.reloadData()
        }
    }
    
    func scrollToBottomIfNeeded() {
        DispatchQueue.main.async {
            guard self.messagesCollectionView.numberOfSections > 0 else {
                Log.info("CollectionView does not contain any sections.")
                return
            }
            
            let lastSection = self.messagesCollectionView.numberOfSections - 1
            let lastRow = self.messagesCollectionView.numberOfItems(inSection: lastSection)
            let indexPath = IndexPath(row: lastRow - 1, section: lastSection)
            
            self.messagesCollectionView.scrollToItem(at: indexPath, at: .bottom, animated: true)
        }
    }
    
    func setTypingIndicatorViewHidden(_ isHidden: Bool, performUpdates updates: (() -> Void)?) {
        DispatchQueue.main.async {
            self.setTypingIndicatorViewHidden(isHidden, animated: true, whilePerforming: updates) { [weak self] isSuccess in
                guard isSuccess else {
                    Log.error("Operation was not success.")
                    return
                }
                guard self?.isLastSectionVisible() ?? false else {
                    Log.error("Last section is not visible.")
                    return
                }
                
                self?.messagesCollectionView.scrollToLastItem(animated: true)
            }
        }
    }

    func isLastSectionVisible() -> Bool {
        guard let index = CXoneChat.shared.threads.get().index(of: presenter.documentState.thread.id) else {
            return false
        }
        guard let thread = CXoneChat.shared.threads.get()[safe: index] else {
            return false
        }
        
        return messagesCollectionView.indexPathsForVisibleItems.contains(.init(item: 0, section: thread.messages.count - 1))
    }
    
    func setupSubviews() {
        scrollsToLastItemOnKeyboardBeginsEditing = true
        showMessageTimestampOnSwipeLeft = true
        
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messageCellDelegate = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        
        CXoneChat.shared.delegate = self
        
        messageInputBar.delegate = self
    }
}
