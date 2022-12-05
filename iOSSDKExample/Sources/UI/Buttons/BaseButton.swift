import UIKit


class BaseButton: UIButton {
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    init() {
        super.init(frame: .zero)
        
        var config: UIButton.Configuration = .filled()
        config.titlePadding = 10
        config.imagePadding = 10
        config.contentInsets = NSDirectionalEdgeInsets(top: 14, leading: 20, bottom: 14, trailing: 20)
        config.cornerStyle = .fixed
        
        self.configuration = config
        
        layer.cornerRadius = 8
    }
}
