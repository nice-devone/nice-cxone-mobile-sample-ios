// swiftlint:disable file_length

import CXoneChatSDK
import InputBarAccessoryView
import Kingfisher
import MapKit
import MessageKit
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
        
        if !CXoneChat.shared.connection.channelConfiguration.hasMultipleThreadsPerEndUser {
            title = presenter.documentState.thread.assignedAgent?.fullName.mapNonEmpty { $0 } ?? "No Agent"
        } else {
            title = presenter.documentState.thread.name.mapNonEmpty { $0 } ?? "No Agent"
        }
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
        
        if case .custom = messagesDataSource.messageForItem(at: indexPath, in: messagesCollectionView).kind {
            guard let messageData = presenter.documentState.thread.messages[safe: indexPath.section] else {
                Log.error(CommonError.unableToParse("messageData", from: presenter.documentState.thread))
                return UICollectionViewCell()
            }
            
            let cell: ThreadDetailCustomCell = collectionView.dequeue(for: indexPath)
            cell.pluginMessageView.configure(elements: messageData.messageContent.payload.elements)
            
            return cell
        }
        
        return super.collectionView(collectionView, cellForItemAt: indexPath)
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


// MARK: - CameraInputBarAccessoryViewDelegate

extension ThreadDetailViewController: CameraInputBarAccessoryViewDelegate {
    
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith attachments: [AttachmentManager.Attachment]) {
        let message = inputBar.inputTextView.attributedText.string
        let attachments = attachments.compactMap { attachment -> AttachmentUpload? in
            guard case .image(let image) = attachment, let data = image.jpegData(compressionQuality: 0.7) else {
                return nil
            }
            
            return .init(data: data, mimeType: data.mimeType, fileName: "\(UUID().uuidString).\(data.fileExtension)")
        }
        
        Task { @MainActor in
            do {
                try await CXoneChat.shared.threads.messages.send(message, with: attachments, for: presenter.documentState.thread)
                
                inputBar.invalidatePlugins()
                inputBar.inputTextView.text = String()
                inputBar.inputTextView.resignFirstResponder()
                inputBar.sendButton.startAnimating()
                inputBar.inputTextView.placeholder = "Sending..."
                
                await Task.sleep(seconds: 1)
                
                inputBar.sendButton.stopAnimating()
                inputBar.inputTextView.placeholder = "Aa"
            } catch {
                error.logError()
            }
        }
    }
    
    @objc
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        inputBar.inputTextView.text = String()
        inputBar.inputTextView.resignFirstResponder()
        inputBar.invalidatePlugins()
        inputBar.sendButton.startAnimating()
        inputBar.inputTextView.placeholder = "Sending..."
        inputBar.sendButton.stopAnimating()
        
        Task { @MainActor in
            do {
                try await CXoneChat.shared.threads.messages.send(text, for: presenter.documentState.thread)
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
    
    func currentSender() -> SenderType {
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
    
    func detectorAttributes(
        for detector: DetectorType,
        and message: MessageType,
        at indexPath: IndexPath
    ) -> [NSAttributedString.Key: Any] {
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
    
    func enabledDetectors(
        for message: MessageType,
        at indexPath: IndexPath,
        in messagesCollectionView: MessagesCollectionView
    ) -> [DetectorType] {
        [.url, .address, .phoneNumber, .date, .transitInformation, .mention, .hashtag]
    }
    
    // MARK: - All Messages
    
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        isFromCurrentSender(message: message) ? .primaryColor : UIColor(rgb: 230, 230, 230, alpha: 1)
    }
    
    func messageStyle(
        for message: MessageType,
        at indexPath: IndexPath,
        in messagesCollectionView: MessagesCollectionView
    ) -> MessageStyle {
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
    
    func configureAvatarView(
        _ avatarView: AvatarView,
        for message: MessageType,
        at indexPath: IndexPath,
        in messagesCollectionView: MessagesCollectionView
    ) {
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
        guard case MessageKind.photo(let media) = message.kind else {
            Log.error(CommonError.unableToParse("media", from: message.kind))
            return
        }
        guard let imageURL = media.url else {
            Log.error(CommonError.unableToParse("url", from: media))
            return
        }
        
        if imageURL.pathExtension != "jpg" || imageURL.pathExtension != "png" || imageURL.pathExtension != "heic" {
            imageView.kf.indicatorType = .activity
            imageView.kf.setImage(with: imageURL)
        } else {
            imageView.kf.setImage(with: AVAssetImageDataProvider(assetURL: imageURL, seconds: 1))
        }
    }
    
    
    // MARK: - Location Messages
    
    func annotationViewForLocation(
        message: MessageType,
        at indexPath: IndexPath,
        in messageCollectionView: MessagesCollectionView
    ) -> MKAnnotationView? {
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
    
    func cellTopLabelHeight(
        for message: MessageType,
        at indexPath: IndexPath,
        in messagesCollectionView: MessagesCollectionView
    ) -> CGFloat {
        let isTimeLabelVisible = indexPath.section % 3 == 0 && !presenter.isPreviousMessageSameSender(at: indexPath)
        
        return isTimeLabelVisible ? 18 : 0
    }
    
    func messageTopLabelHeight(
        for message: MessageType,
        at indexPath: IndexPath,
        in messagesCollectionView: MessagesCollectionView
    ) -> CGFloat {
        if isFromCurrentSender(message: message) {
            return !presenter.isPreviousMessageSameSender(at: indexPath) ? 20 : 0
        } else {
            return !presenter.isPreviousMessageSameSender(at: indexPath) ? (20 + 18) : 0
        }
    }
    
    func messageBottomLabelHeight(
        for message: MessageType,
        at indexPath: IndexPath,
        in messagesCollectionView: MessagesCollectionView
    ) -> CGFloat {
        (!presenter.isNextMessageSameSender(at: indexPath) && isFromCurrentSender(message: message)) ? 16 : 0
    }
}


// MARK: - CXoneChatDelegate

extension ThreadDetailViewController: CXoneChatDelegate {
    
    func onCustomPluginMessage(_ messageData: [Any]) {
        guard let object = messageData[0] as? [String: Any] else {
            Log.error(CommonError.unableToParse("object", from: messageData))
            return
        }
        guard let variables = object["variables"] as? NSDictionary else {
            Log.error(CommonError.unableToParse("variables", from: object))
            return
        }
        
        let message = variables.reduce("") { result, data in
            result + "\(data.key): \(data.value)\n"
        }
        
        DispatchQueue.main.async {
            self.showAlert(title: "Plugin received: ", message: message)
        }
    }
    
    func onAgentChange(_ agent: Agent, for threadId: UUID) {
        presenter.documentState.thread.assignedAgent = agent
        
        if !CXoneChat.shared.connection.channelConfiguration.hasMultipleThreadsPerEndUser {
            DispatchQueue.main.async {
                self.navigationItem.title = agent.fullName.mapNonEmpty { $0 } ?? "No Name"
            }
        }
    }
    
    func onAgentTyping(_ didEnd: Bool, id: UUID) {
        guard id == presenter.documentState.thread.id else {
            Log.error("Did start typing in unknown thread.")
            return
        }
        guard timer == nil else {
            Log.error("Could not handle typing indicator because timer is not nil.")
            return
        }
        
        if didEnd {
            setTypingIndicatorViewHidden(true, performUpdates: nil)
        } else {
            setTypingIndicatorViewHidden(false) {
                DispatchQueue.main.async {
                    self.scrollToBottomIfNeeded()
                }
            }
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
            self.presenter.documentState.thread = CXoneChat.shared.threads.get()[index]
            self.title = self.presenter.documentState.thread.name ?? "No Agent"
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
    
    func updateThreadData() {
        presenter.updateThreadData()
        
        DispatchQueue.main.async {
            self.messagesCollectionView.reloadData()
        }
    }
    
    func scrollToBottomIfNeeded() {
        guard messagesCollectionView.numberOfSections > 0 else {
            Log.info("CollectionView does not contain any sections.")
            return
        }
        
        let lastSection = messagesCollectionView.numberOfSections - 1
        let lastRow = messagesCollectionView.numberOfItems(inSection: lastSection)
        let indexPath = IndexPath(row: lastRow - 1, section: lastSection)
        
        messagesCollectionView.scrollToItem(at: indexPath, at: .bottom, animated: true)
    }
    
    func setTypingIndicatorViewHidden(_ isHidden: Bool, performUpdates updates: (() -> Void)?) {
        setTypingIndicatorViewHidden(isHidden, animated: true, whilePerforming: updates) { [weak self] isSuccess in
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
