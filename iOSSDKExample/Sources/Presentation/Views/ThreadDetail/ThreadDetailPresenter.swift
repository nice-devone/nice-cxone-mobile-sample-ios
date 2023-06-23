import CXoneChatSDK
import UIKit


class ThreadDetailPresenter: BasePresenter<ThreadDetailPresenter.Input, ThreadDetailPresenter.Navigation, Void, ThreadDetailViewState> {
    
    // MARK: - Structs
    
    struct Input {
        let configuration: Configuration
        let thread: ChatThread
    }
    
    struct Navigation {
        let showToast: (_ title: String, _ message: String) -> Void
        let showController: (UIViewController) -> Void
        let popToThreadList: () -> Void
    }
    
    struct DocumentState {
        var thread: ChatThread
        var isConnected = false
    }
    
    lazy var documentState = DocumentState(thread: input.thread)
    
    var threadName: String {
        documentState.thread.name?.mapNonEmpty { $0 }
            ?? documentState.thread.assignedAgent?.fullName.mapNonEmpty { $0 }
            ?? "No Agent"
    }
    
    
    // MARK: - Lifecycle
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidSubscribe() {
        super.viewDidSubscribe()
        
        NotificationCenter.default.addObserver(self, selector: #selector(didEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        
        
        if input.thread.messages.count == 1 {
            viewState.toLoading()
        
            do {
                try CXoneChat.shared.threads.load(with: input.thread.id)
            } catch {
                error.logError()
                viewState.toError(title: "Oops", message: error.localizedDescription)
                
                navigation.popToThreadList()
            }
        } else {
            viewState.toLoaded()
        }
    }
}


// MARK: - Actions

extension ThreadDetailPresenter {
    
    @objc
    func willEnterForeground() {
        guard !documentState.isConnected else {
            return
        }
        
        reconnect()
    }
    
    @objc
    func didEnterBackground() {
        documentState.isConnected = false
    }
    
    func onViewWillAppear() {
        documentState.isConnected = true
        
        do {
            try CXoneChat.shared.analytics.viewPage(title: "ChatView", uri: "chat-view")
        } catch {
            error.logError()
        }
    }
    
    func onUnexpectedDisconnect() {
        Log.trace("Reconnecting the CXone services.")
        
        reconnect()
    }
    
    func onConnect() {
        documentState.isConnected = true
        
        do {
            try CXoneChat.shared.threads.load(with: input.thread.id)
        } catch {
            error.logError()
            navigation.popToThreadList()
        }
    }
    
    func onShareCellContent(_ content: Any?) {
        let controller = UIActivityViewController(activityItems: [content as Any], applicationActivities: nil)

        navigation.showController(controller)
    }
    
    func onCopyCellContent(_ content: Any?) {
        switch content {
        case let content as UIImage:
            UIPasteboard.general.image = content
        case let content as URL:
            UIPasteboard.general.url = content
        default:
            break
        }
        
        UIPasteboard.general.string = content as? String
    }
    
    @objc
    func onEditCustomField() {
        let contactCustomFields: [CustomFieldType] = CXoneChat.shared.threads.customFields.get(for: input.thread.id)
        
        guard !contactCustomFields.isEmpty else {
            Log.error(.unableToParse("contactCustomFields"))
            return
        }
        
        let entity = FormVO(title: "Edit of Custom Fields", entities: contactCustomFields.map(FormCustomFieldType.init))
        let controller = FormViewController(entity: entity) { [weak self] customFields in
            guard let self = self else {
                return
            }

            do {
                try CXoneChat.shared.threads.customFields.set(customFields, for: self.documentState.thread.id)
            } catch {
                error.logError()
                self.viewState.toError(title: "Oops!", message: error.localizedDescription)
            }
        }

        navigation.showController(controller)
    }
    
    @objc
    func onEditThreadName() {
        let controller = UIAlertController(title: "Update Thread Name", message: "Enter a name for this thread.", preferredStyle: .alert)
        controller.addTextField { textField in
            textField.placeholder = "Thread name"
        }
        
        let saveAction = UIAlertAction(title: "Confirm", style: .default) { [weak self] _ in
            guard let self = self, let title = (controller.textFields?[safe: 0] as? UITextField)?.text else {
                Log.error(CommonError.unableToParse("title", from: controller.textFields?[safe: 0]))
                return
            }
            
            do {
                try CXoneChat.shared.threads.updateName(title, for: self.documentState.thread.id)
            } catch {
                error.logError()
                self.viewState.toError(title: "Oops!", message: error.localizedDescription)
            }
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
        controller.addAction(saveAction)
        controller.addAction(cancel)
        
        navigation.showController(controller)
    }
    
    func onMessageReceivedFromOtherThread(_ message: Message) {
        guard case .text(let text) = message.kind else {
            Log.error(CommonError.unableToParse("text", from: message))
            return
        }
        
        Task { @MainActor in
            self.navigation.showToast("New message from \(message.senderInfo.fullName)", text)
        }
    }
    
    func onSendMessage(_ message: OutboundMessage) async throws {
        let newMessage = try await CXoneChat.shared.threads.messages.send(message, for: documentState.thread)
        
        documentState.thread.messages.append(newMessage)
    }
    
    func updateThreadData() {
        guard let updatedThread = CXoneChat.shared.threads.get().thread(by: documentState.thread.id) else {
            Log.error(CommonError.unableToParse("updatedThread", from: CXoneChat.shared.threads))
            return
        }
        
        documentState.thread = updatedThread
    }
    
    func isPreviousMessageSameSender(at indexPath: IndexPath) -> Bool {
        guard indexPath.section - 1 >= 0 else {
            return false
        }
        
        guard let senderId = documentState.thread.messages[safe: indexPath.section]?.sender.senderId.lowercased(),
              let previousSenderId = documentState.thread.messages[safe: indexPath.section - 1]?.sender.senderId.lowercased()
        else {
            return false
        }
        
        return senderId == previousSenderId
    }
    
    func isNextMessageSameSender(at indexPath: IndexPath) -> Bool {
        guard indexPath.section + 1 < documentState.thread.messages.count else {
            return false
        }
        
        guard let senderId = documentState.thread.messages[safe: indexPath.section]?.sender.senderId.lowercased(),
              let nextSenderId = documentState.thread.messages[safe: indexPath.section + 1]?.sender.senderId.lowercased()
        else {
            return false
        }
        
        return senderId == nextSenderId
    }
}


// MARK: - Private methods

private extension ThreadDetailPresenter {
    
    func reconnect() {
        Task { @MainActor in
            viewState.toLoading(title: "Reconnecting...")
            
            try await CXoneChat.shared.connection.connect(
                chatURL: input.configuration.chatUrl,
                socketURL: input.configuration.socketUrl,
                brandId: input.configuration.brandId,
                channelId: input.configuration.channelId
            )
        }
    }
}
