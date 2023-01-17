import CXoneChatSDK
import Foundation
import UIKit


class ThreadListPresenter: BasePresenter<
    ThreadListPresenter.Input,
    ThreadListPresenter.Navigation,
    Void,
    ThreadListViewState
> {

    // MARK: - Structs
    
    struct Input {
        let configuration: Configuration
    }

    struct Navigation {
        var presentController: (UIViewController) -> Void
        var navigateToThread: (ChatThread) -> Void
        var navigateToLogin: () -> Void
        var navigateToConfiguration: () -> Void
        var showProactiveActionPopup: (_ data: [String: Any], _ actionId: UUID) -> Void
    }
    
    struct DocumentState {
        var isConnected = false
        var threads = [ChatThread]()
        var isCurrentThreadsSegmentSelected = true
        let locations = ["West Coast", "Northeast", "Southeast", "Midwest"]
        let departments = ["Sales", "Services"]
        
        var isMultiThread: Bool { CXoneChat.shared.connection.channelConfiguration.hasMultipleThreadsPerEndUser }
    }
    
    
    // MARK: - Properties
    
    lazy var documentState = DocumentState()
    
    
    // MARK: - Init
    
    override func viewDidSubscribe() {
        super.viewDidSubscribe()
        
        CXoneChat.shared.delegate = self
        
        Task { @MainActor in
            viewState.toLoading()
            
            do {
                try await connect()
            } catch {
                error.logError()
                viewState.toError(title: "Ops!", message: error.localizedDescription)
            }
        }
    }
}


// MARK: - Actions

extension ThreadListPresenter {
    
    @objc
    func signOut() {
        CXoneChat.signOut()
        
        navigation.navigateToConfiguration()
    }
    
    func onViewDidAppear() {
        guard documentState.isConnected else {
            return
        }
        
        fetchThreads()
    }
    
    @objc
    func onAddThreadTapped() {
        guard documentState.isMultiThread || documentState.threads.isEmpty else {
            Log.error(CommonError.failed("Cannot create new thread - Current brand is not multi thread."))
            viewState.toError(title: "Unable to create new thread", message: "Your brand supports only single conversation.")
            return
        }
        
        promptUserCredentials()
    }
    
    @objc
    func onSegmentControlChanged(isCurrentThreadsSegmentSelected: Bool) {
        documentState.isCurrentThreadsSegmentSelected = isCurrentThreadsSegmentSelected
        
        fetchThreads()
    }
    
    func onThreadSwipeToDelete(_ thread: ChatThread) {
        viewState.toLoading()
        
        do {
            try CXoneChat.shared.threads.archive(thread)
            
            fetchThreads()
        } catch {
            error.logError()
            viewState.toError(title: "Ops!", message: error.localizedDescription)
        }
    }
    
    @MainActor
    func onThreadTapped(thread: ChatThread) async {
        do {
            try CXoneChat.shared.threads.load(with: thread.id)
            
            navigation.navigateToThread(thread)
        } catch {
            error.logError()
            viewState.toError(title: "Ops", message: error.localizedDescription)
        }
    }
}


// MARK: - CXoneChatDelegate

extension ThreadListPresenter: CXoneChatDelegate {
    
    func onConnect() {
        documentState.isConnected = true
        do {
            try loadThreads()
            
            try CXoneChat.shared.analytics.chatWindowOpen()
            try CXoneChat.shared.analytics.viewPage(title: "ThreadList", uri: "thread-view")
            
            // To manually execute a trigger, use the following line instead of reportPageView
            // if let triggerId = UUID(uuidString: "1c3bf289-5885-43c9-91be-b92516a55dbe") {
            //    try CXoneChat.shared.connection.executeTrigger(triggerId)
            // }
        } catch {
            error.logError()
            viewState.toError(title: "Ops!", message: error.localizedDescription)
        }
    }
    
    func onUnexpectedDisconnect() {
        documentState.isConnected = false
        
        viewState.toError(title: "Connection Dropped", message: "Please sign in again.")
    }
    
    func onThreadLoad(_ thread: ChatThread) {
        fetchThreads()
    }
    
    func onNewMessage(_ message: Message) {
        documentState.threads = CXoneChat.shared.threads.get().filter(\.canAddMoreMessages)
        
        guard let thread = documentState.threads.thread(by: message.threadId) else {
            Log.error(CommonError.unableToParse("thread", from: documentState.threads))
            viewState.toError(title: "Ops!", message: "Something went wrong. Please, try again later.")
            return
        }
        
        if thread.messages.isEmpty {
            do {
                try updateThreadsMetadata()
            } catch {
                error.logError()
                viewState.toError(title: "Ops!", message: error.localizedDescription)
            }
        } else {
            viewState.toLoaded(documentState: documentState)
        }
    }
    
