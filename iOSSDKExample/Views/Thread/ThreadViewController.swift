import Foundation
import UIKit
import SwiftUI
import CXOneChatSDK
import ActivityIndicator
import MessageKit

/// Loads all of the threads and put them into a UITableViewController
@available(iOS 13.0, *)
class ThreadViewController: UITableViewController, CreateNewThreadDelegate {
	// MARK: - Variables
	var cxOneChat = CXOneChat.shared
	var first = true
    var addedThread = false
    var closure: (() -> Void )?
    var deleteClosure: (() -> Void)?
    var reconnectFailedNumber = 0
    var threads = [ChatThread]()
    var segmented = UISegmentedControl(frame: CGRect(x: 107, y: 24, width: UIScreen.main.bounds.width - 46, height: 32))
    var popupDismissed = false
    override func viewDidLoad() {
		super.viewDidLoad()
		self.tableView.register(ThreadCell.self, forCellReuseIdentifier: "threadCell")
        self.showActivityIndicator(color: .white)
        registerCallbacks()
        let signOutButton = UIBarButtonItem(title: "Sign Out", style: .plain, target: self, action: #selector(self.signOut))
        DispatchQueue.main.async {
            self.navigationItem.leftBarButtonItem = signOutButton
        }

        do {
            let encodedConfig = UserDefaults.standard.data(forKey: "connection-configuration")!
            let config = try JSONDecoder().decode(ConnectionConfiguration.self, from: encodedConfig)
            if config.isCustomEnvironment {
                try cxOneChat.connect(chatURL: config.chatUrl, socketURL: config.socketUrl, brandId: config.brandId, channelId: config.channelId)
            } else {
                try cxOneChat.connect(environment: config.environment!, brandId: config.brandId, channelId: config.channelId)
            }
        } catch {
            print(error)
        }
        segmented.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.black], for: .selected)
        segmented.selectedSegmentTintColor = .white
        segmented.insertSegment(withTitle: "Current", at: 0, animated: true)
        segmented.insertSegment(withTitle: "Archived", at: 1, animated: true)
        segmented.selectedSegmentIndex = 0
        segmented.addTarget(self, action: #selector(updateThreads), for: .primaryActionTriggered)
        let headerView = UIView(frame: CGRect(x: 0, y: 89, width: UIScreen.main.bounds.width, height: 68))
        segmented.translatesAutoresizingMaskIntoConstraints = false
        let separator = UIView(frame: .zero)
        separator.translatesAutoresizingMaskIntoConstraints = false
        separator.backgroundColor = .separator
        headerView.addSubview(segmented)
        headerView.addSubview(separator)
        NSLayoutConstraint.activate([
            segmented.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 18),
            segmented.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 23),
            segmented.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -23),
            segmented.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -18),
            separator.bottomAnchor.constraint(equalTo: headerView.bottomAnchor),
            separator.heightAnchor.constraint(equalToConstant: 0.5),
            separator.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 6),
            separator.trailingAnchor.constraint(equalTo: headerView.trailingAnchor)            
        ])
        tableView.tableHeaderView = headerView
