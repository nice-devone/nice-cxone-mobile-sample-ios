import CXoneChatSDK
import MessageKit
import UIKit


class ThreadDetailCustomCell: UICollectionViewCell {
    
    // MARK: - Views
    
    let pluginMessageView = PluginMessageView()
    
    
    // MARK: - Init
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    override init(frame: CGRect) {
        super.init(frame: .zero)
    
        contentView.addSubview(pluginMessageView)
        setupConstraints()
    }
}


// MARK: - Private methods

private extension ThreadDetailCustomCell {
    
    func setupConstraints() {
        pluginMessageView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(4)
            make.width.equalTo(200)
        }
    }
}
