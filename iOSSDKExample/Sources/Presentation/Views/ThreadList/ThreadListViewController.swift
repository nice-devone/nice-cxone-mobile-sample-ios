import CXoneChatSDK
import UIKit


class ThreadListViewController: BaseViewController, ViewRenderable {
    
    // MARK: - Properties
    
    let presenter: ThreadListPresenter
    private let myView = ThreadListView()
    
    private var threads = [ChatThread]()
    private var isMultiThread = false
    
    
    // MARK: - Init
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(presenter: ThreadListPresenter) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }


    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter.subscribe(from: self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        presenter.onViewDidAppear()
    }
    
    override func loadView() {
        super.loadView()
        
        title = "Threads"
        view = myView
        
        myView.tableView.register(ThreadListCell.self)
        myView.tableView.delegate = self
        myView.tableView.dataSource = self
        
        myView.segmentedControl.addTarget(self, action: #selector(onSegmentControlChanged), for: .primaryActionTriggered)
        
        let disconnectButton = UIBarButtonItem(
            image: UIImage(systemName: "bolt.slash.fill"),
            style: .plain,
            target: presenter,
            action: #selector(presenter.onDisconnectTapped)
        )
        disconnectButton.tintColor = .primaryColor
        
        navigationItem.leftBarButtonItem = disconnectButton
    }
    
    func render(state: ThreadListViewState) {
        if !state.isLoading {
            hideLoading()
        }
        
        switch state {
        case .loading(let title):
            showLoading(title: title)
        case .loaded(let entity):
            myView.emptyView.isHidden = !entity.threads.isEmpty
            myView.tableView.isHidden = entity.threads.isEmpty
            threads = entity.threads
            isMultiThread = entity.isMultiThread
            adjustNavigationBar()
            myView.tableView.reloadData()
        case .error(let title, let message):
            showAlert(title: title, message: message)
        }
    }
}


// MARK: - UITableViewDelegate, UITableViewDataSource

extension ThreadListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        "Archive"
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        90
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        Task { @MainActor in
            guard let thread = threads[safe: indexPath.row] else {
                Log.error(CommonError.unableToParse("thread", from: threads))
                return
            }
            
            await presenter.onThreadTapped(thread: thread)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        threads.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        tableView.dequeue(ThreadListCell.self, forIndexPath: indexPath)
    }
    
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let cell = cell as? ThreadListCell else {
            return
        }
        guard let thread = threads[safe: indexPath.row] else {
            Log.error(CommonError.unableToParse("thread", from: threads))
            return
        }
        
        cell.configure(thread: thread, isMultiThread: isMultiThread)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard isMultiThread, myView.segmentedControl.selectedSegmentIndex == 0 else {
            return UISwipeActionsConfiguration(actions: [])
        }
    
        let delete = UIContextualAction(style: .destructive, title: "Archive") { [weak self] _, _, _ in
            guard let self = self else {
                return
            }
            guard let thread = self.threads[safe: indexPath.row] else {
                Log.error(CommonError.unableToParse("thread", from: self.threads))
                return
            }
            
            self.presenter.onThreadSwipeToDelete(thread)
        }
        
        return UISwipeActionsConfiguration(actions: [delete])
    }
}


// MARK: - Actions

private extension ThreadListViewController {
    
    @objc
    func onSegmentControlChanged() {
        presenter.onSegmentControlChanged(isCurrentThreadsSegmentSelected: myView.segmentedControl.selectedSegmentIndex == 0)
    }
}


// MARK: - Private methods

private extension ThreadListViewController {

    func adjustNavigationBar() {
        let isEnabled = isMultiThread || threads.filter(\.canAddMoreMessages).isEmpty
        
        if navigationItem.rightBarButtonItem == nil {
            navigationItem.rightBarButtonItem = UIBarButtonItem(
                barButtonSystemItem: .add,
                target: presenter,
                action: #selector(presenter.onAddThreadTapped)
            )
        }
        
        navigationItem.rightBarButtonItem?.tintColor = isEnabled ? .primaryColor : .lightGray
    }
}