//        do {
//            try cxOneChat.reportChatWindowOpen()
//        } catch {
//            print(error.localizedDescription)
//        }
    }

	override func viewDidAppear(_ animated: Bool) {
        updateThreads()
	}
    
    @objc func updateThreads() {
        self.threads = cxOneChat.threads.filter({
            segmented.selectedSegmentIndex == 0 ? $0.canAddMoreMessages : !$0.canAddMoreMessages
        })
        self.tableView.reloadData()
    }
    
    fileprivate func loadThreads() {
        do {
            if self.cxOneChat.channelConfig?.settings.hasMultipleThreadsPerEndUser ?? false {
                try self.cxOneChat.loadThreads()
            } else {
                try self.cxOneChat.loadThread()
            }
        } catch {
            print(error.localizedDescription)
        }
    }
	
	@objc func addThread() {
        let vc =  NewThreadCustomFieldsPopupViewController()
        vc.providesPresentationContextTransitionStyle = true
        vc.definesPresentationContext = true
        vc.modalPresentationStyle = .overCurrentContext
        addedThread = true
        vc.closure = { [weak self] customFields, createdThreadId in
            DispatchQueue.main.async {
                guard let thread = self?.cxOneChat.threads.first(where: {
                    $0.idOnExternalPlatform == createdThreadId
                }) else { return }
                self?.threads.append(thread)
                self?.tableView.reloadData()
                self?.closure = { [weak self] in
                    do {
                        try self?.cxOneChat.setCustomerCustomFields(customFields: customFields)
                        
                    } catch {
                        print(error.localizedDescription)
                    }
                }
                guard let index = self?.threads.firstIndex(where: {$0.idOnExternalPlatform == createdThreadId}) else {return}
                self?.goToThread(index: index)
            }
        }
        present(vc, animated: true, completion: nil)
		self.tableView.reloadData()
	}
    
    @objc func signOut() {
        CXOneChat.signOut()
        let nc = UINavigationController()
        nc.viewControllers.append(ConfigViewController())
        view.window?.rootViewController = nc
    }

	
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 90
	}
	
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        goToThread(index: indexPath.row)
	}
    
    func goToThread(index: Int) {
        let thread = threads[index]
        let vc: AdvancedExampleViewController = AdvancedExampleViewController(thread: thread)
        vc.closure = closure
        self.navigationController?.pushViewController(vc, animated: true)
    }
	
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return threads.count
	}
	
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "threadCell") as! ThreadCell
        let agentText = threads[indexPath.row].threadAgent?.fullName ?? "No Agent"
        cell.nameLabel.text = agentText
                
        let names = agentText.components(separatedBy: " ")
        var initials = ""
        for name in names {
            initials += String(name.first ?? Character.init("S"))
        }
        cell.avatarView.initials = initials
        if cxOneChat.channelConfig?.settings.hasMultipleThreadsPerEndUser ?? false {
            if let threadName = threads[indexPath.row].threadName, !threadName.isEmpty {
                cell.nameLabel.text = threadName
            } else {
                cell.nameLabel.text = "N/A"
            }
        }
        let kind = threads[indexPath.row].messages.last?.kind
        switch kind {
        case .text(let string):
            cell.lastMessageLabel.text = string
        case .photo(_):
            cell.lastMessageLabel.text = "Image"
        case .custom(_):
            cell.lastMessageLabel.text = threads[indexPath.row].messages.last?.messageContent.fallbackText
        default:
            break
        }
        return cell
    }
    

    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = UIContextualAction(style: .destructive, title: "Archive") { [unowned self] action, view, completionHandler in
            DispatchQueue.main.async {
                self.showActivityIndicator(color: .white)
            }
            self.deleteClosure = { [indexPath]  in
                DispatchQueue.main.async {
                    self.hideActivityIndicator()
                    self.threads[indexPath.row].canAddMoreMessages = false
                    self.updateThreads()
                    completionHandler(true)
                }
            }
            do {
                try self.cxOneChat.archiveThread(threadIdOnExternalPlatform: threads[indexPath.row].idOnExternalPlatform)
            } catch {
                print(error.localizedDescription)
            }
        }
        if self.cxOneChat.channelConfig != nil && self.cxOneChat.channelConfig?.settings.hasMultipleThreadsPerEndUser ?? false && segmented.selectedSegmentIndex == 0 {
            return UISwipeActionsConfiguration(actions: [delete])
        } else {
            return UISwipeActionsConfiguration(actions: [])
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "Archive"
    }
	
    func updateMetadata() {
        for thread in cxOneChat.threads {
            do {
                try cxOneChat.loadThreadInfo(threadIdOnExternalPlatform: thread.idOnExternalPlatform)
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func createNewThread() {
        if self.cxOneChat.channelConfig?.settings.hasMultipleThreadsPerEndUser == false {
            DispatchQueue.main.async {
                self.addThread()
            }
        }
    }
    
    fileprivate func promptForCustomerName() {
        let popupVC = ConfigChoosePopupViewController()
        popupVC.delegate = self
        popupVC.modalPresentationStyle = .overCurrentContext
        popupVC.customer = cxOneChat.customer
        self.present(popupVC, animated: true, completion: nil)
    }
    
    fileprivate func registerCallbacks() {
        cxOneChat.onConnect = { [weak self] in
            guard let self = self else {return}
            if self.cxOneChat.channelConfig!.settings.hasMultipleThreadsPerEndUser {
                self.addCreateThreadButton()
            }
            self.loadThreads()
            do {
                try self.cxOneChat.reportChatWindowOpen()
                try self.cxOneChat.reportPageView(title: "ThreadViewController", uri: "thread-view")
                
                // To manually execute a trigger, use the following line instead of reportPageView
//                try self.cxOneChat.executeTrigger(triggerId: UUID(uuidString: "1c3bf289-5885-43c9-91be-b92516a55dbe")!)
            } catch {
                print("Error reporting chat window open: \(error)")
            }
        }
        
        cxOneChat.onUnexpectedDisconnect = { [weak self] in
            guard let self = self else {return}
            DispatchQueue.main.async {
                self.showAlert(title: "Connection Dropped", message: "Please sign in again.")
                let navigationController = UINavigationController()
                navigationController.viewControllers.append(ConfigViewController())
                self.view.window?.rootViewController = navigationController
            }
        }

        cxOneChat.onThreadLoad = { [weak self] _ in
            guard let self = self else {return}
            DispatchQueue.main.async {
                if self.navigationController?.topViewController == self {
                    if self.cxOneChat.channelConfig?.settings.hasMultipleThreadsPerEndUser ?? false {
                        do {
                            try self.cxOneChat.loadThreads()
                        } catch {
                            print(error.localizedDescription)
                        }
                    } else {
                        DispatchQueue.main.async {
                            self.hideActivityIndicator()
                            let thread = self.cxOneChat.threads[0]
                            self.navigationController?.pushViewController(AdvancedExampleViewController(thread: thread), animated: true)
                        }
                    }
                }
            }
        }
        
        cxOneChat.onThreadLoadFail =  { [weak self] in
            DispatchQueue.main.async {
                self?.hideActivityIndicator()
                let customer = self?.cxOneChat.customer
                if (customer?.firstName.isEmpty ?? true || customer?.lastName.isEmpty ?? true ) {
                    self?.promptForCustomerName()
                } else {
                    self?.createNewThread()
                }
            }
        }

        cxOneChat.onNewMessage = {[weak self] message in
            guard let self = self else {return}
            guard let index = self.threads.firstIndex(where: {
                $0.idOnExternalPlatform == message.threadIdOnExternalPlatform
            }) else { return }
            DispatchQueue.main.async {
                if self.threads[index].messages.isEmpty {
                    self.updateMetadata()
                } else {
                    self.hideActivityIndicator()
                    self.tableView.reloadData()
                }
            }
        }
        
        cxOneChat.onThreadInfoLoad = {[weak self] _ in
            DispatchQueue.main.async {
                self?.threads = self?.cxOneChat.threads.filter({
                    $0.canAddMoreMessages
                }) ?? []
                self?.hideActivityIndicator()
                self?.tableView.reloadData()
            }
        }

        cxOneChat.onThreadArchive = { [weak self] in
            self?.deleteClosure?()
        }
        
        cxOneChat.onCustomPluginMessage = { pluginMessage in
            print("Plugin message received")
        }

        cxOneChat.onAgentChange = { [weak self] _, _ in
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }

        cxOneChat.onThreadsLoad =  { [weak self] threads in
            DispatchQueue.main.async {
                self?.hideActivityIndicator()
                if threads.isEmpty {
                    self?.createNewThread()
                } else {
                    self?.updateMetadata()
                    self?.threads = self?.cxOneChat.threads.filter({
                        $0.canAddMoreMessages
                    }) ?? []
                    self?.tableView.reloadData()
                }
                if (self?.cxOneChat.customer?.lastName.isEmpty ?? true || self?.cxOneChat.customer?.lastName.isEmpty ?? true ) {
                    self?.promptForCustomerName()
                }
            }
        }

        cxOneChat.onNewMessage = { [weak self] message in
            DispatchQueue.main.async { [weak self] in
                guard let self = self else {return}
                self.hideActivityIndicator()
                if self.addedThread {
                    guard let thread = self.cxOneChat.threads.last else { return }
                    let vc: AdvancedExampleViewController = AdvancedExampleViewController(thread: thread)
                    self.addedThread = false
                    vc.closure = self.closure
                    self.navigationController?.pushViewController(vc, animated: true)
                } else {
                    self.threads = self.cxOneChat.threads.filter({
                        $0.canAddMoreMessages
                    })
                    self.tableView.reloadData()
                }
            }
        }

        cxOneChat.onTokenRefreshFailed = { [weak self] in
            DispatchQueue.main.async {
                UserDefaults.standard.removeObject(forKey: "user")
                UserDefaults.standard.removeObject(forKey: "customer")
                UserDefaults.standard.removeObject(forKey: "token")
                self?.cxOneChat.customer = nil
               
                let vc = UIStoryboard(name: "Login", bundle: nil).instantiateInitialViewController()
                self?.view.window?.rootViewController = vc
            }
        }
        cxOneChat.onThreadUpdate = { [weak self] in
            DispatchQueue.main.async {
                self?.threads = self?.cxOneChat.threads ?? []
                self?.tableView.reloadData()
            }
        }
        cxOneChat.onProactivePopupAction = { [weak self] data, actionId in
            guard let self = self else {return}
            if self.popupDismissed == false {
                DispatchQueue.main.async {
                    let popupView = ProActiveActionPopup(data: data, actionId: actionId)
                    popupView.translatesAutoresizingMaskIntoConstraints = false
                    self.view.addSubview(popupView)
                    popupView.backgroundColor = UIColor(red: 217/255, green: 235/255, blue: 1.0, alpha: 1)
                    popupView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -29).isActive = true
                    popupView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 29).isActive = true
                    popupView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: -29).isActive = true
                    self.popupDismissed = true
                }
            }
        }
    }
    
    func addCreateThreadButton() {
        let navBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(self.addThread))
        DispatchQueue.main.async {
            self.navigationItem.rightBarButtonItem = navBarButtonItem
        }
    }
}