    func onThreadInfoLoad(_ thread: ChatThread) {
        fetchThreads()
    }
    
    func onThreadArchive() {
        fetchThreads()
    }
    
    func onCustomPluginMessage(_ messageData: [Any]) {
        Log.info("Plugin message received")
        
        viewState.toLoaded(documentState: documentState)
    }
    
    func onAgentChange(_ agent: Agent, for threadId: UUID) {
        fetchThreads()
    }
    
    func onThreadsLoad(_ threads: [ChatThread]) {
        fetchThreads()
    }
    
    func onTokenRefreshFailed() {
        CXoneChat.shared.customer.set(nil)
        
        navigation.navigateToLogin()
    }
    
    func onThreadUpdate() {
        fetchThreads()
    }
    
    func onProactivePopupAction(data: [String: Any], actionId: UUID) {
        navigation.showProactiveActionPopup(data, actionId)
    }
    
    func onError(_ error: Error) {
        // "recoveringThreadFailed" is a soft error.
        if let error = error as? CXoneChatError, error == CXoneChatError.recoveringThreadFailed {
            Log.info(error.localizedDescription)
        } else {
            error.logError()
        }
        
        viewState.toLoaded(documentState: documentState)
    }
}


// MARK: - Private methods

private extension ThreadListPresenter {
    
    func updateThreadsMetadata() throws {
        try CXoneChat.shared.threads.get().forEach { thread in
            try CXoneChat.shared.threads.loadInfo(for: thread)
        }
    }
    
    func loadThreads() throws {
        if documentState.isMultiThread {
            try CXoneChat.shared.threads.load()
        } else {
            try CXoneChat.shared.threads.load(with: nil)
        }
    }
    
    @MainActor
    func connect() async throws {
        if let env = input.configuration.environment {
            try await CXoneChat.shared.connection.connect(environment: env, brandId: input.configuration.brandId, channelId: input.configuration.channelId)
        } else {
            try await CXoneChat.shared.connection.connect(
                chatURL: input.configuration.chatUrl,
                socketURL: input.configuration.socketUrl,
                brandId: input.configuration.brandId,
                channelId: input.configuration.channelId
            )
        }
    }
    
    func fetchThreads() {
        documentState.threads = CXoneChat.shared.threads
            .get()
            .filter { documentState.isCurrentThreadsSegmentSelected ? $0.canAddMoreMessages : !$0.canAddMoreMessages }
        
        viewState.toLoaded(documentState: documentState)
    }
    
    func promptUserCredentials() {
        let entities = [
            FormTextFieldEntity(type: .text, placeholder: "First Name", customField: (key: "firstName", value: "")),
            FormTextFieldEntity(type: .text, placeholder: "Last Name", customField: (key: "lastName", value: ""))
        ]
        let controller = FormViewController(entity: FormVO(title: "User Credentials", entities: entities)) { [weak self] customFields in
            CXoneChat.shared.customer.setName(
                firstName: customFields.first { $0.key == "firstName" }.map(\.value) ?? "",
                lastName: customFields.first { $0.key == "lastName" }.map(\.value) ?? ""
            )
            
            self?.promptContactCustomFields()
        }

        navigation.presentController(controller)
    }
    
    func promptContactCustomFields() {
        let entities: [FormTextFieldEntity] = [
            .init(type: .list(documentState.locations), placeholder: "Location", customField: (key: "location", value: "")),
            .init(type: .list(documentState.departments), placeholder: "Department", customField: (key: "department", value: ""))
        ]
        let controller = FormViewController(entity: .init(title: "Contact Custom Fields", entities: entities)) { [weak self] customFields in
            do {
                let threadId = try CXoneChat.shared.threads.create()
                
                guard let thread = CXoneChat.shared.threads.get().thread(by: threadId) else {
                    Log.error(CommonError.unableToParse("thread", from: self?.documentState.threads))
                    self?.viewState.toError(title: "Ops!", message: "Something went wrong. Please, try it again later.")
                    return
                }
                
                try CXoneChat.shared.threads.customFields.set(customFields, for: threadId)
                
                self?.fetchThreads()
                
                self?.navigation.navigateToThread(thread)
            } catch {
                error.logError()
                self?.viewState.toError(title: "Ops!", message: error.localizedDescription)
            }
        }
        
        navigation.presentController(controller)
    }
}
