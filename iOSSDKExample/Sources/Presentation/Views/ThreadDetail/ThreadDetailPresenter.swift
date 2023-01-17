import CXoneChatSDK
import UIKit


class ThreadDetailPresenter: BasePresenter<ThreadDetailPresenter.Input, ThreadDetailPresenter.Navigation, Void, ThreadDetailViewState> {
    
    // MARK: - Structs
    
    struct Input {
        let thread: ChatThread
    }
    
    struct Navigation {
        let showToast: (_ title: String, _ message: String) -> Void
        let showController: (UIViewController) -> Void
    }
    
    struct DocumentState {
        var thread: ChatThread
    }
    
    lazy var documentState = DocumentState(thread: input.thread)
}


// MARK: - Actions

extension ThreadDetailPresenter {
    
    func onShareCellContent(_ content: Any?) {
        let controller = UIActivityViewController(activityItems: [content as Any], applicationActivities: nil)
        
        navigation.showController(controller)
    }
    
    func onCopyCellContent(_ content: Any?) {
        switch content {
        case let text as String where content is String:
            UIPasteboard.general.string = text
        case let image as UIImage where content is UIImage:
            UIPasteboard.general.image = image
        default:
            Log.warning(.failed("Unsupported cell content."))
        }
    }
    
    @objc
    func onEditCustomField() {
        let locations = ["West Coast", "Northeast", "Southeast", "Midwest"]
        let locationCustomField = CXoneChat.shared.threads.customFields
            .get(for: documentState.thread.id)
            .first { $0.key == "location" } ?? (key: "location", value: "")
        let departments = ["Sales", "Services"]
        let departmentCustomField = CXoneChat.shared.threads.customFields
            .get(for: documentState.thread.id)
            .first { $0.key == "department" } ?? (key: "department", value: "")
        let entities = [
            FormTextFieldEntity(type: .list(locations), placeholder: "Locations", customField: locationCustomField),
            FormTextFieldEntity(type: .list(departments), placeholder: "Departments", customField: departmentCustomField)
        ]
        let controller = FormViewController(entity: .init(title: "Edit Custom Fields", entities: entities)) { [weak self] customFields in
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
    
    func onViewWillAppear() {
        do {
            try CXoneChat.shared.analytics.viewPage(title: "ChatView", uri: "chat-view")
        } catch {
            error.logError()
        }
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
