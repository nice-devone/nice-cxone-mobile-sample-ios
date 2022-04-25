//
//  Created by Customer Dynamics Development on 9/8/21.
//

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
	var sdkClient = CXOneChat.shared
	var first = true
    var addedThread = false
    var closure: (() -> Void )?
    var deleteClosure: (() -> Void)?
    var config: ChannelConfiguration?
    var recoverTHreadFailed = false
    var reconnectFailedNumber = 0
    override func viewDidLoad() {
		super.viewDidLoad()
		self.tableView.register(ThreadCell.self, forCellReuseIdentifier: "threadCell")        
        do{
            try sdkClient.connectChat()
        }catch {
            print(error.localizedDescription)
        }
        subcribeToevents()
        self.showActivityIndicator(color: .green)
        if sdkClient.getChannelConfiguration() != nil && sdkClient.getChannelConfiguration()?.settings.hasMultipleThreadsPerEndUser ?? false {
            addCreateThreadButton()
        }
	}
	
	override func viewDidAppear(_ animated: Bool) {
		self.tableView.reloadData()
	}
	
	@objc func addThread() {
        let vc =  NewThreadCustomFieldsPopupViewController()
        vc.providesPresentationContextTransitionStyle = true
        vc.definesPresentationContext = true
        vc.modalPresentationStyle = .overCurrentContext
        addedThread = true
        vc.closure = { [weak self] customFields in
            print("closure poput call")
            DispatchQueue.main.async {
                self?.tableView.reloadData()
                self?.closure = { [weak self] in
                    do {
                        try self?.sdkClient.setCustomerCustomFields(customFields: customFields)
                        
                    }catch {
                        print(error.localizedDescription)
                    }
                }
                guard let index = self?.sdkClient.threads.firstIndex(where: {$0.active}) else {return}
                self?.goToThread(index: index)
            }
            
        }

        present(vc, animated: true, completion: nil)
		self.tableView.reloadData()
	}
	
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 90
	}
	
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        sdkClient.setCurrentThread(idOnExternalPlatform: sdkClient.threads[indexPath.row].idOnExternalPlatform)
        goToThread(index: indexPath.row)
	}
    
    func goToThread(index: Int) {
        let vc: AdvancedExampleViewController = AdvancedExampleViewController(threadIndex: index)
        vc.closure = closure
        self.navigationController?.pushViewController(vc, animated: true)
    }
	
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return self.sdkClient.threads.count
	}
	
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "threadCell") as! ThreadCell
        cell.nameLabel.text = sdkClient.threads[indexPath.row].threadAgent.displayName.isEmpty ? "No Agent" : sdkClient.threads[indexPath.row].threadAgent.displayName
        
        let names = self.sdkClient.threads[indexPath.row].threadAgent.displayName.components(separatedBy: " ")
        var initials = ""
        for name in names {
            initials += String(name.first ?? Character.init("S"))
        }
        cell.avatarView.initials = initials
        let kind = self.sdkClient.threads[indexPath.row].messages.last?.kind
        switch kind {
        case .text(let string):
            cell.lastMessageLabel.text = string
        case .photo(_):
            cell.lastMessageLabel.text = "Image"
        default:
            break
        }
        return cell
    }
    

    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = UIContextualAction(style: .destructive, title: "Archive") { [unowned self] action, view, completionHandler in
            DispatchQueue.main.async {
                self.showActivityIndicator(color: .label)
            }
            self.deleteClosure = { [indexPath]  in
                DispatchQueue.main.async {
                    self.hideActivityIndicator()
                    self.sdkClient.delete(at: indexPath.row)
                    self.tableView.deleteRows(at:[indexPath] , with: .automatic)
                    completionHandler(true)
                }
            }
            do {
                try self.sdkClient.archiveThread(threadId: sdkClient.threads[indexPath.row].idOnExternalPlatform)
            }catch {
                print(error.localizedDescription)
            }
        }
        if config != nil && config?.settings.hasMultipleThreadsPerEndUser ?? false {
            return UISwipeActionsConfiguration(actions: [delete])
        }else {
            return UISwipeActionsConfiguration(actions: [])
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "Archive"
    }
	
    func updateMetadata() {
        for thread in sdkClient.threads {
            do {
                try sdkClient.loadThreadInfo(idOnExternalPlatform: thread.idOnExternalPlatform)
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func createNewThread() {
        if self.sdkClient.getChannelConfiguration()?.settings.hasMultipleThreadsPerEndUser == false {
            DispatchQueue.main.async {
                self.addThread()
            }
        }
    }
    
    fileprivate func getUserName() {
        let popupVC = ConfigChoosePopupViewController()
        popupVC.delegate = self
        popupVC.modalPresentationStyle = .overCurrentContext
        popupVC.customer = sdkClient.customer
        self.present(popupVC, animated: true, completion: nil)
    }
    
    fileprivate func subcribeToevents() {
        sdkClient.onThreadCreate = { [weak self] in
            guard let self = self  else {return}
            DispatchQueue.main.async {
                if self.navigationController?.topViewController == self {
                    if self.sdkClient.getChannelConfiguration()?.settings.hasMultipleThreadsPerEndUser ?? false {
                        do{
                            try  self.sdkClient.loadThreads()
                        }catch {
                            print(error.localizedDescription)
                        }
                    }else {
                        DispatchQueue.main.async {
                            self.hideActivityIndicator()
                            self.sdkClient.setCurrentThread(idOnExternalPlatform: self.sdkClient.threads[0].idOnExternalPlatform)
                            self.navigationController?.pushViewController(AdvancedExampleViewController(threadIndex: 0), animated: true)
                        }
                    }
                }
            }
           
        }
        sdkClient.onMessageAddedToThread = {[weak self] message in
            guard let self = self else {return}
            let index = self.sdkClient.threads.firstIndex(where: {
                $0.idOnExternalPlatform == message.threadId
            })
            DispatchQueue.main.async {
                if self.sdkClient.threads[index ?? 0].messages.isEmpty {
                    self.updateMetadata()
                }else {
                    self.hideActivityIndicator()
                    self.tableView.reloadData()
                }
            }
        }
        
        sdkClient.onThreadInfoLoad = {[weak self] in
            DispatchQueue.main.async {
                self?.hideActivityIndicator()
                self?.tableView.reloadData()
            }
        }
        sdkClient.onThreadArchive = { [weak self] in
            self?.deleteClosure?()
        }
        
        sdkClient.onData = { [weak self] data in
            self?.parsePluginData(data)
        }
        sdkClient.onAgentChange = { [weak self] in
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
        sdkClient.onLoadThreadFail =  { [weak self] in
            guard let self = self else {return}
            DispatchQueue.main.async {
                self.hideActivityIndicator()
                let customer = self.sdkClient.customer
                if (customer?.firstName.isEmpty ?? true || customer?.familyName.isEmpty ?? true ) {
                    self.getUserName()
                }else {
                    self.createNewThread()
                }
            }
        }
        
//        sdkClient.onLoadThreadFail = {[weak self] in
//            guard let self = self else {return}
//            self.recoverTHreadFailed = true
//        }
        sdkClient.onLoadThreads =  { [weak self] threads in
            DispatchQueue.main.async {
                self?.hideActivityIndicator()
                if threads.isEmpty {
                    self?.createNewThread()
                }else {
                    self?.updateMetadata()
                    self?.tableView.reloadData()
                }
                if (self?.sdkClient.customer?.firstName.isEmpty ?? true || self?.sdkClient.customer?.familyName.isEmpty ?? true ) {
                    self?.getUserName()
                }
            }
        }
        sdkClient.onMessageAddedToChatView = { [weak self] message in
            DispatchQueue.main.async { [weak self] in
                guard let self = self else {return}
                self.hideActivityIndicator()
                if self.addedThread {
                    let vc: AdvancedExampleViewController = AdvancedExampleViewController(threadIndex: self.sdkClient.threads.count - 1)
                    self.addedThread = false
                    print("closure:", self.closure == nil)
                    vc.closure = self.closure
                    self.navigationController?.pushViewController(vc, animated: true)
                }else {
                    self.tableView.reloadData()
                }
            }
        }
        sdkClient.onTokenRefreshFailed = {
            DispatchQueue.main.async {
                UserDefaults.standard.removeObject(forKey: "user")
                UserDefaults.standard.removeObject(forKey: "customer")
                UserDefaults.standard.removeObject(forKey: "token")
                self.sdkClient.customer = nil
               
                let vc = UIStoryboard(name: "Login", bundle: nil).instantiateInitialViewController()
                self.view.window?.rootViewController = vc
            }
        }
        sdkClient.onChannelConfigLoad = { [weak self] config in
            DispatchQueue.main.async {
                self?.config = config
                if config.settings.hasMultipleThreadsPerEndUser {
                    self?.addCreateThreadButton()
                }
            }
        }

    }
    
    func addCreateThreadButton() {
        let navBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addThread))
        navigationItem.rightBarButtonItem = navBarButtonItem
    }
}

public extension  UIViewController {
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alert.addAction(action)
        self.showDetailViewController(alert, sender: self)
    }
    
    func parsePluginData(_ data: Data) {
        var messages = ""
        
        do {
            let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            if let data = json?["data"] as? [String: Any] {
                let message = data["message"] as? NSDictionary
                let content = message?["messageContent"] as? NSDictionary
                let payload = content?["payload"] as? [String: Any]
                let elements = payload?["elements"] as! [[String: Any]]
                let variables = elements[0]["variables"] as! NSDictionary
                for (key,val)in variables {
                    messages.append("\(key): \(val) \n ")
                }
                print("message:", messages)
                DispatchQueue.main.async {[weak self] in
                    self?.showAlert(title: "Plugin received:", message: messages)
                }
            }
        } catch {
            _ = error
        }
    }
}
