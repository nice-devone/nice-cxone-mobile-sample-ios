import UIKit


class ThreadListView: UIView {
    
    // MARK: - Views
    
    let segmentedControl: UISegmentedControl = {
        let view = UISegmentedControl()
        view.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.black], for: .selected)
        view.selectedSegmentTintColor = .white
        view.insertSegment(withTitle: "Current", at: 0, animated: true)
        view.insertSegment(withTitle: "Archived", at: 1, animated: true)
        view.selectedSegmentIndex = 0
        
        return view
    }()
    private let headerView = UIView()
    private let separator = UIView()
    
    let emptyView = ThreadListEmptyView()
    let tableView = UITableView()
    
    
    // MARK: - Initialization

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    init() {
        super.init(frame: .zero)

        addAllSubviews()
        setupSubviews()
        setupConstraints()
    }
}


// MARK: - Private methods

private extension ThreadListView {
    
    func addAllSubviews() {
        addSubviews([emptyView, headerView, tableView])
        
        headerView.addSubviews([segmentedControl, separator])
    }

    func setupSubviews() {
        backgroundColor = .systemBackground
        
        separator.backgroundColor = .separator
    }
    
    func setupConstraints() {
        emptyView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        headerView.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide.snp.top)
            make.leading.trailing.equalToSuperview()
        }
        segmentedControl.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(18)
            make.leading.trailing.equalToSuperview().inset(24)
            make.height.equalTo(32)
        }
        separator.snp.makeConstraints { make in
            make.top.equalTo(segmentedControl.snp.bottom).offset(16)
            make.bottom.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(6)
            make.height.equalTo(0.5)
        }
        tableView.snp.makeConstraints { make in
            make.top.equalTo(headerView.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
}
