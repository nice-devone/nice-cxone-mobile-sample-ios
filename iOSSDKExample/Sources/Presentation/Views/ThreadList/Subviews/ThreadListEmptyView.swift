import UIKit


class ThreadListEmptyView: UIView {
    
    // MARK: - Views
    
    private let titleLabel = UILabel()
    
    
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

private extension ThreadListEmptyView {
    
    func addAllSubviews() {
        addSubview(titleLabel)
    }

    func setupSubviews() {
        backgroundColor = .systemBackground
        
        titleLabel.text = "Your thread list is empty."
        titleLabel.textColor = .darkGray
        titleLabel.font = .preferredFont(forTextStyle: .title3)
    }
    
    func setupConstraints() {
        titleLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
}
