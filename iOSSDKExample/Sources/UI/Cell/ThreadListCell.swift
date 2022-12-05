import CXoneChatSDK
import MessageKit
import UIKit


class ThreadListCell: UITableViewCell {
    
    // MARK: - Views
    
    let avatarView = AvatarView(frame: .init(x: 0, y: 0, width: 70, height: 70))
	let nameLabel = UILabel()
	let lastMessageLabel = UILabel()
	
    
    // MARK: - Init
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		
		addAllSubviews()
        setupSubviews()
        setupConstraints()
	}
	
	
    // MARK: - Lifecycle
    
    override func prepareForReuse() {
        avatarView.initials = ""
        lastMessageLabel.text = ""
        nameLabel.text = ""
    }
}


// MARK: - Private methods

extension ThreadListCell {
    
    func configure(thread: ChatThread, isMultiThread: Bool) {
        let agentName = thread.name?.mapNonEmpty { $0 } ?? thread.assignedAgent?.fullName ?? "No Agent"
        nameLabel.text = agentName

        avatarView.initials = agentName.components(separatedBy: " ").reduce(into: "") { result, name in
            if let character = name.first {
                result += String(character)
            } else {
                result += ""
            }
        }

        if let kind = thread.messages.last?.kind {
            switch kind {
            case .text(let string):
                lastMessageLabel.text = string
            case .photo:
                lastMessageLabel.text = "Image"
            case .custom:
                lastMessageLabel.text = thread.messages.last?.messageContent.fallbackText
            default:
                Log.warning("unknown message kind - \(String(describing: thread.messages.last?.kind))")
            }
        }
    }
}


// MARK: - Private methods

private extension ThreadListCell {

    func addAllSubviews() {
        addSubviews([avatarView, nameLabel, lastMessageLabel])
    }
    
    func setupSubviews() {
        nameLabel.font = .systemFont(ofSize: 16, weight: .bold)
        
        lastMessageLabel.font = .systemFont(ofSize: 12, weight: .light)
    }
    
    func setupConstraints() {
        avatarView.snp.makeConstraints { make in
            make.top.leading.bottom.equalToSuperview().inset(10)
            make.width.equalTo(avatarView.snp.height)
        }
        nameLabel.snp.makeConstraints { make in
            make.top.trailing.equalToSuperview().inset(10)
            make.leading.equalTo(avatarView.snp.trailing).offset(10)
            make.height.equalTo(20)
        }
        lastMessageLabel.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom).offset(6)
            make.leading.equalTo(avatarView.snp.trailing).offset(10)
            make.trailing.equalToSuperview().inset(10)
        }
    }
}
