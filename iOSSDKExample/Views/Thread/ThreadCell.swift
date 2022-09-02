import Foundation
import UIKit
import MessageKit

//KEEP

class ThreadCell: UITableViewCell {
	let avatarView = AvatarView()
	let nameLabel : UILabel = {
		var label = UILabel()
		label.font = UIFont.systemFont(ofSize: 16, weight: .bold)
		return label
	}()
	let lastMessageLabel : UILabel = {
		var label = UILabel()
		label.font = UIFont.systemFont(ofSize: 12, weight: .light)
		return label
	}()
	
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		
		addSubview(avatarView)
		addSubview(nameLabel)
		addSubview(lastMessageLabel)
		
		avatarView.translatesAutoresizingMaskIntoConstraints = false
		nameLabel.translatesAutoresizingMaskIntoConstraints = false
		lastMessageLabel.translatesAutoresizingMaskIntoConstraints = false
		
		avatarView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10).isActive = true
		avatarView.topAnchor.constraint(equalTo: self.topAnchor, constant: 10).isActive = true
		avatarView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -10).isActive = true
		avatarView.widthAnchor.constraint(equalTo: avatarView.heightAnchor).isActive = true
		
		nameLabel.leadingAnchor.constraint(equalTo: avatarView.trailingAnchor, constant: 10).isActive = true
		nameLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 10).isActive = true
		nameLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10).isActive = true
		nameLabel.heightAnchor.constraint(equalToConstant: 20).isActive = true
		
		lastMessageLabel.leadingAnchor.constraint(equalTo: avatarView.trailingAnchor, constant: 10).isActive = true
		lastMessageLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 5).isActive = true
		lastMessageLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10).isActive = true
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
    override func prepareForReuse() {
        lastMessageLabel.text = ""
        nameLabel.text = ""
    }
}
