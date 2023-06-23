// swiftlint:disable file_length

import CXoneChatSDK
import InputBarAccessoryView
import Kingfisher
import MapKit
import MessageKit
import SafariServices
import Toast
import UIKit
import UniformTypeIdentifiers


class ThreadDetailViewController: MessagesViewController, ViewRenderable {
    
    // MARK: - Properties
    
    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }
    
    let presenter: ThreadDetailPresenter
    let myView = ThreadDetailView()
    
    var observation: NSKeyValueObservation?
    
    var timer: Timer?
    var textInputWaitTime: Int = 0
    
    lazy var audioPlayer = AudioPlayer(messageCollectionView: messagesCollectionView)
    
    
    // MARK: - Init
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(presenter: ThreadDetailPresenter) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        messagesCollectionView = myView.messagesCollectionView
        messageInputBar = myView.messageInputBar
        super.viewDidLoad()
        
        presenter.subscribe(from: self)
        
        setupSubviews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        presenter.onViewWillAppear()
    }
    
    override func loadView() {
        super.loadView()
        
        view = myView

        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: Assets.squareAndPencil, style: .plain, target: self, action: #selector(onButtonTapped))
        
        myView.refreshControl.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)
        
        title = presenter.threadName
    }
    
    func render(state: ThreadDetailViewState) {
        if !state.isLoading {
            hideLoading()
        }
        
        switch state {
        case .loading(let title):
            showLoading(title: title)
        case .loaded:
            updateThreadData()
            
            DispatchQueue.main.async {
                self.messagesCollectionView.reloadData()
                self.messagesCollectionView.scrollToLastItem()
            }
        case .error(let title, let message):
            showAlert(title: title, message: message)
        }
    }
    
    
    // MARK: - Methods
    
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        super.motionEnded(motion, with: event)
        
        guard motion == .motionShake else {
            return
        }
        
        let shareLogs = UIAlertAction(title: "Share Logs", style: .default) { _ in
            do {
                self.present(try Log.getLogShareDialog(), animated: true)
            } catch {
                error.logError()
            }
        }
        let removeLogs = UIAlertAction(title: "Remove Logs", style: .destructive) { _ in
            do {
                try Log.removeLogs()
            } catch {
                error.logError()
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        UIAlertController.show(.actionSheet, title: "Options", message: nil, actions: [shareLogs, removeLogs, cancelAction])
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
        case .custom(let type):
            switch type {
            case is MessageRichLink:
                return collectionView.dequeue(for: indexPath) as ThreadDetailRichLinkCell
            case is MessageQuickReplies:
                return collectionView.dequeue(for: indexPath) as ThreadDetailQuickRepliesCell
            case is MessageListPicker:
                return collectionView.dequeue(for: indexPath) as ThreadDetailListPickerCell
            default:
                return collectionView.dequeue(for: indexPath) as ThreadDetailPluginCell
            }
        case .linkPreview:
            return collectionView.dequeue(for: indexPath) as ThreadDetailLinkCell
        default:
            return super.collectionView(collectionView, cellForItemAt: indexPath)
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if cell is TypingIndicatorCell {
            return
        }
        guard let messageData = presenter.documentState.thread.messages[safe: indexPath.section] else {
            Log.error(CommonError.unableToParse("messageData", from: presenter.documentState.thread))
            return
        }
        
        if let cell = cell as? MessageContentCell {
            cell.configure(with: messageData, at: indexPath, and: messagesCollectionView)
        }
        
        let isLastCell = indexPath.section == presenter.documentState.thread.messages.count - 1
        
        switch cell {
        case let cell as ThreadDetailPluginCell:
            cell.isOptionSelectionEnabled = isLastCell
            cell.pluginDelegate = self
        case let cell as ThreadDetailQuickRepliesCell:
            cell.isOptionSelectionEnabled = isLastCell
            cell.messageDelegate = self
        case let cell as ThreadDetailListPickerCell:
            cell.messageDelegate = self
        case let cell as TypingIndicatorCell:
            cell.typingBubble.startAnimating()
        default:
            break
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
        
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { [weak presenter] _ -> UIMenu? in
            var menuOptions = [UIAction]()
            
            switch cell {
            case let mediaCell as MediaMessageCell where cell is MediaMessageCell:
                let share = UIAction(title: "Share", image: UIImage(systemName: "square.and.arrow.up")) { _ in
                    presenter?.onShareCellContent(mediaCell.imageView.image)
                }
                let copy = UIAction(title: "Copy", image: UIImage(systemName: "doc.on.doc")) { _ in
                    presenter?.onCopyCellContent(mediaCell.imageView.image)
                }
                
                menuOptions = [share, copy]
            case let textCell as TextMessageCell where cell is TextMessageCell:
                let share = UIAction(title: "Share", image: UIImage(systemName: "square.and.arrow.up")) { _ in
                    presenter?.onShareCellContent(textCell.messageLabel.text)
                }
                let copy = UIAction(title: "Copy", image: UIImage(systemName: "doc.on.doc")) { _ in
                    presenter?.onCopyCellContent(textCell.messageLabel.text)
                }
                
                menuOptions = [share, copy]
            case let cell as ThreadDetailRichLinkCell:
                let share = UIAction(title: "Share", image: UIImage(systemName: "square.and.arrow.up")) { _ in
                    presenter?.onShareCellContent(cell.linkUrl)
                }
                let copy = UIAction(title: "Copy", image: UIImage(systemName: "doc.on.doc")) { _ in
                    presenter?.onCopyCellContent(cell.linkUrl)
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
    
    @objc
    func onButtonTapped(_ sender: Any) {
        messageInputBar.inputTextView.resignFirstResponder()
        
        switch sender {
        case let button as UIBarButtonItem where button.image == Assets.squareAndPencil:
            presenter.onEditThreadName()
        case let button as UIBarButtonItem where button.image == Assets.pencil:
            presenter.onEditCustomField()
        default:
            Log.warning("Unknown sender did tap.")
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
    
    func pluginMessageView(_ view: PluginMessageView, quickReplySelected text: String, withPostback postback: String?) {
        try? CXoneChat.shared.analytics.customVisitorEvent(data: .custom("Quick Reply tapped."))
        
        send(OutboundMessage(text: text, postback: postback), for: self.messageInputBar)
    }
}


// MARK: - ThreadDetailRichMessageDelegate

extension ThreadDetailViewController: ThreadDetailRichMessageDelegate {
    
    func richMessageCell(_ cell: MessageContentCell, didSelect option: String, withPostback postback: String) {
        send(OutboundMessage(text: option, postback: postback), for: self.messageInputBar)
    }
}


// MARK: - AttachmentsInputBarAccessoryViewDelegate

extension ThreadDetailViewController: MessagesInputBarAccessoryDelegate {
    
    func inputBar(_ inputBar: MessagesInputBarAccessoryView, didRecordAudioMessage audioMessage: ChatAttachmentManager.Attachment) {
        let controller = AudioPreviewController(audioRecorder: inputBar.audioRecorder)
        controller.modalPresentationStyle = .formSheet
        controller.willSendAttachment = { [weak self] attachment in
            self?.inputBar(inputBar, didPressSendButtonWith: [attachment])
        }
        
        presenter.navigation.showController(controller)
    }
    
    func inputBar(_ inputBar: MessagesInputBarAccessoryView, didPressSendButtonWith attachments: [ChatAttachmentManager.Attachment]) {
        let message = inputBar.inputTextView.attributedText.string
        let attachments = attachments.compactMap { attachment -> ContentDescriptor? in
            switch attachment {
            case .image(let image):
                guard let data = image.jpegData(compressionQuality: 0.7) else {
                    return nil
                }
                
                let fileName = "\(UUID().uuidString).jpg"
                return ContentDescriptor(
                    data: data,
                    mimeType: "image/jpg",
                    fileName: fileName,
                    friendlyName: fileName
                )
            case .data(let data):
                let fileName = "\(UUID().uuidString).\(data.fileExtension)"
                return ContentDescriptor(
                    data: data,
                    mimeType: data.mimeType,
                    fileName: fileName,
                    friendlyName: fileName
                )
            case .url(let url):
                return ContentDescriptor(
                    url: url,
                    mimeType: url.mimeType,
                    fileName: "\(UUID().uuidString).\(url.pathExtension)",
                    friendlyName: url.lastPathComponent
                )
            }
        }
        
        send(OutboundMessage(text: message, attachments: attachments), for: inputBar)
    }
    
    @objc
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        send(OutboundMessage(text: text), for: inputBar)
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
        let messageStatus: String
        
        if let userStatistics = currentMessage.userStatistics {
            messageStatus = userStatistics.readAt != nil ? "Read" : "Delivered"
        } else {
            messageStatus = "Sent"
        }
        
        return NSAttributedString(
            string: messageStatus,
            attributes: [
                .font: UIFont.preferredFont(forTextStyle: .caption2, compatibleWith: UITraitCollection(legibilityWeight: .bold)),
                .foregroundColor: UIColor.darkGray
            ])
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
            mask.path = UIBezierPath(roundedRect: view.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: 16, height: 16)).cgPath
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
        LocationMessageSnapshotOptions(showsBuildings: true, showsPointsOfInterest: true, span: MKCoordinateSpan(latitudeDelta: 10, longitudeDelta: 10))
    }
    
    
    // MARK: - Audio Messages
    
    func audioTintColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        isFromCurrentSender(message: message) ? .white : .primaryColor
    }
    
    func configureAudioCell(_ cell: AudioMessageCell, message: MessageType) {
        audioPlayer.configureAudioCell(cell, message: message)
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
    
    func onConnect() {
        presenter.onConnect()
    }
    
    func onAgentChange(_ agent: Agent, for threadId: UUID) {
        presenter.documentState.thread.assignedAgent = agent
        
        guard presenter.documentState.thread.name.isNilOrEmpty else {
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
        
        DispatchQueue.main.async {
            self.setTypingIndicatorViewHidden(!isTyping, animated: true)
            
            self.messagesCollectionView.scrollToLastItem()
        }
    }
    
    func onThreadLoad(_ thread: ChatThread) {
        hideLoading()
        
        DispatchQueue.main.async {
            self.updateThreadData()
            
            self.messagesCollectionView.reloadData()
            self.messagesCollectionView.scrollToLastItem()
        }
    }
    
    func onNewMessage(_ message: Message) {
        self.hideLoading()
        
        if message.threadId == presenter.documentState.thread.id {
            DispatchQueue.main.async {
                self.updateThreadData()
                
                if message.direction == .toClient {
                    self.messagesCollectionView.refreshSectionToAddNewItem(self.presenter.documentState.thread.messages.count - 1)
                } else {
                    self.messagesCollectionView.refreshSection(self.presenter.documentState.thread.messages.count - 1)
                }
            }
        } else {
            presenter.onMessageReceivedFromOtherThread(message)
        }
    }
    
    func onLoadMoreMessages(_ messages: [Message]) {
        DispatchQueue.main.async {
            self.myView.refreshControl.endRefreshing()
            
            self.updateThreadData()
            
            self.messagesCollectionView.reloadData()
            self.messagesCollectionView.scrollToLastItem()
        }
    }
    
    func onAgentReadMessage(threadId: UUID) {
        DispatchQueue.main.async {
            let messageIndex = self.presenter.documentState.thread.messages.firstIndex { $0.userStatistics?.readAt == nil }
                
            self.updateThreadData()
            
            if let messageIndex {
                self.messagesCollectionView.refreshSection(messageIndex)
            }
        }
    }
    
    func onThreadUpdate() {
        guard let index = CXoneChat.shared.threads.get().index(of: presenter.documentState.thread.id) else {
            Log.error(CommonError.unableToParse("index", from: CXoneChat.shared.threads))
            return
        }

        self.presenter.documentState.thread = CXoneChat.shared.threads.get()[index]
        
        DispatchQueue.main.async {
            self.title = self.presenter.threadName
        }
    }
    
    func onError(_ error: Error) {
        error.logError()
        
        DispatchQueue.main.async {
            self.hideLoading()
            
            self.myView.refreshControl.endRefreshing()
        }
    }
    
    func onUnexpectedDisconnect() {
        presenter.onUnexpectedDisconnect()
    }
}


// MARK: - Private methods

private extension ThreadDetailViewController {
    
    @objc
    func willEnterForeground() {
        CXoneChat.shared.delegate = self
        
        presenter.willEnterForeground()
    }
    
    func send(_ message: OutboundMessage, for inputBar: InputBarAccessoryView) {
        inputBar.invalidatePlugins()
        inputBar.inputTextView.text = String()
        inputBar.inputTextView.resignFirstResponder()
        inputBar.sendButton.startAnimating()
        inputBar.inputTextView.placeholder = "Sending..."
        
        Task { @MainActor in
            do {
                try await presenter.onSendMessage(message)
                
                messagesCollectionView.refreshSectionToAddNewItem(presenter.documentState.thread.messages.count - 1)
            } catch {
                error.logError()
                showAlert(title: "Oops!", message: error.localizedDescription)
            }
            
            inputBar.sendButton.stopAnimating()
            inputBar.inputTextView.placeholder = "Aa"
        }
    }
    
    func updateThreadData() {
        presenter.updateThreadData()
        
        self.title = presenter.threadName
        
        let anyContactCustomFieldsExists = !(CXoneChat.shared.threads.customFields.get(for: presenter.input.thread.id) as [CustomFieldType]).isEmpty
        let isButtonPresented = navigationItem.rightBarButtonItems?.first { $0.image == Assets.pencil } != nil
        
        if anyContactCustomFieldsExists && !isButtonPresented {
            navigationItem.rightBarButtonItems?.append(
                UIBarButtonItem(image: Assets.pencil, style: .plain, target: self, action: #selector(onButtonTapped))
            )
        }
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
