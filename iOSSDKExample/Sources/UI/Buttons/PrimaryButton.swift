import UIKit


class PrimaryButton: BaseButton {
    
    // MARK: - Properties
    
    var identifier: String?

    override var intrinsicContentSize: CGSize {
        CGSize(width: super.intrinsicContentSize.width, height: 44)
    }
    
    
    // MARK: - Init
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    override init() {
        super.init()
        
        configure()
    }
}


// MARK: - Private methods

private extension PrimaryButton {
    
    func configure() {
        backgroundColor  = .systemBlue
        setTitleColor(.white, for: .normal)
    }
}
